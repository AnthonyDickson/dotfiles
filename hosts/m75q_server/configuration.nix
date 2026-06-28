{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/core.nix
    ./modules/networking.nix
    ./modules/nfs-mounts.nix
    ./modules/dns.nix
    ./modules/tailscale.nix
    ./modules/docker.nix
    ./modules/caddy
    ./modules/authelia
    ./modules/backup.nix
    ./modules/budgeteur
    ./modules/homepage
    ./modules/jellyfin
  ];

  system.stateVersion = "26.05";
}
