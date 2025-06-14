# Dotfiles

This repo contains config for my macOS MacBook, NixOS desktop and NixOS server.
NixOS/Nix Darwin, Nix and Home Manager are used to manage the system and user environment.

## Installation (macOS)

1. Install Nix if not installed already:

    ```shell
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinateI
    ```

1. Clone git repo:

    ```shell
    git clone https:://github.com/AnthonyDickson/dotfiles ~/.config/nix
    ```

1. Run nix to build the system and user environment:

    1. First time:

       ```shell
       nix run nix-darwin -- switch --flake ~/.config/nix#darwin
       ```

    2. After initial install:

       ```shell
       darwin-rebuild switch --flake ~/.config/nix#darwin
       ```

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
