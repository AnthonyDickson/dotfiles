# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../../modules/system/audio.nix
    ./../../modules/system/bootloader.nix
    ./../../modules/system/cachix.nix
    ./../../modules/system/calcure.nix
    ./../../modules/system/calculator.nix
    ./../../modules/system/display-manager.nix
    ./../../modules/system/docker.nix
    ./../../modules/system/firefox.nix
    ./../../modules/system/fish.nix
    ./../../modules/system/hyprland.nix
    ./../../modules/system/hyprlock.nix
    ./../../modules/system/hyprpicker.nix
    ./../../modules/system/hyprshot.nix
    ./../../modules/system/jaq.nix
    ./../../modules/system/keymap.nix
    ./../../modules/system/keyring.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/libreoffice.nix
    ./../../modules/system/image-viewer.nix
    ./../../modules/system/marksman.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/fonts.nix
    ./../../modules/system/nixd.nix
    ./../../modules/system/obsidian.nix
    ./../../modules/system/playerctl.nix
    ./../../modules/system/printing.nix
    ./../../modules/system/pyright.nix
    ./../../modules/system/samba.nix
    ./../../modules/system/stylix
    ./../../modules/system/tailscale.nix
    ./../../modules/system/thunderbird.nix
    ./../../modules/system/unfree.nix
    ./../../modules/system/user-accounts.nix
    ./../../modules/system/uv.nix
    ./../../modules/system/wayland-electron-fix.nix
    ./../../modules/system/wordbook.nix
    ./../../modules/system/xserver.nix
  ];

  users.defaultUserShell = pkgs.fish;
  
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Mainly for uv
  programs.nix-ld.enable = true;

  nix.optimise = {
    automatic = true;
    dates = [ "21:00" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
