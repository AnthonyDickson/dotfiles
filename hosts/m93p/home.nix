# home.nix

{ username, ... }:
{
  imports = [
    ./../../modules/home/ast-grep.nix
    ./../../modules/home/bat
    ./../../modules/home/btop.nix
    ./../../modules/home/calcure
    ./../../modules/home/dunst.nix
    ./../../modules/home/fish.nix
    ./../../modules/home/git.nix
    ./../../modules/home/git_credentials.nix
    ./../../modules/home/helix.nix
    ./../../modules/home/hypridle.nix
    ./../../modules/home/hyprland.nix
    ./../../modules/home/hyprlock.nix
    ./../../modules/home/hyprpaper.nix
    ./../../modules/home/hyprpolkit.nix
    ./../../modules/home/kitty/nixos.nix
    ./../../modules/home/lazygit
    ./../../modules/home/lsd.nix
    ./../../modules/home/micromamba.nix
    ./../../modules/home/nerd-fonts.nix
    ./../../modules/home/ncspot.nix
    ./../../modules/home/obsidian.nix
    ./../../modules/home/programs/nixos.nix
    ./../../modules/home/ruff.nix
    ./../../modules/home/starship
    ./../../modules/home/stylix.nix
    ./../../modules/home/walker.nix
    ./../../modules/home/waybar
    ./../../modules/home/yazi.nix
    ./../../modules/home/zoxide.nix
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
