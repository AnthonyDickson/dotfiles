{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  # Keep old generations from filling the ESP
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
}
