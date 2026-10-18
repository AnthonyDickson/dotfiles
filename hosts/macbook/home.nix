{ pkgs, username, ... }:
{
  imports = [
    ./../../modules/home/difftastic.nix
    ./../../modules/home/fish.nix
    ./../../modules/home/ghostty.nix
    ./../../modules/home/git.nix
    ./../../modules/home/helix.nix
    ./../../modules/home/nerd-fonts.nix
    ./../../modules/home/starship.nix
    ./../../modules/home/stylix.nix
    ./../../modules/home/yazi.nix
    ./../../modules/home/zellij.nix
    ./../../modules/home/zoxide.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Same scheme as modules/system/stylix on NixOS.
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    # Use Ghostty's default font like on NixOS, which has ligatures.
    targets.ghostty.fonts.enable = false;
  };

  programs = {
    bat.enable = true;
    btop.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    lazygit.enable = true;

    fish = {
      # Installed system-wide on NixOS by modules/system/fish.nix.
      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      # Nix's PATH setup lives in /etc/zshrc, which fish doesn't read.
      loginShellInit = ''
        fish_add_path --prepend --move /nix/var/nix/profiles/default/bin $HOME/.nix-profile/bin
      '';
    };

    ghostty = {
      # nixpkgs only ships the prebuilt binary on macOS.
      package = pkgs.ghostty-bin;
      settings = {
        # Start fish from Ghostty so the login shell stays zsh.
        command = "${pkgs.fish}/bin/fish --login";
        macos-option-as-alt = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "server" = {
          hostname = "192.168.0.20";
          port = 22;
          user = "anthonyd";
          identityFile = "~/.ssh/nixos_server";
          identitiesOnly = true;
        };
        "dsm.anthonyd.co.nz" = {
          port = 22;
          user = "anthony";
          identityFile = "~/.ssh/dsm";
          identitiesOnly = true;
        };
      };
    };
  };

  # Cross-platform CLI tools from hosts/m75q/configuration.nix.
  home.packages = with pkgs; [
    ast-grep # Structural grep for code
    cmake # Build tools for CXX
    crush # CLI tool for LLM-assisted coding
    dprint # Code formatter, used for markdown
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    fzf # Fuzzy finder for terminal
    gh # GitHub CLI for auth
    httpie # better curl for testing http requests
    hyperfine # Tool for benchmarking run time of CLI commands
    imagemagick # For image manipulation
    jaq # CLI tool for parsing JSON
    localsend # Cross-platform peer-to-peer file sharing
    lsd # ls but nicer
    marksman # Markdown LSP + wiki style links
    nixd # nix LSP
    nixfmt # Formatter for .nix files
    nodejs_22 # node and npm for running and building applications in JavaScript
    ripgrep # better grep, works recursively on folders and is fast
    scooter # interactive find and replace TUI
    tealdeer # tldr in Rust, provides simple examples for commands
    tokei # Count lines of code
    unzip # unarchive zip files
    uv # Python package manager
    wget # download files from the internet
    zip # archive zip files
  ];
}
