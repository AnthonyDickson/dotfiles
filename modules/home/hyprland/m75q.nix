{
  imports = [
    ./default.nix
  ];

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "desc:Acer Technologies XB273K GP 0x0511FB48, 3840x2160@60, 0x0, 1.5"
        "desc:AOC Q27G2G4 0x0000175D, 2560x1440@60, auto-left, 1.0, transform, 3"
      ];
    };
  };
}
