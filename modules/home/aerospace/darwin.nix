{
  # Assumes that aerospace is installed via homebrew in configuration.nix
  home.file = {
    ".aerospace.toml".source = ./aerospace.toml;
  };
}
