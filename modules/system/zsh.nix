{pkgs, ...}:
{
  # The better Bash
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;  
}
