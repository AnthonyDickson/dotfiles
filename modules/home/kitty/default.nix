{
  # Assumes kitty is installed via homebrew in configuration.nix

  home.file = {
    ".config/kitty/kitty.conf".source = ./kitty.conf;
    ".config/kitty/current-theme.conf".source = ./current-theme.conf;
  };
}
