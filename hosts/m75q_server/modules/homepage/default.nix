{ ... }:

let
  domain = "homepage.s.anthonyd.co.nz";
  port = 3000;
in
{
  imports = [
    ./homepage-config.nix
  ];

  services.homepage-config.enable = true;

  # Arion (docker-compose) project — uses host networking
  virtualisation.arion.projects.homepage.settings.imports = [
    (import ./arion-compose.nix { })
  ];

  # Caddy reverse proxy — protected by Authelia
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      import authelia
      reverse_proxy localhost:${toString port}
    '';
  };

  # Authelia access control: all pages require 2FA
  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = domain;
      policy = "two_factor";
    }
  ];
}
