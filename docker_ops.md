# Docker Operations

## Adding a New Project

Adding a new project spans three files. The steps below use `newapp` as an example.

### 1. Create the arion compose config

```nix
# hosts/myserver/projects/newapp/arion-compose.nix
{ secretPath }: # receives the secret path from docker.nix
{ pkgs, ... }: {
  project.name = "newapp";

  services.web.service = {
    image = "myorg/newapp:latest";
    ports = [ "8081:8081" ];
    env_file = [ secretPath ];
    restart = "unless-stopped";
  };
}
```

### 2. Add the secret

On your **local machine**, create and encrypt the secrets file (see [Secret Management](./secret_management.md)):

```bash
mkdir -p hosts/myserver/projects/newapp

SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --input-type dotenv --output-type dotenv hosts/myserver/projects/newapp/secrets.env
```

### 3. Declare the secret in sops.nix

```nix
secrets.newapp-env = {
  sopsFile = ./projects/newapp/secrets.env;
  format = "dotenv";
  path = "/run/secrets/newapp.env";
};
```

### 4. Register the project in docker.nix

```nix
virtualisation.arion.projects = {
  budgeteur.settings.imports = [ ... ]; # existing

  newapp.settings.imports = [
    (import ./projects/newapp/arion-compose.nix {
      secretPath = config.sops.secrets.newapp-env.path;
    })
  ];
};
```

The `secretPath` argument is necessary because the arion compose config does not have access to the NixOS `config` module — the path must be passed in explicitly from `docker.nix` where `config.sops` is in scope.

### 5. Commit, push, and rebuild

On your **local machine**:
```bash
git add .
git commit -m "add newapp project"
git push
```

On the **server**:
```bash
git pull
sudo nixos-rebuild switch --flake .#myserver
```

---

## Updating a Container Image

### Pinned tag (e.g. `myapp:1.2.0`)

Update the tag in the arion compose config, then commit, push, and rebuild:

```nix
image = "myorg/myapp:1.3.0"; # bump the version
```

```bash
# local
git commit -am "bump myapp to 1.3.0" && git push

# server
git pull && sudo nixos-rebuild switch --flake .#myserver
```

### Floating tag (e.g. `myapp:latest`)

The image tag in the config hasn't changed, so nixos-rebuild won't pull a new image automatically. Pull it manually first on the **server**, then restart the service:

```bash
docker pull myorg/myapp:latest
systemctl restart arion-myapp.service
```

> Pinned tags are recommended for reproducibility — `latest` can change unexpectedly and makes rollbacks harder.

---

## Operational Commands

All arion projects run as systemd services named `arion-<project-name>.service`.

### Checking status

```bash
# Service-level status
systemctl status arion-budgeteur.service

# Container-level status
docker ps
```

### Viewing logs

```bash
# Via systemd (all container output)
journalctl -u arion-budgeteur.service -f

# Via docker (per container)
docker logs budgeteur-rs-web-1 -f
```

### Starting and stopping

```bash
# Stop a project
systemctl stop arion-budgeteur.service

# Start a project
systemctl start arion-budgeteur.service

# Restart a project
systemctl restart arion-budgeteur.service
```

### Restarting all projects

```bash
systemctl restart 'arion-*.service'
```
