{pkgs, ...}:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    fishPlugins.fzf-fish
    fzf
  ];
}
