{ username, ... }:
{
  imports = [
    ./../../modules/home/fish.nix
    ./../../modules/home/git_credentials.nix
    ./../../modules/home/git.nix
    ./../../modules/home/helix.nix
    ./../../modules/home/hypridle.nix
    ./../../modules/home/hyprland/m75q.nix
    ./../../modules/home/hyprlock.nix
    ./../../modules/home/kitty.nix
    ./../../modules/home/ruff.nix
    ./../../modules/home/starship.nix
    ./../../modules/home/stylix.nix
    # TODO: Re-enable Walker once nix.flake is added back
    # ./../../modules/home/walker.nix
    ./../../modules/home/waybar/m75q.nix
    ./../../modules/home/yazi.nix
    ./../../modules/home/zellij.nix
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
  home.stateVersion = "25.05"; # Please read the comment before changing.

  programs = {
    bat.enable = true;
    btop.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    lazygit.enable = true;
    ncspot.enable = true;
  };

  services = {
    dunst.enable = true;
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
  };
}
