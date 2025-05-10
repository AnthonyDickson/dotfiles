{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    hyprcursor
  ];
}
