# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, username, inputs, ... }:

{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.enableSudoTouchIdAuth = true;

  users.users.${username}.home = "/Users/${username}";
  home-manager.backupFileExtension = "backup";
  nix.configureBuildUsers = true;
  nix.useDaemon = true;

  system.defaults = {
    dock = {
      autohide = false;
      # Groups apps by app in mission control
      expose-group-by-app = true;
    };
    finder.AppleShowAllExtensions = true;
    ## Enable cmd + ctrl to drag a window by clicking anywhere on it.
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  };
  
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    casks = [
      # Tiling window manager
      "aerospace"
      "kitty"
    ];
    brews = [
      # Window borders
      "borders"
    ];
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
    onActivation.cleanup = "zap";
  };
}
