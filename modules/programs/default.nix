{pkgs, ...}:
{
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
    cargo
    cmake # Build tools for CXX
    duf # better df with colours and nice formatting
    dust # better du with graph visualisation
    fd # better find
    ffmpeg # multimedia tool for handling audio, video and other multimedia
    fzf # Fuzzy finder for terminal, used in neovim
    gcc # CXX compiler
    gnumake # GNU Make
    go # golang
    gotools # extra tools for golang such as gopls, godoc
    golangci-lint # linter for golang
    httpie # better curl for testing http requests
    imagemagick # For image manipulation
    mermaid-cli # For neovim image preview
    nodejs_22 # node and npm for running and building applications in JavaScript
    ninja # Faster builds for CXX
    python3 # Python interpreter
    ripgrep # better grep, works recursively on folders and is fast
    scc # counts lines of code excluding comments and empty lines
    tealdeer # tldr in Rust, provides simple examples for commands
    tectonic # For rendering LaTeX math equations
    unzip # unarchive zip files
    wget # download files from the internet
  ];
}
