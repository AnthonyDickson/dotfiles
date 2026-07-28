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
    ./modules/ntfy
    ./modules/budgeteur
    ./modules/homepage
    ./modules/lustre_todos
    ./modules/jellyfin
  ];

  system.stateVersion = "26.05";
}
