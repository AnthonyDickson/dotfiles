{ config, lib, pkgs, ... }:

let
  cfg = config.services.backup;

  backupCmd = { name, source, method }: ''
    echo "Backing up ${name}..."
    mkdir -p "$STAGING/${name}"
  ''
  + (if method == "sqlite-dump" then ''
    ${pkgs.sqlite}/bin/sqlite3 ${source} \
      ".backup $STAGING/${name}/$(basename ${source})"
  '' else ''
    cp -al ${source}/* "$STAGING/${name}/" || true
  '');

  backupScript = pkgs.writeShellScriptBin "server-backup" ''
    set -euo pipefail

    STAGING=/var/backup
    NAS=/mnt/backups

    if ! grep -q " /mnt/backups " /proc/mounts; then
      echo "Backup NFS mount not available"
      exit 1
    fi

    mkdir -p "$NAS"
    rm -rf "$STAGING"/*

    ${lib.concatMapStringsSep "\n" backupCmd cfg.paths}

    LOGDIR=/var/log/backups
    mkdir -p "$LOGDIR"
    LOGFILE="$LOGDIR/$(date +%Y-%m-%d_%H-%M-%S).log"

    echo "Syncing to NAS (log: $LOGFILE)..."
    ${pkgs.rsync}/bin/rsync -rltD --chmod=D755,F644 --delete --stats \
      "$STAGING"/ "$NAS"/ > "$LOGFILE" 2>&1

    echo "Backup complete"
  '';
in
{
  options.services.backup = {
    paths = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Subdirectory name in the backup staging area.";
          };
          source = lib.mkOption {
            type = lib.types.str;
            description = "Source path to back up.";
          };
          method = lib.mkOption {
            type = lib.types.enum [ "sqlite-dump" "copy-dir" ];
            description = ''
              Backup method:
              `sqlite-dump` — runs `sqlite3 .backup` (safe export).
              `copy-dir` — hardlinks directory contents with `cp -al`.
            '';
          };
        };
      });
      default = [];
      description = "List of paths and databases to back up to the NAS.";
    };
  };

  config = lib.mkIf (cfg.paths != []) {
    systemd.tmpfiles.rules = [
      "d /var/backup 0755 root root -"
      "d /var/log/backups 0755 root root -"
    ];

    systemd.services.server-backup = {
      description = "Stage and sync server backups to NAS";
      after = [ "mnt-backups.mount" "network-online.target" ];
      wants = [ "mnt-backups.mount" "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backupScript}/bin/server-backup";
      };
    };

    systemd.timers.server-backup = {
      description = "Daily server backup to NAS";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = 600;
      };
    };
  };
}
