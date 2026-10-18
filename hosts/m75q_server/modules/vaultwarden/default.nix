{ ... }:

let
  domain = "vaultwarden.s.anthonyd.co.nz";
  port = 8222;
  # Fixed by the NixOS module for stateVersion >= 24.11
  stateDir = "/var/lib/vaultwarden";
in
{
  services.vaultwarden = {
    enable = true;

    config = {
      DOMAIN = "https://${domain}";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;

      # Caddy sends X-Forwarded-For, not Vaultwarden's default X-Real-IP
      IP_HEADER = "X-Forwarded-For";

      # Single user and no SMTP server, so invites and email-based features
      # (email 2FA, emergency access, new device notices) are unavailable
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;
      SHOW_PASSWORD_HINT = false;

      # The admin page is disabled because ADMIN_TOKEN is not set, as settings
      # are managed here. To use it temporarily, add ADMIN_TOKEN (an argon2
      # PHC string from `vaultwarden hash`) through a sops environmentFile.
      # Settings it saves go to ${stateDir}/config.json and override these.

      # Mobile push needs PUSH_ENABLED here and PUSH_INSTALLATION_ID and
      # PUSH_INSTALLATION_KEY from https://bitwarden.com/host in a sops
      # environmentFile.
    };
  };

  # The Bitwarden clients call the API directly and cannot follow Authelia's
  # login redirect, so Caddy does not put forward auth in front of it.
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # Backup — SQLite database, plus the RSA keys, attachments and sends. The
  # copy-dir also picks up a live copy of the database, which the dump makes
  # redundant.
  services.backup.paths = [
    {
      name = "vaultwarden/db";
      source = "${stateDir}/db.sqlite3";
      method = "sqlite-dump";
    }
    {
      name = "vaultwarden/data";
      source = stateDir;
      method = "copy-dir";
    }
  ];
}
