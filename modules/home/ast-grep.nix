{pkgs, ...}:
{
  home.packages = with pkgs; [
    ast-grep # grep that parses code
  ];

  programs.zsh = {
    shellAliases = {
      sg = "ast-grep";
    };
  };
}
