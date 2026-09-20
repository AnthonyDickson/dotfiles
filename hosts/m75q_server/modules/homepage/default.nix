{ config, ... }:

let
  domain = "homepage.s.anthonyd.co.nz";
  port = 3000;
  client_id = "homepage";
in
{
  imports = [
    ./homepage-config.nix
  ];

  services.homepage-config.enable = true;

  # Expected to define HOMEPAGE_AUTH_SECRET and HOMEPAGE_OIDC_CLIENT_SECRET
  sops.secrets.homepage-env = {
    sopsFile = ./secrets.env;
  };

  # Arion (docker-compose) project: uses host networking
  virtualisation.arion.projects.homepage.settings.imports = [
    (import ./arion-compose.nix {
      secretPath = config.sops.secrets.homepage-env.path;
    })
  ];

  # Caddy reverse proxy: protected by Authelia
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      import authelia
      reverse_proxy localhost:${toString port}
    '';
  };

  # Authelia access control and OIDC client
  services.authelia.instances.main.settings = {
    # Explicit rule so the domain bypasses the default deny policy
    access_control.rules = [
      {
        domain = domain;
        policy = "two_factor";
      }
    ];

    identity_providers.oidc.clients = [
      {
        client_id = client_id;
        client_name = "Homepage";
        # PBKDF2 hash of the HOMEPAGE_OIDC_CLIENT_SECRET value; see docs/homepage.md
        client_secret = "$pbkdf2-sha512$310000$AWVaTJvvlNPHTOE4qVbp.w$qlpSV8piuvBQrwepiJl291IxO14uGQTLKEzZUelBR8wN3wmkR5Co7wNz34iNvUjpVKnmn7BDjc3/dFaEkksP4Q";
        public = false;
        redirect_uris = [
          "https://${domain}/api/auth/callback/homepage-oidc"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
        ];
        grant_types = [ "authorization_code" ];
        response_types = [ "code" ];
        response_modes = [
          "query"
          "form_post"
        ];
        authorization_policy = "one_factor";
        consent_mode = "implicit";
        require_pkce = true;
        pkce_challenge_method = "S256";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };
}
