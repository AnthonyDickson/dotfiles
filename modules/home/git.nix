{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Anthony Dickson";
      user.email = "git@anthonyd.co.nz";
      init.defaultBranch = "main";
      credential.helper = "!gh auth git-credential";
    };
  };
}
