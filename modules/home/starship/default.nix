{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  home.file = {
    ".config/starship.toml".source = ./starship.toml;
  };
}
