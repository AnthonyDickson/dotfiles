# Forgejo

Git hosting at `https://git.s.anthonyd.co.nz`, running the rootless
`codeberg.org/forgejo/forgejo` image as an Arion project with SQLite. Sign-in is
only through Authelia (OpenID Connect).

## Architecture

The Arion project (`forgejo`) runs a single container named `forgejo`. The
rootless image runs as uid/gid **1000** and keeps all of its state, including
`app.ini`, under `/var/lib/gitea` in the container.

| Host port | Container port | Purpose                                      |
| --------- | -------------- | -------------------------------------------- |
| 3030      | 3000           | Web UI, API and git over HTTPS (via Caddy)   |
| 2222      | 2222           | Forgejo's built-in SSH server (git over SSH) |

Caddy reverse proxies `git.s.anthonyd.co.nz` to port 3030 **without** Authelia
forward-auth. Forward-auth would block `git clone`/`push` over HTTPS and API
clients, so Forgejo handles authentication itself:

- Accounts can only be created by signing in with Authelia; Forgejo's own
  username/password sign-in and registration form are disabled
  (`ENABLE_INTERNAL_SIGNIN=false`, `ALLOW_ONLY_EXTERNAL_REGISTRATION=true`).
- The OIDC client requires two-factor authentication in Authelia.
- Members of the Authelia `admins` group become Forgejo site admins on login.
- The Forgejo username is taken from Authelia's `preferred_username` (e.g.
  `anthonyd`).

Port 2222 is opened in the firewall; SSH traffic goes straight to the container,
not through Caddy.

## Configuration

| File                | Contents                                                           |
| ------------------- | ------------------------------------------------------------------ |
| `default.nix`       | Arion project, Caddy vhost, Authelia rule and OIDC client, backups |
| `arion-compose.nix` | Container definition and the non-secret `FORGEJO__*` settings      |
| `secrets.env`       | Encrypted secrets (see below)                                      |

Settings are passed as `FORGEJO__<section>__<KEY>` environment variables, which
the image writes into `app.ini` on every start. Edit `arion-compose.nix` rather
than `app.ini`, since changes made directly to `app.ini` are overwritten for any
key that is also set in the environment.

### State

Forgejo stores its state under `/var/lib/forgejo` (created at boot by
`systemd.tmpfiles`, owned by `1000:1000`), mounted at `/var/lib/gitea`:

| Path                                   | Contents                               | Backed up       |
| -------------------------------------- | -------------------------------------- | --------------- |
| `/var/lib/forgejo/data/gitea.db`       | SQLite database                        | yes (dump)      |
| `/var/lib/forgejo/git/repositories`    | Bare git repositories                  | yes             |
| `/var/lib/forgejo/git/lfs`             | Git LFS objects                        | yes             |
| `/var/lib/forgejo/data/attachments`    | Issue/release attachments              | yes             |
| `/var/lib/forgejo/data/` (other)       | Avatars, sessions, SSH host keys, logs | no              |
| `/var/lib/forgejo/custom/conf/app.ini` | Generated config, **contains secrets** | no (deliberate) |

The database is named `gitea.db` because that is the rootless image's default.

## Secrets

`secrets.env` defines:

| Key                                 | Purpose                                                                |
| ----------------------------------- | ---------------------------------------------------------------------- |
| `FORGEJO__security__SECRET_KEY`     | Encrypts secrets stored in the database (e.g. 2FA, OAuth)              |
| `FORGEJO__security__INTERNAL_TOKEN` | Authenticates Forgejo's internal API calls                             |
| `FORGEJO__oauth2__JWT_SECRET`       | Signs tokens issued by Forgejo's own OAuth2 provider                   |
| `OIDC_CLIENT_SECRET`                | Plaintext Authelia client secret; only read by the setup command below |

