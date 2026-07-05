{ config, pkgs, ... }:
{
  sops.secrets.cloudflare_api_token = {
    sopsFile = ./secrets.env;
    owner = "caddy";
  };

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
    };

    globalConfig = ''
      email anthony.dickson9656@gmail.com

      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.secrets.cloudflare_api_token.path;
  };
}
