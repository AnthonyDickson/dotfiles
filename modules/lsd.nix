{pkgs, ...}:
{
  home.packages = with pkgs; [ lsd ];
  
  programs.zsh = {
    shellAliases = {
      l = "lsd";
    };
  };
}
