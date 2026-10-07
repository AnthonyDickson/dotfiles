# Paperless-ngx

Document management at `https://paperless.s.anthonyd.co.nz`, running
`ghcr.io/paperless-ngx/paperless-ngx` as an Arion project with a Redis broker,
Gotenberg and Tika.

## Architecture

The Arion project (`paperless`) runs four containers:

| Service     | Image                                 | Role                                 |
| ----------- | ------------------------------------- | ------------------------------------ |
| `webserver` | `ghcr.io/paperless-ngx/paperless-ngx` | Django app, API and document storage |
| `broker`    | `redis:8-alpine`                      | Celery broker and cache              |
| `gotenberg` | `gotenberg/gotenberg`                 | Office document → PDF conversion     |
| `tika`      | `apache/tika`                         | MIME/content extraction              |

Caddy reverse proxies `paperless.s.anthonyd.co.nz` to the `webserver` container
on port 8777 and enforces Authelia forward-auth (`import authelia`). The `/api`
namespace bypasses Authelia so token-based API clients (such as the QuickScan
mobile app) can connect directly, authenticated by a Paperless API token (see
[Secrets](#secrets)); the web UI still requires two-factor authentication.

Paperless sees connections from Caddy arriving at the Docker bridge gateway, so
`PAPERLESS_TRUSTED_PROXIES` is set to the Docker bridge range (`172.16.0.0/12`).
This lets Paperless log the real client IP from `X-Forwarded-For`.

## Configuration

| File                | Contents                                                       |
| ------------------- | -------------------------------------------------------------- |
| `default.nix`       | Arion project, Caddy vhost, Authelia rule, backups, state dirs |
| `arion-compose.nix` | Container definitions and the non-secret `PAPERLESS_*` vars    |
| `secrets.env`       | Encrypted secrets (see below)                                  |

### State

Paperless stores its state under `/var/lib/paperless` (created at boot by
`systemd.tmpfiles`), owned by uid **1000** / gid **100** to match `USERMAP_UID`
/ `USERMAP_GID`:

| Path                         | Container path               | Backed up |
| ---------------------------- | ---------------------------- | --------- |
| `/var/lib/paperless/data`    | `/usr/src/paperless/data`    | db only   |
| `/var/lib/paperless/media`   | `/usr/src/paperless/media`   | yes       |
| `/var/lib/paperless/export`  | `/usr/src/paperless/export`  | no        |
| `/var/lib/paperless/consume` | `/usr/src/paperless/consume` | no        |
| `/var/lib/paperless/redis`   | `/data`                      | no        |

Drop files into `/var/lib/paperless/consume` to have them ingested. Backups dump
`data/db.sqlite3` and hardlink `media/` (see [Backups](./backups.md)).

## Secrets

`secrets.env` defines:

| Key                        | Purpose                                           |
| -------------------------- | ------------------------------------------------- |
| `PAPERLESS_SECRET_KEY`     | Django signing key; changing it logs everyone out |
| `PAPERLESS_ADMIN_PASSWORD` | Password for the `anthony` superuser              |

### First-time setup

1. Generate a secret key (used only on first launch; it persists in the database
   afterwards):

   ```shell
   nix run nixpkgs#openssl -- rand -base64 64 | tr -d '\n'
   ```

2. Create the encrypted secrets file, replacing the values:

   ```shell
   SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
     sops --input-type dotenv --output-type dotenv hosts/m75q_server/modules/paperless/secrets.env
   ```

   ```dotenv
   PAPERLESS_SECRET_KEY=<output from step 1>
   PAPERLESS_ADMIN_PASSWORD=<choose a strong password>
   ```

3. Commit and push, then on the server run `git pull && sudo nixos-rebuild
   switch --flake .#m75q_server`.

The admin user (`anthony`) and email are created only when the database is
empty, so they have no effect after the first launch.

## API access

Paperless-ngx ships a REST API under `/api`, used by the web UI and by external
clients such as the QuickScan mobile app. Because the API is token-authenticated
rather than interactive, Authelia forward-auth is bypassed for `/api` (see the
`bypass` rule in `default.nix`); the web UI itself still requires two-factor
authentication. Tokens are sent as `Authorization: Token <token>`.

To create a token, log into the web UI (through Authelia), open the user
dropdown → **My Profile**, and click the circular arrow next to the API token
field. Alternatively:

```shell
nix run nixpkgs#curl -- -s -X POST https://paperless.s.anthonyd.co.nz/api/token/ \
  -H 'Content-Type: application/json' \
  -d '{"username":"anthony","password":"<password>"}'
```

Then in QuickScan set the server URL to `https://paperless.s.anthonyd.co.nz` and
paste the token. Treat the token as a secret: it grants full API access to the
account, and anyone holding it can reach `/api` without Authelia.

## Container access

`PAPERLESS_ADMIN_USER` and `PAPERLESS_ADMIN_MAIL` live in `arion-compose.nix`;
they are not secret. All other settings are non-secret and live in
`arion-compose.nix`'s `environment` block.
