{
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
