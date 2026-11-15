{ config, pkgs, lib, ... }:
let
  domain = "ntfy.anthonyd.co.nz";
  port = 2586;
  # Thresholds for the daily health check
  staleBackupHours = 30;
  diskUsedPercent = 85;

  # Run by smartd, as root, with the problem described in SMARTD_* variables
  smartdNotify = pkgs.writeShellScript "smartd-ntfy" ''
    # smartd may find a problem at boot, before ntfy is listening
    ${pkgs.curl}/bin/curl -fsS -o /dev/null --retry 5 --retry-connrefused \
      -H "Authorization: Bearer $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.ntfy-token.path})" \
      -H "Title: $SMARTD_SUBJECT" \
      -H "Priority: high" \
      -H "Tags: warning" \
      -d "$SMARTD_MESSAGE" "http://localhost:${toString port}/disk"
  '';
in
{
  # --- Secrets ---

  sops.secrets.ntfy-pass-hash = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "ntfy-pass-hash";
    owner = "ntfy-sh";
  };

  # bcrypt hash for the read-only `reader` user that clients subscribe with,
  # from `ntfy user hash`
  sops.secrets.ntfy-reader-pass-hash = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
    key = "ntfy-reader-pass-hash";
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
      # Topics carry backup logs and the container list, so clients sign in
      auth-default-access = "deny-all";
    };
  };

  # The nixpkgs module no longer defines a static ntfy-sh user, so declare one
  # here. Disable DynamicUser so the ntfy-sh process runs as this user, which
  # can read its sops-owned secret files.
  users.users.ntfy-sh = {
    isSystemUser = true;
    group = "ntfy-sh";
  };
  users.groups.ntfy-sh = { };

  systemd.services.ntfy-sh.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ntfy-sh";
    Group = "ntfy-sh";
  };

  # Override ExecStart with a wrapper that reads auth secrets at runtime.
  # sops.placeholder returns full dotenv lines (KEY=VALUE), but .path files
  # contain only the extracted value — so we read those instead.
  systemd.services.ntfy-sh.serviceConfig.ExecStart = lib.mkForce (
    let
      cfg = config.services.ntfy-sh;
      startScript = pkgs.writeShellScript "ntfy-start" ''
        export NTFY_AUTH_USERS="server:$(cat ${config.sops.secrets.ntfy-pass-hash.path}):admin,reader:$(cat ${config.sops.secrets.ntfy-reader-pass-hash.path}):user"
        export NTFY_AUTH_ACCESS="reader:*:ro"
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
      curl -fsS -o /dev/null \
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

      # Snapshot every container's name, state and health, sorted for stable
      # comparison. Not `docker ps` Status, which includes the uptime and so
      # changes as time passes.
      CURRENT=$(docker ps -aq 2>/dev/null \
        | xargs -r docker inspect -f '{{slice .Name 1}} {{.State.Status}}{{if .State.Health}} ({{.State.Health.Status}}){{end}}' 2>/dev/null \
        | sort || true)
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

  # --- Disk health (SMART) ---

  # smartd reads the drives' health counters and error logs every 30 minutes,
  # which puts no load on them. No self-tests are scheduled.
  services.smartd = {
    enable = true;
    # Only the ntfy notifier below
    notifications.wall.enable = false;
    # -a: all health checks; -W: note 70°C, warn at 80°C; -M daily: repeat
    # the warning each day while the problem lasts
    defaults.monitored = "-a -W 0,70,80 -m <nomailer> -M daily -M exec ${smartdNotify}";
  };

  # --- Daily check for a stale backup and low disk space ---

  # The backup's own failure notification covers a run that fails. This
  # covers a run that never happens, and a disk filling up, which would break
  # the database dumps. It repeats daily for as long as the problem lasts.
  systemd.timers.server-health-check = {
    description = "Daily check for a stale backup and low disk space";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Well after the backup, which starts at midnight
      OnCalendar = "09:00";
      Persistent = true;
    };
  };

  systemd.services.server-health-check = {
    description = "Notify when the backup is stale or the disk is filling up";
    after = [ "ntfy-sh.service" ];
    wants = [ "ntfy-sh.service" ];
    path = [ pkgs.curl ];
    serviceConfig.Type = "oneshot";
    script = ''
      TOKEN=$(cat ${config.sops.secrets.ntfy-token.path})

      # notify <topic> <title> <message>
      notify() {
        curl -fsS -o /dev/null --retry 5 --retry-connrefused \
          -H "Authorization: Bearer $TOKEN" \
          -H "Title: $2" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d "$3" "http://localhost:${toString port}/$1"
      }

      # A notification that cannot be sent must not skip the checks after it
      FAILED=0

      STAMP=${config.services.backup.stampFile}
      if [ ! -e "$STAMP" ]; then
        notify backups "Backup is stale" "No backup has completed on this server yet." || FAILED=1
      else
        AGE_HOURS=$(( ($(date +%s) - $(stat -c %Y "$STAMP")) / 3600 ))
        # A daily backup that last finished just after midnight is 33 hours
        # old by the morning after a missed run
        if [ "$AGE_HOURS" -ge ${toString staleBackupHours} ]; then
          notify backups "Backup is stale" \
            "The last successful backup finished $AGE_HOURS hours ago ($(cat "$STAMP"))." || FAILED=1
        fi
      fi

      # /var is on the root filesystem
      USED=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')
      if [ "$USED" -ge ${toString diskUsedPercent} ]; then
        notify disk "Disk space low" "The root filesystem is $USED% full." || FAILED=1
      fi

      exit "$FAILED"
    '';
  };
}
