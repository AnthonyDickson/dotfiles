{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    libsForQt5.gwenview
  ];
}
