# Authelia

Authentication and single sign-on for protected services behind Caddy reverse proxy.

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
   - **One-Time Password** — scan the QR code with an authenticator app
     (Aegis, 1Password, etc.)
   - **Security Key** — register a passkey, YubiKey, or platform authenticator
     (Face ID, Touch ID, Windows Hello)

After enrollment, subsequent logins will prompt for your chosen second factor.

## Adding More Users

1. Generate a password hash:

   ```shell
   nix run nixpkgs#authelia -- crypto hash generate argon2 --password 'theirpassword'
   ```

2. Add their hash to `hosts/m75q_server/authelia_secrets.yaml`:

   ```yaml
   AUTHELIA_USER_ANTHONYD_HASH: $argon2id$...   # existing
   AUTHELIA_USER_NEWPERSON_HASH: $argon2id$...  # new
   ```

3. Re-encrypt:

   ```shell
   sops --encrypt --in-place hosts/m75q_server/authelia_secrets.yaml
   ```

4. Add a new `sops.secrets` entry and update the template in
   `hosts/m75q_server/configuration.nix`:

   ```nix
   sops.secrets.authelia-user-newperson-hash = {
     sopsFile = ./authelia_secrets.yaml;
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
`configuration.nix`:

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
`authelia_secrets.yaml` as a new sops secret (owner: `authelia-main`),
re-encrypt, and `sudo nixos-rebuild switch`.

## Troubleshooting

| Symptom                                    | Check                                                               |
| ------------------------------------------ | ------------------------------------------------------------------- |
| Redirect loop on protected service         | Confirm `auth.s.anthonyd.co.nz` has no `import authelia`            |
| 401/403 after login                        | Check `access_control` rules; verify cookie domain matches `s.anthonyd.co.nz` |
| MFA enrollment link not received           | `cat /var/lib/authelia-main/notifications.txt`                      |
| Passkey not working                        | Ensure you're accessing via HTTPS; WebAuthn requires a secure context |
| Service starts but crashes                 | `journalctl -u authelia-main --since "5 min ago"`                   |
