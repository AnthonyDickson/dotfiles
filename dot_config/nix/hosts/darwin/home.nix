# home.nix

{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono
    chezmoi # For managing dotfiles
    neovim # vim but better
    git # version control
    gh # GitHub CLI for auth
    lazygit # awesome terminal UI for git
    difftastic # diffs based on syntax
    fzf # Fuzzy finder for terminal, used in neovim
    lsd # ls with colours and dev icons
    bat # cat with syntax highlighting
    scc # counts lines of code excluding comments and empty lines
    ripgrep # better grep, works recursively on folders and is fast
    ast-grep # grep that parses code
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    tealdeer # tldr in Rust, provides simple examples for commands
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    btop # better htop with nice UI
    httpie # better curl for testing http requests
    wget # download files from the internet
    
    cmake # Build tools for CXX
    ninja # Faster builds for CXX
    gnumake # GNU Make
    nodejs_22 # node and npm for running and building applications in JavaScript
    # Python interpreter
    (python3.withPackages (ps: with ps; [
      pip
      setuptools
    ]))
    go # golang
    gotools # extra tools for golang such as gopls, godoc
    golangci-lint # linter for golang
    rustup # Rust toolchain (rustc, cargo, rust-analyzer)
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/davish/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # The better Bash
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      l = "lsd";
      cm = "chezmoi";
      lg = "lazygit";
    };
    initExtra = ''
      # alt + left arrow
      bindkey "^[[1;3D" backward-word
      # alt + right arrow
      bindkey "^[[1;3C" forward-word
      # delete key
      bindkey "^[[3~" delete-char
      # alt + del
      bindkey "^[[3;3~" delete-word

      # Fix for OCS 52 key codes (remote copy and paste) in kitty terminal
      # when using ssh.
      [[ "$TERM"  == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

      # Set config home used by lazygit
      export XDG_CONFIG_HOME="$HOME/.config"

      export EDITOR="nvim"
    '';
  };
  
  # fancy prompts for terminal apps
  programs.starship = {
      enable = true;
      enableZshIntegration = true;
  };

  # smarter cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };


  catppuccin = {
    flavor = "mocha";
    bat.enable = true;
    btop.enable = true;
    lazygit.enable = true;
  };
}
