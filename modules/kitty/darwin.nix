{
  # Assumes kitty is installed via homebrew in configuration.nix

  home.file = {
    ".config/kitty/kitty.conf".source = ./kitty.conf;
    ".config/current-theme.conf".source = ./current-theme.conf;
  };
}
