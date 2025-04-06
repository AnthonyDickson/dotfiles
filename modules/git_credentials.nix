{
  programs.git = {
    extraConfig = {
      credential.helper = "!gh auth git-credential";
    };
  };
}
