{mainMonitor, secondaryMonitor, ...}:
{
  imports = [
    ./default.nix
  ];

  programs.waybar.settings.mainBar = {
    "hyprland/workspaces" = {
      persistent-workspaces = {
        ${mainMonitor} = [1 2 3 4];
        ${secondaryMonitor} = [5 6 7 8];
      };
    };

    cpu.format = " {icon} {usage}%";
  };
}
