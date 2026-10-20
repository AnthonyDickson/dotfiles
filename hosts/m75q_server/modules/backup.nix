{ config, lib, pkgs, ... }:

let
  cfg = config.services.backup;

  # A missing source fails the backup (sqlite3 would otherwise create an empty
  # database) unless the path is marked optional.
  backupCmd = { name, source, method, optional }:
    let
      onMissing =
        if optional then
          ''echo "Skipping ${name}: ${source} does not exist"''
        else
          ''echo "Backup source ${source} for ${name} does not exist" >&2; exit 1'';
      # `/.` copies the directory's contents, including dotfiles
      copy =
        if method == "sqlite-dump" then
          ''${pkgs.sqlite}/bin/sqlite3 ${source} ".backup $STAGING/${name}/$(basename ${source})"''
        else
          ''cp -al ${source}/. "$STAGING/${name}/"'';
    in
    ''
      echo "Backing up ${name}..."
      if [ ! -e ${source} ]; then
        ${onMissing}
      else
        mkdir -p "$STAGING/${name}"
        ${copy}
      fi
    '';

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
    # Owner and group only: the backups hold keys and databases. The NAS squashes
    # root to a user in group users, which the admin account is also in. -p so
    # the modes also apply to files already on the NAS.
    ${pkgs.rsync}/bin/rsync -rltpD --chmod=D750,F640 --delete --stats \
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
            description = ''
              Subdirectory in the backup staging area. May be nested (e.g.
              `paperless/data`) so the backup mirrors the source's layout.
            '';
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
          optional = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Skip the path when it does not exist instead of failing the
              backup, for directories an app only creates once it needs them.
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
      "d /var/backup 0700 root root -"
      "d /var/log/backups 0755 root root -"
    ];

    systemd.services.server-backup = {
      description = "Stage and sync server backups to NAS";
      after = [ "mnt-backups.mount" "network-online.target" ];
      wants = [ "mnt-backups.mount" "network-online.target" ];
      onFailure = [ "ntfy-backup-failure.service" ];
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
