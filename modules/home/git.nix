{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Anthony Dickson";
      user.email = "anthony.dickson9656@gmail.com";
      init.defaultBranch = "main";
      credential.helper = "!gh auth git-credential";
    };
  };
}
