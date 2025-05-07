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
    git clone https:://github.com/AnthonyDickson/dotfiles ~/.config/nix
    ```

1. Build the system:

    ```shell
    sudo nixos-rebuild switch --flake ~/.config/nix#nix
    ```

## Installation (Lenovo M93p Tiny Server)

1. Clone git repo:

    ```shell
    git clone https:://github.com/AnthonyDickson/dotfiles ~/.config/nix
    ```

2. Build the system:

    ```shell
    sudo nixos-rebuild switch --flake ~/.config/nix#m93p
    ```

## TODO

- Add home-manager to NixOS server, try to make it as similar as NixOS as possible
- Add cloudflare config to modules/
