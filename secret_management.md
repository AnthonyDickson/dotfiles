# Secret Management

## Overview

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix) with [age](https://github.com/FiloSottile/mkcert) encryption. Each secret file is encrypted such that only authorised keys can decrypt it, and is safe to commit to git.

Two types of keys are involved:

- **Server host key** — located at `/etc/ssh/ssh_host_ed25519_key`, generated at first boot. Used by sops-nix to automatically decrypt secrets at boot time.
- **Admin key** — your personal age key, stored on your local machine. Used to encrypt and re-encrypt secrets. Acts as a recovery key if the server is lost.

At boot, sops-nix decrypts secrets into `/run/secrets/` (a tmpfs — in RAM only, never written to disk) and re-decrypts them fresh on every reboot.

## Maintaining Secrets

Secret creation and editing is done on your **local machine** (where your admin key lives). Deploying is done on the **server**.

### Adding or updating a secret

On your **local machine**:

```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --input-type dotenv --output-type dotenv hosts/myserver/projects/myapp/secrets.env
```

This opens `$EDITOR` with the decrypted contents. Make your changes, save, and close — sops re-encrypts automatically.

Then commit and push:

```bash
git add hosts/myserver/projects/myapp/secrets.env
git commit -m "update myapp secrets"
git push
```

On the **server**, pull and rebuild:

```bash
git pull
sudo nixos-rebuild switch --flake .#myserver
```

### Adding a new project

On your **local machine**:

1. Create the secrets file:
```bash
mkdir -p hosts/myserver/projects/newapp

SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --input-type dotenv --output-type dotenv hosts/myserver/projects/newapp/secrets.env
```

2. Declare the secret in `sops.nix`:
```nix
secrets.newapp-env = {
  sopsFile = ./projects/newapp/secrets.env;
  format = "dotenv";
  path = "/run/secrets/newapp.env";
};
```

3. Reference it in your arion compose config, commit, and push.

On the **server**, pull and rebuild.

### Rotating a secret

On your **local machine**, open and edit the file as above, update the value, commit, and push. On the **server**, pull and rebuild. The new value takes effect on the next `nixos-rebuild switch`.

## Migrating to a New Server

### Scenario 1 — Admin key is available (standard migration)

The admin key allows you to re-encrypt secrets for the new server's host key without needing the old server at all.

1. On the **new server**, get its host public key:
```bash
nix-shell -p ssh-to-age --run \
  'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

2. On your **local machine**, update `.sops.yaml` with the new server key:
```yaml
keys:
  - &old-server age1...  # keep until migration complete
  - &new-server age1...  # add new server
  - &admin      age1...

creation_rules:
  - path_regex: hosts/myserver/.*secrets\.env
    key_groups:
      - age:
          - *new-server
          - *admin
```

3. On your **local machine**, re-encrypt all secrets using your admin key:
```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops updatekeys \
  hosts/myserver/projects/myapp/secrets.env
```

Repeat for each secrets file, then commit and push.

4. On the **new server**, clone the repo and rebuild:
```bash
git clone <your-repo>
sudo nixos-rebuild switch --flake .#myserver
```

### Scenario 2 — Admin key is not available

If both the old server and the admin key are lost, the encrypted secrets are unrecoverable. You will need to:

1. On the **new server**, get its host public key as above.
2. On your **local machine**, update `.sops.yaml` with only the new server key.
3. On your **local machine**, re-create each secrets file with regenerated values (reissue API keys, generate new passwords, etc.):
```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --input-type dotenv --output-type dotenv hosts/myserver/projects/myapp/secrets.env
```
4. Commit, push, then on the **new server** clone the repo and rebuild.

This is why keeping your admin key backed up securely (e.g. on a hardware key or in secure offline storage) is critical — it is the only recovery path that does not require regenerating secrets.
