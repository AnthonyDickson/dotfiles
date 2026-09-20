# Authelia

Authentication and single sign-on for protected services behind Caddy reverse
proxy.

## First Login & MFA Enrollment

After deploying, you'll be prompted for a second factor on first login:

1. Visit any protected service, e.g. `https://budgeteur.s.anthonyd.co.nz`
2. You'll be redirected to `https://auth.s.anthonyd.co.nz`
3. Log in with your username and password
4. Authelia will prompt to enroll a second factor — the enrollment link is
   written to a local file (no email server needed):

   ```shell
   cat /var/lib/authelia-main/notifications.txt
   ```
5. Open the link and choose either:
   - **One-Time Password** — scan the QR code with an authenticator app (Aegis,
     1Password, etc.)
   - **Security Key** — register a passkey, YubiKey, or platform authenticator
     (Face ID, Touch ID, Windows Hello)

After enrollment, subsequent logins will prompt for your chosen second factor.

## Adding More Users

1. Generate a password hash:

   ```shell
   nix run nixpkgs#authelia -- crypto hash generate argon2 --password 'theirpassword'
   ```

2. Add their hash to `hosts/m75q_server/modules/authelia/secrets.yaml`:

   ```yaml
   AUTHELIA_USER_ANTHONYD_HASH: $argon2id$...   # existing
   AUTHELIA_USER_NEWPERSON_HASH: $argon2id$...  # new
   ```

3. Re-encrypt:

   ```shell
   sops --encrypt --in-place hosts/m75q_server/modules/authelia/secrets.yaml
   ```

4. Add a new `sops.secrets` entry and update the template in
   `hosts/m75q_server/modules/authelia/default.nix`:

   ```nix
   sops.secrets.authelia-user-newperson-hash = {
     sopsFile = ./secrets.yaml;
     format = "yaml";
     key = "AUTHELIA_USER_NEWPERSON_HASH";
     owner = "authelia-main";
   };

   sops.templates."authelia-users.yml" = {
     owner = "authelia-main";
     path = "/var/lib/authelia-main/users.yml";
     content = ''
       users:
         anthonyd:
           displayname: "Anthony Dickson"
           password: "${config.sops.placeholder.authelia-user-anthonyd-hash}"
           email: anthony.dickson9656@gmail.com
           groups:
             - admins
         newperson:
           displayname: "New Person"
           password: "${config.sops.placeholder.authelia-user-newperson-hash}"
           email: newperson@example.com
           groups: []
     '';
   };
   ```

5. Rebuild:

   ```shell
   sudo nixos-rebuild switch
   ```

   sops-nix rewrites the users file and Authelia reloads it automatically
   (`watch = true`). Give the new user their credentials out-of-band — they
   enroll their own MFA on first login.

## Switching to SMTP Notifier

When Stalwart (or another SMTP server) is ready, replace the notifier block in
`hosts/m75q_server/modules/authelia/default.nix`:

```nix
# Remove:
notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

# Add:
notifier.smtp = {
  host = "127.0.0.1";
  port = 587;
  username = "auth@s.anthonyd.co.nz";
  sender = "Authelia <auth@s.anthonyd.co.nz>";
};
```

Then add `AUTHELIA_NOTIFIER_SMTP_PASSWORD: <password>` to
`hosts/m75q_server/modules/authelia/secrets.yaml` as a new sops secret (owner:
`authelia-main`), re-encrypt, and `sudo nixos-rebuild switch`.

## OpenID Connect Clients

Services that support OIDC log in through Authelia directly, so each one needs a
client registered under
`services.authelia.instances.main.settings.identity_providers.oidc.clients` in
that service's own module. See `hosts/m75q_server/modules/homepage/default.nix`
and `hosts/m75q_server/modules/lustre_todos/default.nix` for examples.

Each client specifies:

- `client_id`: a short unique name, usually the service name.
- `client_secret`: the **digest** of the secret shared with the service, not the
  secret itself.
- `redirect_uris`: the service's callback URL, e.g.
  `https://homepage.s.anthonyd.co.nz/api/auth/callback/homepage-oidc`.
- `scopes`, `grant_types`, `response_types`, `response_modes`: whatever the
  service requests.
- `authorization_policy`: `one_factor` or `two_factor` for the authorization
  request. This is separate from `access_control`, which still governs
  forward-auth for the same domain.
- `token_endpoint_auth_method`: `client_secret_basic` for most clients; check
  the service's documentation (Lustre Todos uses `client_secret_post`).

### Generating a Client Secret

Generate the secret and its digest in one step:

```shell
nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
```

The command prints two values:

- the **plaintext secret**, which goes to the service, usually in an encrypted
  env file such as `hosts/m75q_server/modules/homepage/secrets.env`;
- the **digest**, which starts with `$pbkdf2-sha512$` and goes in the module's
  `client_secret`.

Both must come from the same run, otherwise the token exchange fails with
`invalid_client`. Authelia also accepts a plaintext secret, but that is
deprecated and would put the secret in the Nix store, so always use the digest.

To rotate, repeat the command and update the digest in the service module and
the plaintext secret in its sops file, then commit, push, and `sudo
nixos-rebuild switch` on the server.

### Access Control

Authelia's `access_control.default_policy` is `deny`, so a service's domain also
needs an explicit rule or requests to it will be rejected:

```nix
services.authelia.instances.main.settings.access_control.rules = [
  {
    domain = "homepage.s.anthonyd.co.nz";
    policy = "two_factor";
  }
];
```

## Troubleshooting

| Symptom                            | Check                                                                         |
| ---------------------------------- | ----------------------------------------------------------------------------- |
| Redirect loop on protected service | Confirm `auth.s.anthonyd.co.nz` has no `import authelia`                      |
| 401/403 after login                | Check `access_control` rules; verify cookie domain matches `s.anthonyd.co.nz` |
| MFA enrollment link not received   | `cat /var/lib/authelia-main/notifications.txt`                                |
| Passkey not working                | Ensure you're accessing via HTTPS; WebAuthn requires a secure context         |
| Service starts but crashes         | `journalctl -u authelia-main --since "5 min ago"`                             |
| `invalid_client` from a service    | Digest in the client's `client_secret` must match its sops secret             |
