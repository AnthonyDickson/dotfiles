{ pkgs, ... }:
{
  # Cross-platform CLI tools.
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
