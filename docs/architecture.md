# Server Architecture

High-level design and the external hardware/services the server depends on —
none of which are managed by this NixOS configuration.

## Diagram

```
      Internet
         │
  ┌──────┴──────┐
  │  Cloudflare │  DNS for anthonyd.co.nz
  │  (external) │  ACME DNS-01 challenges
  └──────┬──────┘
         │
  ┌──────┴──────┐
  │  Tailscale  │  VPN for remote access
  │  (external) │  Advertises 192.168.0.0/24
  └──────┬──────┘
         │
┌────────┴────────┐
│  SERVER-A       │  192.168.0.20
│  (this config)  │
│                 │
│  Caddy ─────────┤  Reverse proxy (HTTPS)
│  Authelia ──────┤  Forward auth (MFA)
│  Homepage ──────┤  Service dashboard
│  Jellyfin ──────┤  Media server
│  Budgeteur ─────┤  Personal budgeting
│  dnsmasq ───────┤  Local DNS forwarder
│  unbound ───────┤  Recursive resolver
└────────┬────────┘
         │
┌────────┴────────┐
│  Synology NAS   │  192.168.0.10
│  (external)     │  NFS exports for media
│                 │  and backups
└─────────────────┘
```

## External Dependencies

Everything below is assumed to exist and be configured separately. If any of
these move, change IP, or are decommissioned, this server config breaks.

### Cloudflare

The domain **`anthonyd.co.nz`** is registered with Cloudflare and its DNS is
managed there. Subdomains under `s.anthonyd.co.nz` point at the server:

| Hostname                     | Backend   |
| ---------------------------- | --------- |
| `auth.s.anthonyd.co.nz`      | Authelia  |
| `budgeteur.s.anthonyd.co.nz` | Budgeteur |
| `homepage.s.anthonyd.co.nz`  | Homepage  |
| `jellyfin.s.anthonyd.co.nz`  | Jellyfin  |

Caddy uses Cloudflare's **DNS-01 ACME** plugin to obtain wildcard TLS
certificates for `*.s.anthonyd.co.nz`. This means the server does not need
ports 80/443 reachable from the internet — domain validation happens via DNS
TXT records that Caddy creates through the Cloudflare API.

A scoped Cloudflare API token with DNS edit permission on `anthonyd.co.nz` is
required. It lives in `modules/caddy/secrets.env` (encrypted with sops) and is
injected into Caddy's environment at boot.

**Assumptions**:

- Cloudflare account is active and the domain is delegated to Cloudflare
  nameservers
- DNS records for the subdomains above exist (Caddy manages ACME records but
  not the A/AAAA records)
- The API token has `Zone:DNS:Edit` permission on `anthonyd.co.nz`

### Synology NAS

A Synology NAS at **`192.168.0.10`** exports two NFSv4.1 shares:

- **`/volume1/data/media`** — read-only media library for Jellyfin, mounted at
  `/mnt/media`
- **`/volume1/server_backup`** — backup staging area, mounted at `/mnt/backups`
  (see [Backups](backups.md))

The `arion-jellyfin` systemd service has a hard dependency on
`mnt-media.mount` — the container starts only after the NAS is reachable and
the share is mounted.

The `server-backup` systemd service has a soft dependency (`wants`) on
`mnt-backups.mount` — it skips the backup run if the NAS isn't reachable.

Jellyfin runs inside its container as **uid 1000 / gid 303** (gid 303 is the
`render` group for `/dev/dri` hardware transcoding). The NFS export on the NAS
must squash all access to these same IDs — otherwise the container cannot read
media files. In DSM, set **Squash → Map all users to admin** on the NFS
permissions rule, or configure explicit `anonuid=1000,anongid=303`.

The backup share uses the same squash setting (map all to admin) — the backup
script runs as root on the server and the NAS squashes access to a single
account.

**Assumptions**:

- NAS is at a static IP (`192.168.0.10`) and always powered on
- NFSv4.1 is enabled on the NAS with both shares exported
- Both shares are accessible without authentication (network trust) — the NixOS
  config does not set up Kerberos, `sec=krb5`, or explicit NFS credentials
