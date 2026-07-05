{ config, pkgs, lib, ... }:
let
  domain = "ntfy.s.anthonyd.co.nz";
  port = 2586;
in
{
  # --- Secrets ---

  sops.secrets.ntfy-pass-hash = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "ntfy-pass-hash";
    owner = "ntfy-sh";
  };

  sops.secrets.ntfy-token = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "ntfy-token";
    owner = "ntfy-sh";
  };

  # --- ntfy-sh service ---

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${domain}";
      # https://docs.ntfy.sh/known-issues/#ios-app-not-receiving-notifications-anymore
      upstream-base-url = "https://ntfy.sh";
      behind-proxy = true;
      auth-default-access = "read-only";
    };
  };

  # Disable DynamicUser so the ntfy-sh process runs as the static ntfy-sh
  # user, which can read its sops-owned secret files.
  systemd.services.ntfy-sh.serviceConfig.DynamicUser = lib.mkForce false;

  # Override ExecStart with a wrapper that reads auth secrets at runtime.
  # sops.placeholder returns full dotenv lines (KEY=VALUE), but .path files
  # contain only the extracted value — so we read those instead.
  systemd.services.ntfy-sh.serviceConfig.ExecStart = lib.mkForce (
    let
      cfg = config.services.ntfy-sh;
      startScript = pkgs.writeShellScript "ntfy-start" ''
        export NTFY_AUTH_USERS="server:$(cat ${config.sops.secrets.ntfy-pass-hash.path}):admin"
        export NTFY_AUTH_TOKENS="server:$(cat ${config.sops.secrets.ntfy-token.path}):publish"
        exec ${cfg.package}/bin/ntfy serve "$@"
      '';
      configPath = "/etc/ntfy/server.yml";
    in
    "${startScript} -c ${configPath}"
  );

  # --- Caddy reverse proxy ---

  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # --- OnFailure notifier for backup service ---

  systemd.services.ntfy-backup-failure = {
    description = "Send ntfy notification when backup fails";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.curl pkgs.systemd ];
    script = ''
      TOKEN=$(cat ${config.sops.secrets.ntfy-token.path})
      LOGS=$(journalctl -u server-backup.service -n 30 --no-pager -o short 2>/dev/null || echo "(no logs)")
      curl -s -o /dev/null \
        -H "Authorization: Bearer $TOKEN" \
        -H "Title: Backup failed" \
        -H "Priority: high" \
        -H "Tags: warning,rotating_light" \
        -d "$LOGS" "http://localhost:${toString port}/backups"
    '';
  };

  # --- Docker container health watch ---

  systemd.timers.docker-health-watch = {
    description = "Periodic Docker container health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00/5:00";
    };
  };

  systemd.services.docker-health-watch = {
    description = "Check Docker container health and notify on state changes";
    after = [ "docker.service" "ntfy-sh.service" ];
    wants = [ "docker.service" "ntfy-sh.service" ];
    path = [ pkgs.docker pkgs.curl ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Bail if sops hasn't decrypted the token yet (system still activating)
      if [ ! -f ${config.sops.secrets.ntfy-token.path} ]; then
        exit 0
      fi

      TOKEN=$(cat ${config.sops.secrets.ntfy-token.path})
      STATE_DIR=/var/lib/ntfy-monitor
      STATE_FILE=$STATE_DIR/container-state.json
      mkdir -p "$STATE_DIR"

      UPTIME=$(awk '{print int($1)}' /proc/uptime)

      # Snapshot every container's name and status line, sorted for stable comparison
      CURRENT=$(docker ps -a --format '{{.Names}} {{.Status}}' 2>/dev/null | sort || true)
      # Docker daemon isn't running — nothing to monitor
      if [ -z "$CURRENT" ] && ! systemctl -q is-active docker.service; then
        exit 0
      fi

      # First run — store the baseline state without notifying
      if [ ! -f "$STATE_FILE" ]; then
        echo "$CURRENT" > "$STATE_FILE"
        exit 0
      fi

      PREVIOUS=$(cat "$STATE_FILE")
      # State changed: a container was created, removed, started, stopped, or changed health
      if [ "$CURRENT" != "$PREVIOUS" ]; then
        echo "$CURRENT" > "$STATE_FILE"
        # Suppress notifications within 5 minutes of boot (containers are still starting)
        if [ "$UPTIME" -lt 300 ]; then
          exit 0
        fi
        curl -s -o /dev/null \
          -H "Authorization: Bearer $TOKEN" \
          -H "Title: Container state change" \
          -H "Tags: docker" \
          -d "$CURRENT" "http://localhost:${toString port}/docker"
      fi
    '';
  };
}
