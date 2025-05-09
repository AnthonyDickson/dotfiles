{pkgs, ...}:
{
  home.packages = with pkgs; [
    gh # GitHub CLI for auth
  ];

  programs.git = {
    enable = true;
    userName = "Anthony Dickson";
    userEmail = "anthony.dickson9656@gmail.com";
    difftastic = {
      enable = true;
      enableAsDifftool = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
