{pkgs, ...}:
{
  home.packages = with pkgs; [
    gh # GitHub CLI for auth
  ];

  programs.git = {
    extraConfig = {
      credential.helper = "!gh auth git-credential";
    };
  };
}
