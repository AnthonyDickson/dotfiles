# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../../modules/system/audio.nix
    ./../../modules/system/bootloader.nix
    ./../../modules/system/cachix.nix
    ./../../modules/system/display-manager.nix
    ./../../modules/system/docker.nix
    ./../../modules/system/fish.nix
    ./../../modules/system/hyprland.nix
    ./../../modules/system/hyprlock.nix
    ./../../modules/system/keymap.nix
    ./../../modules/system/keyring.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/libreoffice.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/fonts.nix
    ./../../modules/system/samba.nix
    ./../../modules/system/stylix
    ./../../modules/system/unfree.nix
    ./../../modules/system/user-accounts.nix
    ./../../modules/system/wayland-electron-fix.nix
  ];

  users.defaultUserShell = pkgs.fish;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    optimise = {
      automatic = true;
      dates = [ "21:00" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    ast-grep # Structural grep for code
    claude-code # 🤖
    cmake # Build tools for CXX
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    fzf # Fuzzy finder for terminal
    httpie # better curl for testing http requests
    hyprcursor # Custom cursors in Hyprland
    hyprpicker # Color picker
    hyprshot # Screenshoter
    imagemagick # For image manipulation
    jaq # CLI tool for parsing JSON
    libsForQt5.gwenview # Image viewew
    lsd # ls but nicer
    marksman # Markdown LSP + wiki style links
    nixd # nix LSP
    nixfmt-rfc-style # Formatter for .nix files
    nodejs_22 # node and npm for running and building applications in JavaScript
    obsidian # Note taking
    playerctl # CLI tool for controlling media playback
    pyright # Python LSP
    qalculate-qt # Full-featured calculator
    ripgrep # better grep, works recursively on folders and is fast
    tealdeer # tldr in Rust, provides simple examples for commands
    tokei # Count lines of code
    unzip # unarchive zip files
    uv # Python package manager
    wget # download files from the internet
    wl-clipboard # clipboard provider for neovim
    wordbook # Dictionary
  ];

  programs = {
    firefox.enable = true;
    nix-ld.enable = true; # Mainly for uv
    thunderbird.enable = true;
  };

  services = {
    printing.enable = true;
    tailscale.enable = true;
  };
}
