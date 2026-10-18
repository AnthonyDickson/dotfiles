{ config, ... }:

let
  domain = "vikunja.s.anthonyd.co.nz";
  port = 3456;
  stateDir = "/var/lib/vikunja";
  client_id = "vikunja";
  image_tag = "2.7.0";
in
{
  sops.secrets.vikunja-env = {
    # Expected to define VIKUNJA_SERVICE_SECRET and
    # VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_CLIENTSECRET
    sopsFile = ./secrets.env;
  };

  # Needed for the bind mounts to work for the image's non-root user
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 1000 1000 -"
    "d ${stateDir}/db 0750 1000 1000 -"
    "d ${stateDir}/files 0750 1000 1000 -"
  ];

  virtualisation.arion.projects.vikunja.settings = {
    project.name = "vikunja";

    services.web = {
      service = {
        image = "vikunja/vikunja:${image_tag}";

        environment = {
          VIKUNJA_SERVICE_PUBLICURL = "https://${domain}/";
          VIKUNJA_SERVICE_TIMEZONE = "Pacific/Auckland";
          VIKUNJA_SERVICE_ENABLEREGISTRATION = "false";

          VIKUNJA_DATABASE_TYPE = "sqlite";
          VIKUNJA_DATABASE_PATH = "/db/vikunja.db";

          # Accounts are only created through Authelia (OIDC); no local sign-in
          VIKUNJA_AUTH_LOCAL_ENABLED = "false";
          VIKUNJA_AUTH_OPENID_ENABLED = "true";
          VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_NAME = "Authelia";
          VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_AUTHURL = "https://auth.s.anthonyd.co.nz";
          VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_CLIENTID = client_id;

          VIKUNJA_MAILER_ENABLED = "false";
        };

        ports = [ "${toString port}:3456" ];

        # Expected to define VIKUNJA_SERVICE_SECRET and
        # VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_CLIENTSECRET
        env_file = [ config.sops.secrets.vikunja-env.path ];

        volumes = [
          "${stateDir}/db:/db"
          "${stateDir}/files:/app/vikunja/files"
        ];

        # The image has no shell or HTTP client, only the Vikunja binary
        healthcheck = {
          test = [ "CMD" "/app/vikunja/vikunja" "healthcheck" ];
          interval = "30s";
          timeout = "5s";
          retries = 3;
          start_period = "10s";
        };

        labels = {
          "homepage.group" = "Productivity";
          "homepage.name" = "Vikunja";
          "homepage.href" = "https://${domain}";
          "homepage.description" = "Task management";
          "homepage.icon" = "sh-vikunja";
        };

        restart = "unless-stopped";
      };

      out.service.deploy.resources.limits = {
        cpus = "1.0";
        memory = "512mb";
      };
    };
  };

  # Vikunja signs users in through Authelia's OIDC itself, and the API and
  # CalDAV are token-based, so Caddy does not put forward auth in front of it.
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # Backup — SQLite database and task attachments
  services.backup.paths = [
    {
      name = "vikunja/db";
      source = "${stateDir}/db/vikunja.db";
      method = "sqlite-dump";
    }
    {
      name = "vikunja/files";
      source = "${stateDir}/files";
      method = "copy-dir";
    }
  ];

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
        client_name = "Vikunja";
        # PBKDF2 digest of VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHELIA_CLIENTSECRET
        # in secrets.env, from `authelia crypto hash generate pbkdf2`
        client_secret = "$pbkdf2-sha512$310000$y6gkEQ5vwBxv4W/MT249Yw$.2fzYi40GK9Z.vsfcPjpwKMd/tBM3FnFVPobIs5JXgRI2rf9skES.WfuukQsSCSZj7aHyiQVZKg.8/pQATr29w";
        public = false;
        # The last path segment is the provider key in the AUTHELIA env vars
        redirect_uris = [
          "https://${domain}/auth/openid/authelia"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
        ];
        grant_types = [ "authorization_code" ];
        response_types = [ "code" ];
        authorization_policy = "two_factor";
        consent_mode = "implicit";
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };
}
