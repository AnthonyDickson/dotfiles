# MacBook Setup

Standalone Home Manager configuration for macOS. It reuses the shared modules in
`modules/home` and the same `flake.lock` as the NixOS hosts. Everything outside
the user environment is kept close to macOS defaults and set up once by hand.

## Installation

1. Install Nix with the
   [Determinate installer](https://determinate.systems/nix-installer/).

1. Clone the repo:

   ```shell
   git clone https://github.com/AnthonyDickson/dotfiles ~/.config/nix
   cd ~/.config/nix
   ```

1. Build and activate the Home Manager configuration:

   ```shell
   nix build .#homeConfigurations."anthony@macbook".activationPackage
   HOME_MANAGER_BACKUP_EXT=pre-hm ./result/activate
   ```

1. Open Ghostty from `~/Applications/Home Manager Apps`. It starts fish, while
   the login shell stays zsh.

## Updating

```shell
git pull
home-manager switch --flake .#anthony@macbook
```

## One-time macOS Settings

Touch ID for sudo:

```shell
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
```

and uncomment the `auth sufficient pam_tid.so` line.

System defaults:

```shell
defaults write com.apple.dock autohide -bool true
# Group windows by app in Mission Control
defaults write com.apple.dock expose-group-apps -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Cmd + Ctrl to drag a window by clicking anywhere on it (needs a re-login)
defaults write NSGlobalDomain NSWindowShouldDragOnGesture -bool true
# Do not create .DS_Store files on network and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
killall Dock Finder
```
