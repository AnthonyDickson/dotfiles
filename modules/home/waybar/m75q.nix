{
  imports = [
    ./default.nix
  ];

  programs.waybar.settings.mainBar.cpu.format = " {icon} {usage}%";
}
