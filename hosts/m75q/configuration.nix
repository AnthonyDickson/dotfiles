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
    ./../../modules/system/docker.nix
    ./../../modules/system/fish.nix
    ./../../modules/system/keymap.nix
    ./../../modules/system/keyring.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/libreoffice.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/fonts.nix
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
  system.stateVersion = "25.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    anki # Flash cards
    ast-grep # Structural grep for code
    cifs-utils # For mounting NAS onto local file system
    claude-code # 🤖
    cmake # Build tools for CXX
    dprint # Code formatter, used for markdown
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    feishin # Music Player
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    fzf # Fuzzy finder for terminal
    gh # GitHub CLI for auth
    httpie # better curl for testing http requests
    hyperfine # Tool for benchmarking run time of CLI commands
    imagemagick # For image manipulation
    jaq # CLI tool for parsing JSON
    kdePackages.gwenview # Image viewer
    localsend # Cross-platform peer-to-peer file sharing
    lsd # ls but nicer
    marksman # Markdown LSP + wiki style links
    markdown-oxide # PKMS LSP
    nixd # nix LSP
    nixfmt # Formatter for .nix files
    nodejs_22 # node and npm for running and building applications in JavaScript
    obsidian # Note taking
    onlyoffice-desktopeditors # I can't believe it's not M*******t Office
    pyright # Python LSP
    qalculate-qt # Full-featured calculator
    ripgrep # better grep, works recursively on folders and is fast
    spotify # 🎵
    synology-drive-client # Sync with Synology NAS
    tealdeer # tldr in Rust, provides simple examples for commands
    tokei # Count lines of code
    typst # Better LaTex
    tinymist # LSP for Typst
    unzip # unarchive zip files
    uv # Python package manager
    wget # download files from the internet
    wl-clipboard # clipboard provider for neovim
    wordbook # Dictionary
  ];

  programs = {
    firefox = {
      enable = true;
      preferences = {
        "widget.gtk.libadwaita-colors.enabled" = false;
      };
    };
    nix-ld.enable = true; # Mainly for uv
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    thunderbird.enable = true;
  };

  services = {
    flatpak.enable = true;
    printing.enable = true;
    tailscale.enable = true;

    # Cosmic DE
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
  };

}
