{pkgs, ...}:
{
  imports = [
    ./default.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard # clipboard provider for neovim
  ];
}
