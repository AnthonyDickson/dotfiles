{pkgs, ...}:
{
  imports = [
    ./default.nix
  ];

  home.packages = with pkgs; [
    kitty
  ];
}
