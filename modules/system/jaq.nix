{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    jaq
  ];
}
