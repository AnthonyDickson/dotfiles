{ secretPath, domain, port, sshPort, stateDir }:
{
  project.name = "forgejo";

  services.forgejo = {
    service = {
      image = "codeberg.org/forgejo/forgejo:16.0.5-rootless";
      # Fixed name so the admin CLI can be reached with `docker exec forgejo ...`
      container_name = "forgejo";

      ports = [
        "127.0.0.1:${toString port}:3000"
        "${toString sshPort}:2222"
      ];

      # Expected to define FORGEJO__security__SECRET_KEY,
      # FORGEJO__security__INTERNAL_TOKEN, FORGEJO__oauth2__JWT_SECRET and
      # OIDC_CLIENT_SECRET (only read by the one-off auth source setup command)
      env_file = [ secretPath ];

      # Written into app.ini by the image's environment-to-ini on every start
      environment = {
        FORGEJO__server__DOMAIN = domain;
        FORGEJO__server__ROOT_URL = "https://${domain}/";
        FORGEJO__server__SSH_DOMAIN = domain;
        FORGEJO__server__SSH_PORT = toString sshPort;
        FORGEJO__server__SSH_LISTEN_PORT = "2222";

        FORGEJO__database__DB_TYPE = "sqlite3";

        FORGEJO__security__INSTALL_LOCK = "true";
        # Caddy runs on the host; the container sees the Docker bridge gateway
        FORGEJO__security__REVERSE_PROXY_TRUSTED_PROXIES = "172.16.0.0/12";

        # Accounts are only created through Authelia (OIDC); no local sign-in
        FORGEJO__service__DISABLE_REGISTRATION = "false";
        FORGEJO__service__ALLOW_ONLY_EXTERNAL_REGISTRATION = "true";
        FORGEJO__service__SHOW_REGISTRATION_BUTTON = "false";
        FORGEJO__service__ENABLE_INTERNAL_SIGNIN = "false";
        FORGEJO__openid__ENABLE_OPENID_SIGNIN = "false";
        FORGEJO__openid__ENABLE_OPENID_SIGNUP = "false";
        FORGEJO__oauth2_client__ENABLE_AUTO_REGISTRATION = "true";
        FORGEJO__oauth2_client__USERNAME = "preferred_username";
        FORGEJO__oauth2_client__ACCOUNT_LINKING = "auto";

        FORGEJO__mailer__ENABLED = "false";
        FORGEJO__time__DEFAULT_UI_LOCATION = "Pacific/Auckland";
      };

      volumes = [
        "${stateDir}:/var/lib/gitea"
      ];

      healthcheck = {
        test = [ "CMD" "curl" "-fsS" "--max-time" "2" "http://localhost:3000/api/healthz" ];
        interval = "30s";
        timeout = "10s";
        retries = 5;
        start_period = "30s";
      };

      labels = {
        "homepage.group" = "Productivity";
        "homepage.name" = "Forgejo";
        "homepage.href" = "https://${domain}";
        "homepage.description" = "Git hosting";
        "homepage.icon" = "sh-forgejo";
      };

      restart = "unless-stopped";
    };

    out.service.deploy.resources.limits = {
      cpus = "2.0";
      memory = "1gb";
    };
  };
}
