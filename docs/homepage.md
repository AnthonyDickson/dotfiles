# Homepage

Service dashboard at `https://homepage.s.anthonyd.co.nz`, running
`ghcr.io/gethomepage/homepage` as an Arion project. Authentication is handled by
Authelia using OpenID Connect.

## Architecture

- **Caddy** reverse proxies the domain and enforces Authelia forward-auth
  (`import authelia`).
- **Authelia** is the OIDC provider; Homepage is registered as the `homepage` client.
- **Homepage** v2 has its own login gate, so it also redirects to Authelia to
  establish its own session. The client uses PKCE with `one_factor`, which the
  existing Authelia session satisfies, so you only complete 2FA once.

## Configuration

| File                              | Contents                                                                   |
| --------------------------------- | -------------------------------------------------------------------------- |
| `default.nix`                     | Arion project, Caddy vhost, Authelia access control rule and OIDC client    |
| `arion-compose.nix`               | Container definition and `HOMEPAGE_*` OIDC environment variables            |
| `homepage-config.nix`             | Dashboard settings, services, bookmarks and widgets                         |
| `secrets.env`                     | Encrypted secrets (see below)                                               |

The OIDC callback registered with Authelia is
`https://homepage.s.anthonyd.co.nz/api/auth/callback/homepage-oidc`.

## Secrets

`secrets.env` defines:

| Key                           | Purpose                                  |
| ----------------------------- | ---------------------------------------- |
| `HOMEPAGE_AUTH_SECRET`        | Signs and encrypts Homepage session cookies |
| `HOMEPAGE_OIDC_CLIENT_SECRET` | OIDC client secret shared with Authelia  |

### First-time setup

1. Generate the OIDC client secret and its PBKDF2 digest:

   ```shell
   nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
   ```

   This prints the plaintext secret, which goes to the relying party (Homepage),
   and the digest, which goes to Authelia.

2. Put the digest in `client_secret` in `default.nix`, replacing
   `REPLACE_WITH_CLIENT_SECRET_HASH`.

3. Create the encrypted secrets file using the plaintext secret from step 1 and a
   fresh auth secret (`nix run nixpkgs#openssl -- rand -hex 32`):

   ```shell
   SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
     sops --input-type dotenv --output-type dotenv hosts/m75q_server/modules/homepage/secrets.env
   ```

   ```dotenv
   HOMEPAGE_AUTH_SECRET=<64 hex characters>
   HOMEPAGE_OIDC_CLIENT_SECRET=<plaintext secret from step 1>
   ```

4. Commit and push, then on the server run
   `git pull && sudo nixos-rebuild switch --flake .#m75q_server`.

### Rotating the client secret

Repeat step 1, then update both the digest in `default.nix` and
`HOMEPAGE_OIDC_CLIENT_SECRET` in `secrets.env`, and rebuild.

## Troubleshooting

| Symptom                                   | Check                                                                       |
| ----------------------------------------- | --------------------------------------------------------------------------- |
| `invalid_client` returned by Authelia      | The digest in `client_secret` must match `HOMEPAGE_OIDC_CLIENT_SECRET`       |
| Redirect loop at `/api/auth/callback/...`  | `HOMEPAGE_EXTERNAL_URL` must be the public HTTPS URL                         |
| Configuration error on the sign-in page    | `HOMEPAGE_AUTH_SECRET` must be at least 32 characters                        |
