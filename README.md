# Dotfiles
This repo contains config files for various programs I use such as zsh, kitty, LunarVim, and git.
I manage my dotfiles with [chezmoi](https://www.chezmoi.io/) which is required for you to use these files without modification.

## Installation
1.  Install Nix if not installed already: 
    ```shell
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinateI
    ```
2.  Run `nix run nixpkgs#chezmoi -- init --apply AnthonyDickson/dotfiles` to run chezmoi and get the dotfiles from this repo.
3.  Run nix to build the system and user environment:
    1. MacOS (first time):
        ```shell
        nix run nix-darwin -- switch --flake ~/.config/nix
        ```

        After initial install:
        ```shell
        darwin-rebuild switch --flake ~/.config/nix
        ```

## Editing and Adding Files
To update/edit config files, you should use `chezmoi edit ./config/path/to/config.file`.
To add new config files, you should use `chezmoi add ./config/path/file.conf`.

If you edit or add nix flakes, you should rerun step 3.
