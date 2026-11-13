# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, inputs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../../modules/system/audio.nix
    ./../../modules/system/bootloader.nix
    ./../../modules/system/docker.nix
    ./../../modules/system/fish.nix
    ./../../modules/system/keymap.nix
    ./../../modules/system/keyring.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/libreoffice.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/fonts.nix
    ./../../modules/system/stylix
    ./../../modules/system/unfree.nix
    ./../../modules/system/user-accounts.nix
    ./../../modules/system/wayland-electron-fix.nix
  ];

  users.defaultUserShell = pkgs.fish;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    optimise = {
      automatic = true;
      dates = [ "21:00" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    cifs-utils # For mounting NAS onto local file system
    feishin # Music Player
    obsidian # Note taking
    onlyoffice-desktopeditors # I can't believe it's not M*******t Office
    pinta # Simple image editing
    pcsx2
    qalculate-qt # Full-featured calculator
    qimgv # Image viewer
    sops # For managing secrets for my server
    spotify # 🎵
    synology-drive-client # Sync with Synology NAS
    wl-clipboard # clipboard provider for neovim
    wordbook # Dictionary
  ];

  programs = {
    firefox = {
      enable = true;
      preferences = {
        "widget.gtk.libadwaita-colors.enabled" = false;
      };
    };
    nix-ld.enable = true; # Mainly for uv
    ssh = {
      extraConfig = "
          Host dsm.anthonyd.co.nz
            Port 22
            User anthony
            IdentityFile ~/.ssh/nas

          Host server
            Hostname 192.168.0.20
            Port 22
            User anthonyd
            IdentityFile ~/.ssh/server
        ";
    };
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    thunderbird.enable = true;
  };

  services = {
    flatpak.enable = true;
    printing.enable = true;

    # Cosmic DE
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;

    tailscale = {
      enable = true;
      # Fixes bug in Tailscale DNS issues on wake
      extraSetFlags = [ "--accept-dns=false" ];
    };
  };

}