**Do not change `SECRET_KEY` after the first launch.** Values Forgejo encrypted
with it (such as users' 2FA and Actions secrets) become unreadable.

The PBKDF2 digest of `OIDC_CLIENT_SECRET` is the `client_secret` in
`default.nix`. The digest and the secret must come from the same run of the
command in [OpenID Connect Clients](./authelia.md#openid-connect-clients).

### Regenerating the secrets file

Generate the Forgejo secrets with:

```shell
nix shell nixpkgs#forgejo -c forgejo generate secret SECRET_KEY
nix shell nixpkgs#forgejo -c forgejo generate secret INTERNAL_TOKEN
nix shell nixpkgs#forgejo -c forgejo generate secret JWT_SECRET
```

then edit the file:

```shell
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --input-type dotenv --output-type dotenv hosts/m75q_server/modules/forgejo/secrets.env
```

## First-time setup

Forgejo stores login sources in its database rather than `app.ini`, so the
Authelia login source has to be added once with the Forgejo CLI after the first
deploy. Until this is done the login page has no way to sign in.

1. Deploy, then confirm the container is healthy:

   ```shell
   git pull && sudo nixos-rebuild switch --flake .#m75q_server
   docker ps --filter name=forgejo
   ```

2. Add the Authelia login source. The client secret is read from the container's
   environment (`OIDC_CLIENT_SECRET`, from `secrets.env`), so it never appears
   on the command line or in shell history:

   ```shell
   docker exec forgejo sh -c 'forgejo admin auth add-oauth \
     --name authelia \
     --provider openidConnect \
     --key forgejo \
     --secret "$OIDC_CLIENT_SECRET" \
     --auto-discover-url https://auth.s.anthonyd.co.nz/.well-known/openid-configuration \
     --scopes "openid email profile groups" \
     --group-claim-name groups \
     --admin-group admins \
     --skip-local-2fa'
   ```

   - `--name authelia` must match the `/user/oauth2/authelia/callback` redirect
     URI in `default.nix`.
   - `--key forgejo` must match the client's `client_id`.
   - `--admin-group admins` makes members of the Authelia `admins` group Forgejo
     site admins.
   - `--skip-local-2fa` skips Forgejo's own 2FA prompt, since Authelia already
     requires it.

3. Check it was created, then restart Forgejo:

   ```shell
   docker exec forgejo forgejo admin auth list
   sudo systemctl restart arion-forgejo.service
   ```

   The restart is required. The CLI writes the source to the database, but the
   running server only registers login sources at startup. Without a restart,
   the first sign-in is sent to Authelia without a PKCE `code_challenge` and
   Authelia rejects it with "There was an error processing the authorization
   request".

4. Visit `https://git.s.anthonyd.co.nz`, click **Sign in with authelia**, and
   log in. Your account is created automatically on first login.

5. Add an SSH key under **Settings → SSH / GPG Keys**.

### Changing the login source later

Find the source's ID with `admin auth list`, then use `update-oauth` with the
same flags as above, e.g. after rotating the client secret:

```shell
docker exec forgejo forgejo admin auth list
docker exec forgejo sh -c 'forgejo admin auth update-oauth --id 1 --secret "$OIDC_CLIENT_SECRET"'
sudo systemctl restart arion-forgejo.service
```

As with `add-oauth`, restart Forgejo afterwards so the running server picks up
the change.

To rotate the client secret, generate a new secret/digest pair, update
`OIDC_CLIENT_SECRET` in `secrets.env` and `client_secret` in `default.nix`,
deploy, then run the `update-oauth` commands above.

## Using git

**SSH** (port 2222, using the key added in Forgejo):

```shell
git clone ssh://git@git.s.anthonyd.co.nz:2222/anthonyd/repo.git
```

Or set the port once in `~/.ssh/config` and use the short form:

```
Host git.s.anthonyd.co.nz
  Port 2222
  User git
```

```shell
git clone git@git.s.anthonyd.co.nz:anthonyd/repo.git
```

**HTTPS**: SSO accounts have no Forgejo password, so create an access token
under **Settings → Applications** (scope: `repository` read/write) and use it as
the password when git prompts.

## Mirroring GitHub repositories

Use **+ → New migration → GitHub**, paste the repository URL, and tick **This
repository will be a mirror** to keep it in sync on a schedule. Mirroring a
private repository needs a GitHub personal access token entered in the same
form.

## Backups

The daily backup (see [Backups](./backups.md)) dumps the SQLite database and
hardlinks the repositories, LFS objects and attachments into
`/mnt/backups/mirror/forgejo/`, mirroring the layout of `/var/lib/forgejo`:

```
/mnt/backups/mirror/forgejo/
├── data/
│   ├── gitea.db
│   └── attachments/
└── git/
    ├── repositories/
    └── lfs/
```

To restore, stop the project, copy the tree back, fix ownership, and start it:

```shell
sudo systemctl stop arion-forgejo.service
sudo rsync -a /mnt/backups/mirror/forgejo/ /var/lib/forgejo/
sudo chown -R 1000:1000 /var/lib/forgejo
sudo systemctl start arion-forgejo.service
```

`app.ini` is regenerated from the environment on start, and the secrets come
from `secrets.env`, so neither needs restoring. Repository git hooks are
regenerated with `docker exec forgejo forgejo admin regenerate hooks`.

## Updating

Bump the pinned tag in `arion-compose.nix` (keep the `-rootless` suffix) and
deploy. Forgejo migrates the database automatically on start; read the
[release notes](https://codeberg.org/forgejo/forgejo/releases) before major
version bumps.

## Troubleshooting

| Symptom                                                | Check                                                                    |
| ------------------------------------------------------ | ------------------------------------------------------------------------ |
| No "Sign in with authelia" button                      | Login source missing: run the [first-time setup](#first-time-setup) step |
| Authelia: "error processing the authorization request" | Forgejo wasn't restarted after `add-oauth`/`update-oauth`; restart it    |
| `invalid_client` after Authelia login                  | Digest in `default.nix` must match `OIDC_CLIENT_SECRET`                  |
| `redirect_uri` mismatch                                | Login source name must be `authelia`                                     |
| Not an admin after login                               | Authelia user must be in the `admins` group; log out and back in         |
| SSH connection refused                                 | Port 2222 in the clone URL; `docker ps` shows `0.0.0.0:2222->2222`       |
| Container exits on start                               | `journalctl -u arion-forgejo.service` / `docker logs forgejo`            |
| Permission denied writing `/var/lib/gitea`             | `sudo chown -R 1000:1000 /var/lib/forgejo`                               |
