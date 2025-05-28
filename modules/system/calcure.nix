{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    calcure
  ];
}
