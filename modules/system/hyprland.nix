{inputs, pkgs, ...}:
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # Hyprland uses wayland, so we can disable xserver
  services.xserver.enable = false;

  # Wayland compat for Qt https://wiki.hyprland.org/Useful-Utilities/Must-have/#qt-wayland-support
  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
  ];
}
