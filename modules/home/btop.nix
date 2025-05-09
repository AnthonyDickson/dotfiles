{pkgs, ...}:
{
  home.packages = with pkgs; [btop];
  catppuccin.btop.enable = true;
}
