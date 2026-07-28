{ config, ... }:

let
  domain = "todos.s.anthonyd.co.nz";
  port = 8088;
  db_filename = "todos.sqlite3";
  docker_volume = "/var/lib/lustre_todos";
  client_id = "lustre-todos";
in
{
  sops.secrets.lustre-todos-env = {
    # Expected to define the env var Oidc__ClientSecret
    sopsFile = ./secrets.env;
  };

  virtualisation.arion.projects.lustre-todos.settings =  {
    project.name = "lustre-todos";

    services.web.service = {
      image = "ghcr.io/anthonydickson/lustre-todos:0.1.0";

      environment = {
        Login__ReturnUrl= "https://${domain}";
        Oidc__Authority= "https://auth.s.anthonyd.co.nz";
        Oidc__ClientId= client_id;
        Oidc__CallbackPath= "/signin-oidc";
        ConnectionStrings__Default= "Data Source=/data/${db_filename}";
      };

      ports = [ "${toString port}:5000" ];

      # Expected to define the env var Oidc__ClientSecret
      env_file = [ config.sops.secrets.lustre-todos-env.path ];

      volumes = [
        "${docker_volume}:/data"
      ];

      healthcheck = {
        test= ["CMD" "bash" "-c" "</dev/tcp/localhost/5000"];
        interval= "30s";
        timeout= "5s";
        retries= 3;
        start_period= "10s";
      };

      labels = {
        "homepage.group" = "Services";
        "homepage.name" = "Lustre Todos";
        "homepage.href" = "https://${domain}";
        "homepage.description" = "Lustre Todos";
        "homepage.icon" = "https://${domain}/favicon.svg";
      };

      restart = "unless-stopped";
    };
  };

  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  services.backup.paths = [
    {
      name = "lustre_todos";
      source = "${docker_volume}/${db_filename}";
      method = "sqlite-dump";
    }
  ];

  services.authelia.instances.main.settings = {
    access_control.rules = [
      {
        domain = domain;
        policy = "two_factor";
      }
    ];

    identity_providers.oidc.clients = [
      {
        client_id = client_id;
        client_name = "Lustre Todos";
        client_secret = "$pbkdf2-sha512$310000$sVnKpSs1VnNTqVWmW6y0RA$bikTV.tiqzCBjOkIk7OEArB6144ZpWG1zaFt2OoWo1ktwqGFFeF9s.iWxv1lODTD62kmCnIo/ETX18f3XkFOzg";
        public = false;
        redirect_uris = [
          "https://${domain}/signin-oidc"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
          "offline_access"
        ];
        grant_types = [
          "authorization_code"
          "refresh_token"
        ];
        response_types = [ "code" ];
        response_modes = [
          "query"
          "form_post"
        ];
        authorization_policy = "one_factor";
        consent_mode = "implicit";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
  };
}
