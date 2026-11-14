{ config, lib, pkgs, ... }:

let
  cfg = config.services.backup;

  # A missing source fails the backup (sqlite3 would otherwise create an empty
  # database) unless the path is marked optional.
  backupCmd = { name, source, method, optional, exclude, ... }:
    let
      excludeCmd = lib.concatMapStringsSep "\n" (pattern:
        ''find "$STAGING/${name}" -type f -name ${lib.escapeShellArg pattern} -delete''
      ) exclude;
      onMissing =
        if optional then
          ''echo "Skipping ${name}: ${source} does not exist"''
        else
          ''echo "Backup source ${source} for ${name} does not exist" >&2; exit 1'';
      # `/.` copies the directory's contents, including dotfiles
      copy =
        if method == "sqlite-dump" then
          ''
            DUMP="$STAGING/${name}/$(basename ${source})"
            # If a copy-dir staged a file here, it is a hardlink to a live
            # file, and dumping onto it would write into that. Removing it
            # only removes the link.
            rm -f "$DUMP" "$DUMP-wal" "$DUMP-shm" "$DUMP-journal"
            ${pkgs.sqlite}/bin/sqlite3 ${source} ".backup $DUMP"
            # Fail the run instead of mirroring a corrupt database
            CHECK=$(${pkgs.sqlite}/bin/sqlite3 "$DUMP" "PRAGMA integrity_check;" 2>&1) || true
            if [ "$CHECK" != "ok" ]; then
              echo "Integrity check failed for $DUMP:" >&2
              echo "$CHECK" >&2
              exit 1
            fi
            # Opening a WAL-mode dump for the check can leave these behind
            rm -f "$DUMP-wal" "$DUMP-shm"
          ''
        else
          ''
            cp -al ${source}/. "$STAGING/${name}/"
            ${excludeCmd}
          '';
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
    # A subdirectory of the share, because the squashed NFS user cannot chmod
    # the share root, which fails rsync -p
    NAS=/mnt/backups/mirror

    if ! grep -q " /mnt/backups " /proc/mounts; then
      echo "Backup NFS mount not available"
      exit 1
    fi

    # A rebuilt server starts every service with empty state, and mirroring
    # that would overwrite the backup it needs to restore from. Such a server
    # has no stamp of its own while the mirror has one, so it refuses until
    # `server-restore --all` (or a deliberate touch) creates the stamp.
    if [ ! -e ${cfg.stampFile} ] && [ -e "$NAS/last-success" ]; then
      echo "Refusing to back up: this server has never completed a backup, but" >&2
      echo "$NAS holds one from $(cat "$NAS/last-success")." >&2
      echo "Restore it with: server-restore --all" >&2
      echo "Or, to replace it with this server's data: touch ${cfg.stampFile}" >&2
      exit 1
    fi

    mkdir -p "$NAS"
    rm -rf "$STAGING"/*

    ${lib.concatMapStringsSep "\n" backupCmd cfg.paths}

    echo "Syncing to NAS..."
    # Owner and group only: the backups hold keys and databases. The NAS squashes
    # root to a user in group users, which the admin account is also in. -p so
    # the modes also apply to files already on the NAS.
    # Output goes to the journal, so the failure notification includes it.
    # last-success is written below, not staged, so --delete must spare it.
    ${pkgs.rsync}/bin/rsync -rltpD --chmod=D750,F640 --delete --stats \
      --exclude=/last-success \
      "$STAGING"/ "$NAS"/

    # Read by the stale backup check, and on the NAS it dates the mirror
    date --iso-8601=seconds > ${cfg.stampFile}
    cp ${cfg.stampFile} "$NAS/last-success"

    echo "Backup complete"
  '';

  # The unit of restore is a service: the paths sharing the first component of
  # their name (`forgejo/data` and `forgejo/git` both belong to `forgejo`).
  services = lib.groupBy (p: lib.head (lib.splitString "/" p.name)) cfg.paths;

  # Where a path lands in the backup: the file for a dump, the directory for
  # a copy
  backupLocation = { name, source, method, ... }:
    if method == "sqlite-dump" then "${name}/${baseNameOf source}" else name;

  # Fails before anything is touched when the backup lacks a required path
  restoreCheck = p: lib.optionalString (!p.optional) ''
    if [ ! -e "$SRC/${backupLocation p}" ]; then
      echo "$SRC/${backupLocation p} is missing from the backup" >&2
      exit 1
    fi
  '';

  # The NAS does not keep ownership (see the rsync above), so it is set from
  # the path's owner and group.
  restoreCmd = p:
    if p.method == "sqlite-dump" then ''
      if [ -e "$SRC/${backupLocation p}" ]; then
        echo "Restoring ${p.source}..."
        make_dir "$ROOT${dirOf p.source}" ${p.owner}:${p.group}
        # Copied beside the database and checked before it replaces it, so a
        # failed copy or a corrupt backup leaves the live database as it was
        TMP="$ROOT${p.source}.restoring"
        cp "$SRC/${backupLocation p}" "$TMP"
        CHECK=$(sqlite3 "$TMP" "PRAGMA integrity_check;" 2>&1) || true
        rm -f "$TMP-wal" "$TMP-shm"
        if [ "$CHECK" != ok ]; then
          rm -f "$TMP"
          echo "$SRC/${backupLocation p} failed its integrity check:" >&2
          echo "$CHECK" >&2
          exit 1
        fi
        chown ${p.owner}:${p.group} "$TMP"
        # A leftover -wal would be replayed into the restored database, and a
        # leftover -journal (from a service killed mid-transaction) would be
        # rolled back into it
        rm -f "$ROOT${p.source}-wal" "$ROOT${p.source}-shm" "$ROOT${p.source}-journal"
        mv -f "$TMP" "$ROOT${p.source}"
      fi
    '' else ''
      if [ -d "$SRC/${backupLocation p}" ]; then
        echo "Restoring ${p.source}..."
        make_dir "$ROOT${p.source}" ${p.owner}:${p.group}
        rsync -rlt "$SRC/${backupLocation p}/" "$ROOT${p.source}/"
        chown -R ${p.owner}:${p.group} "$ROOT${p.source}"
      fi
    '';

  restoreCase = service: paths:
    let
      # Directories first, so a dump is never overwritten or re-owned by the
      # copy of the directory it lives in
      ordered = lib.filter (p: p.method == "copy-dir") paths
        ++ lib.filter (p: p.method == "sqlite-dump") paths;
    in
    ''
      ${service})
        UNITS=(${lib.escapeShellArgs (lib.unique (lib.concatMap (p: p.units) paths))})
        check() {
          :
          ${lib.concatMapStrings restoreCheck paths}
        }
        restore() {
          :
          ${lib.concatMapStrings restoreCmd ordered}
        }
        ;;
    '';

  restoreScript = pkgs.writeShellApplication {
    name = "server-restore";
    runtimeInputs = [ pkgs.coreutils pkgs.rsync pkgs.sqlite pkgs.systemd ];
    text = ''
      usage() {
        cat >&2 <<EOF
      Usage: server-restore <service> [--from DIR] [--test DIR]
             server-restore --all [--from DIR] [--test DIR]

      Restores a service's data from the backup mirror, sets its ownership and
      restarts it. Files in the backup replace their live versions; live files
      that are not in the backup are left alone.

        --all       Restore every service, then let backups run again: for a
                    rebuilt server, whose backups are refused until it has
                    been restored
        --from DIR  Restore from DIR instead of /mnt/backups/mirror, e.g. an
                    older revision restored from Hyper Backup
        --test DIR  Test restore: restore under DIR instead of /, without
                    stopping the service

      Services: ${lib.concatStringsSep " " (lib.attrNames services)}
      EOF
        exit 1
      }

      SRC=/mnt/backups/mirror
      # Prefix for restored paths: empty, or the --test directory. TEST, not
      # an empty ROOT, decides whether this is a live restore.
      ROOT=
      SERVICE=
      ALL=
      TEST=
      while [ $# -gt 0 ]; do
        case "$1" in
          --all) ALL=1; shift ;;
          --from) [ $# -ge 2 ] || usage; SRC=$2; shift 2 ;;
          --test)
            if [ $# -lt 2 ] || [ -z "$2" ]; then usage; fi
            TEST=1
            ROOT=$(realpath -m -- "$2")
            if [ "$ROOT" = / ]; then
              echo "--test needs a scratch directory, not /" >&2
              exit 1
            fi
            shift 2
            ;;
          -*) usage ;;
          *) [ -z "$SERVICE" ] || usage; SERVICE=$1; shift ;;
        esac
      done

      # make_dir <dir> <owner:group>: mkdir -p, but every directory it creates
      # belongs to the service. On a rebuilt server the service may not have
      # created its directories yet, and one left owned by root would stop it
      # writing there.
      make_dir() {
        local dir=$1 missing=()
        while [ ! -d "$dir" ]; do
          missing=("$dir" "''${missing[@]}")
          dir=$(dirname "$dir")
        done
        for dir in "''${missing[@]}"; do
          mkdir "$dir"
          chown "$2" "$dir"
        done
      }

      # Sets UNITS and defines check and restore for a service
      load_service() {
        case "$1" in
      ${lib.concatStrings (lib.mapAttrsToList restoreCase services)}
          *) usage ;;
        esac
      }

      # The service being restored and the units stopped for it, so a failure
      # can say what state things were left in
      CURRENT=
      STOPPED=()
      report_failure() {
        if [ -n "$CURRENT" ]; then
          echo "The restore of $CURRENT failed partway, so its data may be incomplete." >&2
          if [ ''${#STOPPED[@]} -gt 0 ]; then
            echo "Left stopped: ''${STOPPED[*]}" >&2
          fi
          echo "Fix the problem and restore $CURRENT again." >&2
        fi
      }
      trap report_failure EXIT

      restore_service() {
        load_service "$1"
        CURRENT=$1

        if [ -z "$TEST" ]; then
          for unit in "''${UNITS[@]}"; do
            echo "Stopping $unit..."
            systemctl stop "$unit"
            STOPPED+=("$unit")
          done
        fi

        restore

        if [ -z "$TEST" ]; then
          for unit in "''${UNITS[@]}"; do
            echo "Starting $unit..."
            systemctl start "$unit"
          done
        fi

        STOPPED=()
        CURRENT=
        echo "Restored $1 from $SRC"
      }

      if [ -n "$ALL" ]; then
        [ -z "$SERVICE" ] || usage
        SERVICES=(${lib.escapeShellArgs (lib.attrNames services)})
      else
        [ -n "$SERVICE" ] || usage
        SERVICES=("$SERVICE")
      fi

      # Check everything before touching anything
      for service in "''${SERVICES[@]}"; do
        load_service "$service"
        check
      done

      if [ "$(id -u)" -ne 0 ]; then
        echo "server-restore must run as root" >&2
        exit 1
      fi


      for service in "''${SERVICES[@]}"; do
        restore_service "$service"
      done

      # The backup refuses to run on a server without this stamp while the
      # mirror has one. Everything is restored, so it can run again. Keeping
      # the mirror's timestamp keeps the stale backup check honest.
      if [ -n "$ALL" ] && [ -z "$TEST" ]; then
        mkdir -p ${dirOf cfg.stampFile}
        if [ -e "$SRC/last-success" ]; then
          cp --preserve=timestamps "$SRC/last-success" ${cfg.stampFile}
        else
          touch ${cfg.stampFile}
        fi
        echo "Backups are enabled again"
      fi
    '';
  };
in
{
  options.services.backup = {
    stampFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/server-backup/last-success";
      readOnly = true;
      description = ''
        File the backup rewrites each time it completes. Its modification
        time is when the last successful backup finished.
      '';
    };

    paths = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = ''
              Subdirectory in the backup staging area. May be nested (e.g.
              `paperless/data`) so the backup mirrors the source's layout.
              The first component names the service for `server-restore`,
              which restores every path that shares it.
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
          owner = lib.mkOption {
            type = lib.types.str;
            example = "1000";
            description = ''
              User name or ID that owns the source. The backup on the NAS does
              not keep ownership, so `server-restore` sets it from this.
            '';
          };
          group = lib.mkOption {
            type = lib.types.str;
            example = "1000";
            description = "Group name or ID that owns the source.";
          };
          units = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = [ "arion-forgejo.service" ];
            description = ''
              systemd units that use the source. `server-restore` stops them
              while it restores the path and starts them afterwards.
            '';
          };
          exclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = [ "db.sqlite3*" ];
            description = ''
              File name patterns (as for `find -name`) to leave out of a
              `copy-dir` backup, matched at any depth. Use it for a live
              SQLite database and its `-wal` and `-shm` files when the
              database is backed up by a separate `sqlite-dump`: the live
              copy may be inconsistent, and a stale `-wal` restored next to
              the dump can corrupt it.
            '';
          };
        };
      });
      default = [];
      description = "List of paths and databases to back up to the NAS.";
    };
  };

  config = lib.mkIf (cfg.paths != []) {
    environment.systemPackages = [ restoreScript ];

    systemd.tmpfiles.rules = [
      "d /var/backup 0700 root root -"
      "d ${dirOf cfg.stampFile} 0755 root root -"
    ];

    systemd.services.server-backup = {
      description = "Stage and sync server backups to NAS";
      after = [ "mnt-backups.mount" "network-online.target" ];
      wants = [ "mnt-backups.mount" "network-online.target" ];
      onFailure = [ "ntfy-backup-failure.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backupScript}/bin/server-backup";
        # The NFS mount is `hard`, so I/O blocks while the NAS is away and
        # resumes when it returns. Without a limit, a NAS that stays down
        # would hang the run forever and never reach onFailure.
        TimeoutStartSec = "1h";
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
