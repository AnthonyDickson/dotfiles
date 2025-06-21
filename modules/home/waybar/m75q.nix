{
  imports = [
    ./default.nix
  ];

  programs.waybar.settings.mainBar.cpu.format = "CPU {icon} {usage}%";
}
