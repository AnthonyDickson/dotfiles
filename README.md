# Dotfiles
This repo contains config files for various programs I use such as zsh, kitty, LunarVim, and git.
I manage my dotfiles with [chezmoi](https://www.chezmoi.io/) which is required for you to use these files without modification.
## Installation
1. Install git and neovim. Neovim is set as the editor for chezmoi, so you will need this to edit dot files.
2. Run `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME` to install chezmoi and get the dotfiles from this repo.
