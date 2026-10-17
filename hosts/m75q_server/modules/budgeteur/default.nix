{ config, ... }:

let
  domain = "budgeteur.s.anthonyd.co.nz";
  port = 8080;
  db_filename = "budgeteur.sqlite3";
  docker_volume = "/var/lib/budgeteur-fs";
  client_id = "budgeteur-fs";
  image_tag = "1.0.0-rc2";
  # PBKDF2 digest of the OIDC client secret, from
  # `authelia crypto hash generate pbkdf2 --random`. The plaintext goes in
  # secrets.env as Oidc__ClientSecret.
  client_secret_digest = "$pbkdf2-sha512$310000$SoAa8Yp20GArJgbgfO6PeQ$XcaL2YlF3lwJ03wi49q7srBWAEY17lA3tv0ITHjxekUeDUE0o./NkgJVRezpiCCm.yXqWbDzbjRrYTdNB9v4xA";
in
{
  # An invalid digest would stop Authelia, and with it every service's sign-in.
  assertions = [
    {
      assertion = client_secret_digest != "";
      message = "Set client_secret_digest in modules/budgeteur/default.nix";
    }
  ];

  sops.secrets.budgeteur-env = {
    # Expected to define the env var Oidc__ClientSecret
    sopsFile = ./secrets.env;
  };

  # Needed for the bind mount to work for the image's non-root user
  systemd.tmpfiles.rules = [
    "d ${docker_volume} 0750 1654 1654 -"
  ];

  virtualisation.arion.projects.budgeteur.settings = {
    project.name = "budgeteur-fs";

    services.web = {
      service = {
        image = "ghcr.io/anthonydickson/budgeteur-fs:${image_tag}";

        environment = {
          Login__ReturnUrl = "https://${domain}/";
          Oidc__Authority = "https://auth.s.anthonyd.co.nz";
          Oidc__ClientId = client_id;
          Oidc__CallbackPath = "/signin-oidc";
          # Authelia does not support RP-initiated logout; its logout page ends
          # the provider session, then follows rd back to the signed out page.
          Oidc__LogoutUrl = "https://auth.s.anthonyd.co.nz/logout?rd=https://${domain}/signed-out";
          ConnectionStrings__Default = "Data Source=/data/${db_filename}";
          Logging__FilePath = "/data/logs/app.log";
          DataProtection__KeysPath = "/data/keys";
        };

        ports = [ "${toString port}:5000" ];

        # Expected to define the env var Oidc__ClientSecret
        env_file = [ config.sops.secrets.budgeteur-env.path ];

        volumes = [
          "${docker_volume}:/data"
        ];

        # BusyBox wget; 127.0.0.1 because the server listens on IPv4 only and
        # BusyBox wget tries ::1 for localhost without falling back.
        healthcheck = {
          test = [ "CMD" "wget" "-q" "-O" "/dev/null" "http://127.0.0.1:5000/api/status" ];
          interval = "30s";
          timeout = "5s";
          retries = 3;
          start_period = "10s";
        };

        labels = {
          "homepage.group" = "Services";
          "homepage.name" = "Budgeteur";
          "homepage.href" = "https://${domain}";
          "homepage.description" = "Personal budgeting app";
          "homepage.icon" = "https://${domain}/favicon-128x128.png";
        };

        restart = "unless-stopped";
      };

      out.service.deploy.resources.limits = {
        cpus = "1.0";
        memory = "256mb";
      };
    };
  };

  # The app signs users in through Authelia's OIDC itself, so Caddy does not
  # put Authelia's forward auth in front of it.
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  services.backup.paths = [
    {
      name = "budgeteur-fs";
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

    # No offline_access or refresh_token: the app's session is a cookie and an
    # expired one signs in again, and requesting offline_access makes Authelia
    # ask for consent on every sign-in.
    identity_providers.oidc.clients = [
      {
        client_id = client_id;
        client_name = "Budgeteur";
        client_secret = client_secret_digest;
        public = false;
        redirect_uris = [
          "https://${domain}/signin-oidc"
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
        authorization_policy = "two_factor";
        consent_mode = "implicit";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
  };
}
