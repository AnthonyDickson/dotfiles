{
  imports = [
    ./default.nix
  ];
  
  home.file = {
    ".config/starship.toml".source = ./starship.toml;
  };
}
