# home.nix

{ username, ... }:
{
  imports = [
    ./../modules/programs/nixos.nix
    ./../modules/starship
    ./../modules/kitty/nixos.nix
    ./../modules/nerd-fonts.nix
    ./../modules/zoxide.nix
    ./../modules/lsd.nix
    ./../modules/bat.nix
    ./../modules/btop.nix
    ./../modules/git.nix
    ./../modules/git_credentials.nix
    ./../modules/lazygit
    ./../modules/helix.nix
    ./../modules/ast-grep.nix
    ./../modules/micromamba.nix
    ./../modules/hyprland
    ./../modules/fish.nix
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
