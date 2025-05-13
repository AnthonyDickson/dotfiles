{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    pyright
  ];
}
