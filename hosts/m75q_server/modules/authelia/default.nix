{ config, ... }:

{
  # SOPS secrets for Authelia
  sops.secrets.authelia-jwt = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_JWT_SECRET";
    owner = "authelia-main";
  };

  sops.secrets.authelia-session = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_SESSION_SECRET";
    owner = "authelia-main";
  };

  sops.secrets.authelia-storage-key = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_STORAGE_ENCRYPTION_KEY";
    owner = "authelia-main";
  };

  sops.secrets.authelia-oidc-private-key = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_OIDC_PRIVATE_KEY";
    owner = "authelia-main";
  };

  sops.secrets.authelia-oidc-hmac = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_OIDC_HMAC_SECRET";
    owner = "authelia-main";
  };

  sops.secrets.authelia-user-anthonyd-hash = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "AUTHELIA_USER_ANTHONYD_HASH";
    owner = "authelia-main";
  };

  # Generate fles with secrets at activation time so the secrets never land in the Nix store
  sops.templates."authelia-oidc-hmac" = {
    owner = "authelia-main";
    path = "/var/lib/authelia-main/oidc-hmac";
    content = config.sops.placeholder.authelia-oidc-hmac;
  };

  sops.templates."authelia-oidc-private-key.pem" = {
    owner = "authelia-main";
    path = "/var/lib/authelia-main/oidc-private.pem";
    content = config.sops.placeholder.authelia-oidc-private-key;
  };

  sops.templates."authelia-users.yml" = {
    owner = "authelia-main";
    path = "/var/lib/authelia-main/users.yml";
    content = ''
      users:
        anthonyd:
          displayname: "Anthony Dickson"
          password: "${config.sops.placeholder.authelia-user-anthonyd-hash}"
          email: anthony.dickson9656@gmail.com
          groups:
            - admins
    '';
  };

  # Backup — SQLite dump
  services.backup.paths = [{
    name = "authelia";
    source = "/var/lib/authelia-main/db.sqlite3";
    method = "sqlite-dump";
  }];

  # Authelia forward-auth snippet — used by Caddy virtual hosts
  services.caddy.extraConfig = ''
    (authelia) {
      forward_auth localhost:9091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
    }
  '';

  # Authelia portal — not guarded by forward-auth
  services.caddy.virtualHosts."auth.s.anthonyd.co.nz" = {
    extraConfig = ''
      reverse_proxy localhost:9091
    '';
  };

  # Authelia service
  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets.authelia-jwt.path;
      sessionSecretFile = config.sops.secrets.authelia-session.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia-storage-key.path;
      oidcIssuerPrivateKeyFile = "/var/lib/authelia-main/oidc-private.pem";
      oidcHmacSecretFile = "/var/lib/authelia-main/oidc-hmac";
    };

    settings = {
      theme = "dark";

      authentication_backend.file = {
        path = "/var/lib/authelia-main/users.yml";
        watch = true;
      };

      session = {
        name = "authelia_session";
        expiration = "1h";
        inactivity = "5m";
        cookies = [{
          domain = "s.anthonyd.co.nz";
          authelia_url = "https://auth.s.anthonyd.co.nz";
        }];
      };

      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      totp = {
        issuer = "anthonyd.co.nz";
        period = 30;
        skew = 1;
      };

      webauthn = {
        display_name = "Anthony's Server";
        attestation_conveyance_preference = "indirect";
        selection_criteria = {
          user_verification = "preferred";
        };
      };

      notifier.filesystem.filename =
        "/var/lib/authelia-main/notifications.txt";

      identity_providers.oidc = {
        clients = [
          {
            client_id = "elmish-todos";
            client_name = "Elmish Todos";
            # TODO: Regenerate the secret when adding the docker compose for Elmish Todos
            client_secret = "$pbkdf2-sha512$310000$bmyKd6d6FP9t/IbgDDyH2g$cjQoII37ystknXMpyKTRBy5rIaZLWiR1icGS7b/Vue3WJMyjrXLRLdekAIh7H2ZwzYTYCm09yc1uIsDZt.8eTQ";
            public = false;
            redirect_uris = [
              "http://localhost:5000/signin-oidc"
            ];
            scopes = [ "openid" "profile" "email" "offline_access" ];
            grant_types = [ "authorization_code" "refresh_token" ];
            response_types = [ "code" ];
            response_modes = [ "query" "form_post" ];
            authorization_policy = "one_factor";
            consent_mode = "implicit";
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };

      access_control = {
        default_policy = "deny";
        rules = [
          # Per-service access control rules are added by each service module.
          # Bypass rules come first, then catch-all two_factor rules.
        ];
      };
    };
  };
}
