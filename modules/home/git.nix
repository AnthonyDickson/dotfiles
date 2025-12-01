{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh # GitHub CLI for auth
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Anthony Dickson";
        email = "anthony.dickson9656@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.difftastic = {
    enable = true;
    git.diffToolMode = true;
  };
}
