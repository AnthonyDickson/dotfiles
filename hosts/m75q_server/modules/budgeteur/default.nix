{ config, ... }:

let
  domain = "budgeteur.s.anthonyd.co.nz";
  port = 8080;
in
{
  # SOPS secret — decrypted at runtime, never in Nix store
  sops.secrets.budgeteur-env = {
    sopsFile = ./secrets.env;
  };

  # Arion (docker-compose) project
  virtualisation.arion.projects.budgeteur.settings.imports = [
    (import ./arion-compose.nix {
      secretPath = config.sops.secrets.budgeteur-env.path;
    })
  ];

  # Caddy reverse proxy — protected by Authelia
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      import authelia
      reverse_proxy localhost:${toString port}
    '';
  };

  # Backup — SQLite dump
  services.backup.paths = [{
    name = "budgeteur";
    source = "/var/lib/budgeteur/budgeteur.db";
    method = "sqlite-dump";
  }];

  # Authelia access control: API paths bypass auth, everything else uses 2FA
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
}
