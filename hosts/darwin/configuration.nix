# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, username, ... }:

{
  # Needed for Nix installed via Determinate installer.
  nix.enable = false;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ast-grep # Structural grep for code
    bat # cat but better
    btop # htop but better
    dprint # Code formatter, used for markdown
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    fzf # Fuzzy finder for terminal
    gh # GitHub CLI for auth
    httpie # better curl for testing http requests
    hyperfine # Tool for benchmarking run time of CLI commands
    jaq # CLI tool for parsing JSON
    lsd # ls but nicer
    marksman # Markdown LSP + wiki style links
    nixd # nix LSP
    nixfmt-rfc-style # Formatter for .nix files
    ripgrep # better grep, works recursively on folders and is fast
    tealdeer # tldr in Rust, provides simple examples for commands
    tokei # Count lines of code
    typst # Better LaTex
    tinymist # LSP for Typst
    unzip # unarchive zip files
    uv # Python package manager
    wget # download files from the internet
  ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${username}.home = "/Users/${username}";
  home-manager.backupFileExtension = "backup";

  system = {
    primaryUser = "${username}";
  };
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
