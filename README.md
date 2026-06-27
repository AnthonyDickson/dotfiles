# Dotfiles

NixOS, Nix, and Home Manager configurations for my desktop and server.

## Hosts

| Host          | Type    | Purpose                      |
| ------------- | ------- | ---------------------------- |
| `m75q`        | Desktop | Daily driver with Cosmic DE  |
| `m75q_server` | Server  | Containerised apps via Arion |

## Quick Start

**Desktop**: See [Desktop Setup](docs/desktop.md) for installation and migration.

**Server**: See [Server Setup](docs/server.md) for installation and post-install.

## Guides

- [Desktop Setup](docs/desktop.md) — NixOS desktop installation, post-install steps, and migration from another install
- [Server Architecture](docs/architecture.md) — High-level server design, external dependencies, and networking
- [Server Setup](docs/server.md) — NixOS server installation, Tailscale, and deploy keys
- [Secret Management](docs/secrets.md) — Managing encrypted secrets with sops-nix and age
- [Docker Operations](docs/docker.md) — Adding projects, updating images, and operational commands for Arion
- [Authelia](docs/authelia.md) — MFA enrollment, user management, SMTP setup, and troubleshooting

## Structure

```
├── flake.nix              # Flake entrypoint
├── .sops.yaml             # sops encryption rules
├── modules/
│   ├── home/              # Home Manager modules
│   └── system/            # NixOS system modules
└── hosts/
    ├── m75q/              # Desktop configuration
    └── m75q_server/       # Server configuration
        ├── projects/      # Arion compose configs per app
        └── *_secrets.env  # Encrypted secrets (safe to commit)
```
