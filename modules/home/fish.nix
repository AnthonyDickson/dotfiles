{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
     '';
    shellAbbrs = {
      l = "lsd";
      lg = "lazygit";
      sg = "ast-grep";
    };
  };
}
