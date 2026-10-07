{ config, ... }:

let
  domain = "paperless.s.anthonyd.co.nz";
  port = 8777;
in
{
  # State directories created at boot with correct ownership
  # (matches USERMAP_UID / USERMAP_GID in the container)
  systemd.tmpfiles.rules = [
    "d /var/lib/paperless/data 0750 1000 100 -"
    "d /var/lib/paperless/media 0750 1000 100 -"
    "d /var/lib/paperless/export 0750 1000 100 -"
    "d /var/lib/paperless/consume 0750 1000 100 -"
    "d /var/lib/paperless/redis 0750 root root -"
  ];

  # Expected to define PAPERLESS_ADMIN_PASSWORD and PAPERLESS_SECRET_KEY
  sops.secrets.paperless-env = {
    sopsFile = ./secrets.env;
  };

  # Arion (docker-compose) project
  virtualisation.arion.projects.paperless.settings.imports = [
    (import ./arion-compose.nix {
      secretPath = config.sops.secrets.paperless-env.path;
    })
  ];

  # Caddy reverse proxy — protected by Authelia
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      import authelia
      reverse_proxy localhost:${toString port}
    '';
  };

  # Authelia access control: API paths bypass auth so token-based clients
  # (e.g. the QuickScan mobile app) can reach Paperless directly, everything
  # else uses 2FA
  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = domain;
      policy = "bypass";
      resources = [ "^/api.*$" ];
    }
    {
      domain = domain;
      policy = "two_factor";
    }
  ];

  # Backup — documents (media) and the SQLite database (data)
  services.backup.paths = [
    {
      name = "paperless-media";
      source = "/var/lib/paperless/media";
      method = "copy-dir";
    }
    {
      name = "paperless-data";
      source = "/var/lib/paperless/data/db.sqlite3";
      method = "sqlite-dump";
    }
  ];
}
