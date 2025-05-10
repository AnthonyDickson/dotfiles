# home.nix

{ username, wallpaper_path, ... }:
{
  imports = [
    ./../../modules/home/programs/nixos.nix
    ./../../modules/home/starship
    ./../../modules/home/kitty/nixos.nix
    ./../../modules/home/nerd-fonts.nix
    ./../../modules/home/zoxide.nix
    ./../../modules/home/lsd.nix
    ./../../modules/home/bat
    ./../../modules/home/btop.nix
    ./../../modules/home/git.nix
    ./../../modules/home/git_credentials.nix
    ./../../modules/home/lazygit
    ./../../modules/home/helix.nix
    ./../../modules/home/ast-grep.nix
    ./../../modules/home/micromamba.nix
    ./../../modules/home/hyprland
    ./../../modules/home/fish.nix
    ./../../modules/home/stylix.nix
    ./../../modules/home/yazi.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
