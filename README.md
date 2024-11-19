# Dotfiles

This repo contains config files for various programs I use such as zsh, kitty, Neovim, and git.
I manage my dotfiles with [chezmoi](https://www.chezmoi.io/) which is required for you to use these files without modification.

Files in ./unmanaged_config are not directly managed by chezmoi. This allows progams to freely modify these files.
Use this folder for files such as lock files.

## Installation (macOS)

1. Install Nix if not installed already:

    ```shell
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinateI
    ```

2. Run `nix run nixpkgs#chezmoi -- init --apply AnthonyDickson/dotfiles` to run chezmoi and get the dotfiles from this repo.
    This will run chezmoi without installing it; the next step will ensure it is installed permanently.

3. Run nix to build the system and user environment:

    1. First time:

       ```shell
       nix run nix-darwin -- switch --flake ~/.config/nix#darwin
       ```

    2. After initial install:

       ```shell
       darwin-rebuild switch --flake ~/.config/nix#darwin
       ```

## Installation (NixOS)

1. Run `nix-shell -p chezmoi git --run "chezmoi init --apply AnthonyDickson/dotfiles"` to run chezmoi and get the dotfiles from this repo.

2. Build the system:

    ```shell
    sudo nix-rebuild switch --flake ~/.config/nix#nix
    ```

## Hacks

Normally, chezmoi will symlink files. This causes issues for nix which will not work on a symlinked flake.lock.
As a workaround, I instead use a script (`./run_onchange_after_hardlink_flake_lock.sh`) to create a hardlink for flake.lock.
This will run everytime you run `chezmoi apply` so there should not be any issues.

## Editing and Adding Files

To update/edit config files, you should use `chezmoi edit ./config/path/to/config.file`.
To add new config files, you should use `chezmoi add ./config/path/file.conf`.

If you edit or add nix flakes, you should rerun the rebuild step (step 3 for macOS and 2 for NixOS).
