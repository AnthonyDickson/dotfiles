{pkgs, ...}:
{
  home.packages = with pkgs; [
    kitty
  ];

  home.file = {
    ".config/kitty/kitty.conf".source = ./kitty.conf;
    ".config/current-theme.conf".source = ./current-theme.conf;
  };
}
