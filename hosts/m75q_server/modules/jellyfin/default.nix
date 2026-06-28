{ ... }:

let
  domain = "jellyfin.s.anthonyd.co.nz";
  port = 8096;
in
{
  # State directories created at boot with correct ownership
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/config 0755 1000 303 -"
    "d /var/lib/jellyfin/cache 0755 1000 303 -"
  ];

  # Arion (docker-compose) project
  virtualisation.arion.projects.jellyfin.settings.imports = [
    (import ./arion-compose.nix { })
  ];

  # Caddy reverse proxy — no auth guard (Jellyfin handles its own)
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # Backup — hardlink config directory contents
  services.backup.paths = [{
    name = "jellyfin";
    source = "/var/lib/jellyfin/config";
    method = "copy-dir";
  }];

  # Ensure Jellyfin only starts after the NFS media mount is available
  systemd.services.arion-jellyfin = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };
}
