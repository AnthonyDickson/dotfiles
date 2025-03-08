# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, username, ... }:

{
  # Needed for Nix installed via Determinate installer.
  nix.enable = false;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${username}.home = "/Users/${username}";
  home-manager.backupFileExtension = "backup";

  system.defaults = {
    dock = {
      autohide = false;
      # Groups apps by app in mission control
      expose-group-apps = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      # Search current folder by default.
      FXDefaultSearchScope = "SCcf";
    };
    ## Enable cmd + ctrl to drag a window by clicking anywhere on it.
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;

    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # Do not create .DS_Store files on network drives and USB drives.
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
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
    taps = [
      "nikitabobko/tap"
    ];
    onActivation.cleanup = "zap";
  };

  services.jankyborders = {
    enable = true;
    width = 4.0;
    active_color = "0xffe1e3e4";
    inactive_color = "0xff494d64";
    hidpi = true;
  };
}
