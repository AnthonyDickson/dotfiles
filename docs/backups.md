# Backups

Server data is backed up daily to the Synology NAS over NFS using a push model.

## Design

A systemd timer triggers a oneshot service each day. The service:

1. **SQLite databases** — runs `.backup` (consistent snapshot, ~few MB each)
2. **Config trees** — creates a hardlink tree (`cp -al`, zero extra disk usage)
3. **Syncs to NAS** — `rsync --delete` mirrors the staging tree to `/mnt/backups/`

See the `server-backup` service in `hosts/m75q_server/configuration.nix` for
the current list of backed-up paths.

The NAS exports `/volume1/server_backup` via NFSv4.1 (squashed to admin) and
Hyper Backup snapshots the share on its own schedule, providing versioned
retention without any server-side complexity.

NixOS config and secrets live in git — out of scope.

## NAS setup

1. Create a shared folder at `/volume1/server_backup` with a quota (100 GB)
2. Enable NFSv4.1 in **Control Panel → File Services → NFS**
3. Edit the share's NFS permissions: allow `192.168.0.20`, **Squash → Map all
   users to admin**
4. Enable **data checksum for advanced data integrity** on the share (bit rot
   protection for backup data)
5. Configure Hyper Backup to snapshot the share

## Verification

```bash
# Check next run time
systemctl list-timers server-backup.timer

# Trigger a manual run
sudo systemctl start server-backup

# View service output
journalctl -u server-backup --no-pager -o cat

# Browse transfer logs
ls -t /var/log/backups/ | head -5
cat /var/log/backups/$(ls -t /var/log/backups/ | head -1)
```

## Restore

Files on the NAS are a plain mirror (not a backup format). To restore:

```bash
# Copy specific file
sudo cp /mnt/backups/<service>/data.db /var/lib/<service>/

# Full restore of a service's config tree
sudo rsync -a /mnt/backups/<service>/ /var/lib/<service>/config/
```

Hyper Backup also provides a point-and-click restore from the DSM GUI if you
need to go back to an older snapshot.

## Adding a new service

When adding a new container or service that has state worth backing up:

1. **Identify the data path** — usually a bind mount in the Arion compose file
   (e.g. `/var/lib/<service>/`)

2. **Add a staging line** to the backup script in `configuration.nix`. For
   SQLite databases:
   ```nix
   echo "Dumping <service> database..."
   ${pkgs.sqlite}/bin/sqlite3 /var/lib/<service>/data.db \
     ".backup $STAGING/<service>/data.db"
   ```
   For plain file trees:
   ```nix
   echo "Linking <service> config..."
   cp -al /var/lib/<service>/config/* "$STAGING/<service>/" || true
   ```

3. **Add the directory** to the staging `mkdir` line (alphabetical order):
   ```nix
   mkdir -p "$STAGING"/{budgeteur,authelia,jellyfin,homepage,<service>}
   ```
