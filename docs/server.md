# Server Setup

NixOS server configuration for containerised applications using Arion and sops-nix.

## Installation

1. Clone the repo:

   ```shell
   nix-shell -p git helix
   git clone https://github.com/AnthonyDickson/dotfiles ~/.config/nix
   cd ~/.config/nix
   ```

1. Create a new host by copying over the default config:

   ```shell
   mkdir hosts/<host name>
   cp /etc/nixos/configuration.nix /etc/nixos/hardware-configuration.nix hosts/<host name>/
   ```
   and add a host entry in `flake.nix`.

1. Copy over the config you want from existing hosts, ensuring to keep
   `system.stateVersion` in `configuration.nix` from the previous steps.

1. Update the `openssh.authorizedKeys.keys` field with any public keys you want
   to use for remote access.

1. Rebuild the system:

   ```shell
   sudo nixos-rebuild switch --flake ~/.config/nix#<host name>
   ```

## Post-Installation

- Log in to Tailscale:

  ```shell
  sudo tailscale login
  ```

- Generate and register a [GitHub deploy key](https://github.com/AnthonyDickson/dotfiles/settings/keys/new) for the config repo.
  Change the upstream URL to `git@github.com:AnthonyDickson/dotfiles.git`

## Related Docs

- [Secret Management](./secrets.md) — managing encrypted secrets for containerised apps
- [Docker Operations](./docker.md) — managing containerised applications
- [Authelia](./authelia.md) — authentication, MFA enrollment, and user management
