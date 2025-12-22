{ username, ... }:
{
  imports = [
    ./../../modules/home/fish.nix
    ./../../modules/home/difftastic.nix
    ./../../modules/home/git.nix
    ./../../modules/home/helix.nix
    ./../../modules/home/kitty.nix
    ./../../modules/home/ruff.nix
    ./../../modules/home/starship.nix
    ./../../modules/home/stylix.nix
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
  home.stateVersion = "25.11"; # Please read the comment before changing.

  programs = {
    bat.enable = true;
    btop.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    lazygit.enable = true;
  };
}
