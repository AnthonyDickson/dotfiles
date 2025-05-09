{pkgs, ...}:
{
  home.packages = with pkgs; [
    lazygit # awesome terminal wrapper for git
  ];

  home.file = {
    ".config/lazygit/config.yml".source = ./config.yml;
  };

  programs.zsh = {
    shellAliases = {
      lg = "lazygit";
    };
  };

  catppuccin = {
    lazygit.enable = true;
  };
}