- NFS squash is configured to map all access to admin for both shares
- The directory layout under `/volume1/data/media` is what Jellyfin expects
  (the NAS manages its own folder structure)
- `/volume1/server_backup` has a quota configured (100 GB at time of writing)

### Tailscale

The server joins a Tailscale tailnet for remote SSH and HTTPS access when off
the local network. It advertises the **`192.168.0.0/24`** subnet route so
connected clients can reach the NAS and other local devices.

**Assumptions**:

- A Tailscale account (free tier is sufficient) with the server node approved
- The advertised subnet route `192.168.0.0/24` is approved in the Tailscale
  admin console
- Tailscale's MagicDNS is disabled on the server (`--accept-dns=false`) because
  local resolution is handled by dnsmasq/unbound — the server does not want
  Tailscale overriding its DNS

### GitHub Deploy Key

A read-only SSH deploy key registered on
[`AnthonyDickson/dotfiles`](https://github.com/AnthonyDickson/dotfiles) allows
the server to `git pull` config updates without an interactive login.

**Assumptions**:

- The deploy key is registered in the repo's Deploy Keys settings
- The private key is placed at `~/.ssh/nixos_config` on the server with
  permissions `600`
- The SSH config restricts this key to `github.com` only, so it cannot be
  misused for other hosts (see `programs.ssh.extraConfig` in
  `configuration.nix`)

### Container Registries

Public images are pulled from `ghcr.io` (Budgeteur, Homepage) and Docker Hub
(Jellyfin) at `nixos-rebuild` time. No registry credentials are needed.

**Assumptions**:

- Outbound internet access from the server (no proxy required)
- Tags are pinned to specific versions for reproducibility; if using a floating
  tag like `latest`, images must be pulled manually (see
  [Docker Operations](docker.md))

### Public Internet (ACME, Image Pulls, Nix)

The server needs general outbound internet access for:

- Pulling container images from ghcr.io and Docker Hub
- Fetching Nix build inputs and binary cache (cache.nixos.org)
- Let's Encrypt / Cloudflare ACME challenges
- `git pull` from GitHub

No inbound internet access is required beyond what Tailscale provides — Caddy's
ACME challenges go through Cloudflare DNS, not HTTP.

## Networking

```
Server IP:   192.168.0.20
NAS IP:      192.168.0.10
Domain:      anthonyd.co.nz
Subdomain:   s.anthonyd.co.nz (services)
```

The server runs dnsmasq so local clients can resolve these domains to the NAS
and server without public DNS — the router's DHCP should hand out the server as
the DNS resolver, or clients must configure it manually.

| Port | Protocol | Service | Purpose             |
| ---- | -------- | ------- | ------------------- |
| 22   | TCP      | OpenSSH | Remote admin access |
| 53   | TCP+UDP  | dnsmasq | Local DNS           |
| 80   | TCP+UDP  | Caddy   | HTTP→HTTPS redirect |
| 443  | TCP+UDP  | Caddy   | HTTPS termination   |

All other ports (Authelia :9091, Budgeteur :8080, Homepage :3000, Jellyfin
:8096, unbound :5353) are internal and blocked by the firewall.

## Secret Management

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using
[age](https://github.com/FiloSottile/mkcert). See
[Secret Management](secrets.md) for the full workflow.

Two keys can decrypt secrets:

- **Server host key** at `/etc/ssh/ssh_host_ed25519_key` (generated at first
  NixOS boot) — used by sops-nix at boot to decrypt into `/run/secrets/`
- **Admin age key** on the local workstation — used to encrypt and re-encrypt
  secrets before committing

**Assumptions**:

- The server's SSH host key is an ed25519 key (the default for NixOS); if the
  key type changes, `.sops.yaml` must be updated
- The admin key is backed up securely — if both the server and admin key are
  lost, all secrets are unrecoverable and must be regenerated

## Hardware

Derived from `hardware-configuration.nix`:

- **CPU**: AMD with KVM support for virtualisation
- **GPU**: Intel or AMD iGPU with `/dev/dri` available for VA-API transcoding
  (passed into Jellyfin)
- **Storage**: NVMe SSD — ext4 root, vfat EFI boot, swap partition
- **Boot**: systemd-boot with EFI
