{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    hyprshot
  ];
}
