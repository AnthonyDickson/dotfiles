{ ... }:

let
  domain = "kavita.s.anthonyd.co.nz";
  port = 5000;
in
{
  # State directories created at boot with correct ownership
  # (matches PUID / PGID in the container)
  systemd.tmpfiles.rules = [
    "d /var/lib/kavita/config 0750 1000 100 -"
    "d /var/lib/kavita/data 0750 1000 100 -"
  ];

  # Arion (docker-compose) project
  virtualisation.arion.projects.kavita.settings.imports = [
    (import ./arion-compose.nix { })
  ];

  # Caddy reverse proxy — no auth guard (Kavita handles its own, and OPDS
  # readers and mobile apps cannot follow Authelia's login redirect)
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # Backup — SQLite database, config (covers, bookmarks, themes) and the
  # library itself. The copy-dir of the config also picks up a live copy of
  # the database, which the dump makes redundant.
  services.backup.paths = [
    {
      name = "kavita/db";
      source = "/var/lib/kavita/config/kavita.db";
      method = "sqlite-dump";
    }
    {
      name = "kavita/config";
      source = "/var/lib/kavita/config";
      method = "copy-dir";
    }
    {
      name = "kavita/data";
      source = "/var/lib/kavita/data";
      method = "copy-dir";
    }
  ];
}
