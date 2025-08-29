# Dotfiles

This repo contains config for my NixOS desktop.
NixOS, Nix and Home Manager are used to manage the system and user environment.

## Installation (NixOS)

1. Clone git repo:

    ```shell
    nix-shell -p git neovim
    git clone https:://github.com/AnthonyDickson/dotfiles ~/.config/nix
    cd ~/.config/nix
    ```
1. Create a new host for your PC by copying over the default config:

    ```shell
    mkdir hosts/<host name>
    cp /etc/nixos/configuration.nix /etc/nixos/hardware-configuration.nix hosts/<host name>/
    ```
    and add a host in `flake.nix`.

1. Setup Cachix by adding the following to `hosts/<host name>/configuration.nix`:

    ```nix
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./../../modules/system/cachix.nix
    ];

    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];
    ```
    and rebuild the system:

    ```shell
    sudo nixos-rebuild switch --flake ~/.config/nix#<host name>
    ```

1. Copy over the config you want from existing hosts, ensuring to keep
    `system.stateVersion` in `configuration.nix` from the previous steps and
    rebuild the system:

    ```shell
    sudo nixos-rebuild switch --flake ~/.config/nix#<host name>
    ```

## Post-Installation Steps

- Log in to Tailscale:

    ```shell
    sudo tailscale login
    ```

- Enter NAS credentials:

    ```shell
    sudoedit /etc/nixos/smb-secrets
    ```
    
    and use the template:

    ```text
    username=username
    password=password
    ```

- Log in with GitHub:

    ```shell
    gh auth login
    ```

- Enable rime and mozc in Fcitx 5 Configuration for Chinese and Japanese IMEs. 
