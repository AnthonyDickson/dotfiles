let
  mainMonitor = "desc:Acer Technologies XB273K GP 0x0511FB48";
  secondaryMonitor = "desc:AOC Q27G2G4 0x0000175D";
in
{
  imports = [
    ./default.nix
  ];

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "${mainMonitor}, 3840x2160@60, 0x0, 1.5"
        "${secondaryMonitor}, 2560x1440@60, auto-left, 1.0, transform, 3"
      ];
      workspace = [
        "1, monitor:${mainMonitor}, persistent:true, deault:true"
        "2, monitor:${mainMonitor}, persistent:true"
        "3, monitor:${mainMonitor}, persistent:true"
        "4, monitor:${mainMonitor}, persistent:true"
        "5, monitor:${secondaryMonitor}, persistent:true, default:true"
        "6, monitor:${secondaryMonitor}, persistent:true"
        "7, monitor:${secondaryMonitor}, persistent:true"
        "8, monitor:${secondaryMonitor}, persistent:true"
      ];  
      bind = [
        "$mod, Z, workspace, 5"
        "$mod, X, workspace, 6"
        "$mod, C, workspace, 7"
        "$mod, D, workspace, 8"
        "$mod SHIFT, Z, movetoworkspace, 5"
        "$mod SHIFT, X, movetoworkspace, 6"
        "$mod SHIFT, C, movetoworkspace, 7"
        "$mod SHIFT, D, movetoworkspace, 8"
      ];
    };
  };
}
