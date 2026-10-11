{ config, ... }:

let
  domain = "git.s.anthonyd.co.nz";
  port = 3030;
  sshPort = 2222;
  stateDir = "/var/lib/forgejo";
  client_id = "forgejo";
in
{
  # State directory created at boot, owned by the rootless image's git user
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 1000 1000 -"
  ];

  # Expected to define FORGEJO__security__SECRET_KEY,
  # FORGEJO__security__INTERNAL_TOKEN, FORGEJO__oauth2__JWT_SECRET and
  # OIDC_CLIENT_SECRET
  sops.secrets.forgejo-env = {
    sopsFile = ./secrets.env;
  };

  # Arion (docker-compose) project
  virtualisation.arion.projects.forgejo.settings.imports = [
    (import ./arion-compose.nix {
      secretPath = config.sops.secrets.forgejo-env.path;
      inherit domain port sshPort stateDir;
    })
  ];

  # Git over SSH goes straight to Forgejo's built-in SSH server
  networking.firewall.allowedTCPPorts = [ sshPort ];

  # Caddy reverse proxy: no forward-auth so git over HTTPS and API tokens
  # keep working; Forgejo itself only allows sign-in through Authelia (OIDC)
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
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
        client_name = "Forgejo";
        # PBKDF2 hash of the OIDC_CLIENT_SECRET value; see docs/forgejo.md
        client_secret = "$pbkdf2-sha512$310000$/b/RT4CreiwQylEIHdJL5Q$FMas2qaoPnvEBptMUfOTw8ra4fBOgGVPS3s7m1P90OpgkRtfZachJ7guNCyOjuGY8bUPHsEdLZ2C8KjCxRvqNQ";
        public = false;
        # The path segment after /oauth2/ is the Forgejo auth source name
        redirect_uris = [
          "https://${domain}/user/oauth2/authelia/callback"
        ];
        scopes = [
          "openid"
          "email"
          "profile"
          "groups"
        ];
        grant_types = [ "authorization_code" ];
        response_types = [ "code" ];
        authorization_policy = "two_factor";
        consent_mode = "implicit";
        require_pkce = true;
        pkce_challenge_method = "S256";
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };

  # Backup — SQLite database, repositories (incl. LFS) and attachments.
  # app.ini is skipped on purpose: it contains the secrets, which live in sops.
  services.backup.paths = [
    {
      name = "forgejo/data";
      source = "${stateDir}/data/gitea.db";
      method = "sqlite-dump";
    }
    {
      name = "forgejo/git";
      source = "${stateDir}/git";
      method = "copy-dir";
    }
    {
      name = "forgejo/data/attachments";
      source = "${stateDir}/data/attachments";
      method = "copy-dir";
    }
  ];
}
