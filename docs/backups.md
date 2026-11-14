# Backups

Server data is backed up daily to the Synology NAS over NFS using a push model.
Hyper Backup on the NAS then keeps versioned, off-site copies.

## Design

A systemd timer starts the `server-backup` service each day at midnight. The
service builds a staging tree in `/var/backup` and mirrors it to the NAS:

1. **SQLite databases** — `sqlite3 .backup` takes a consistent snapshot, which
   must then pass `PRAGMA integrity_check` or the run fails
2. **Directories** — a hardlink tree (`cp -al`, no extra disk usage). Live
   databases and their `-wal`/`-shm` files are left out, since the dump covers
   them
3. **Sync to NAS** — `rsync --delete` mirrors the staging tree to
   `/mnt/backups/mirror/` (a subdirectory: the squashed NFS user cannot change
   the share root's permissions)
4. **Stamp** — the finish time is written to
   `/var/lib/server-backup/last-success` and to `last-success` in the mirror

Each service module declares what to back up in `services.backup.paths`; the
module itself is `hosts/m75q_server/modules/backup.nix`.

The NAS exports `/volume1/server_backup` via NFSv4.1 (squashed to admin). The
mirror holds only the latest state, so history comes from Hyper Backup:

| Hyper Backup setting | Value                                  |
| -------------------- | -------------------------------------- |
| Schedule             | Daily at 01:00, after the server's run |
| Destination          | Off-site                               |
| Retention            | Rotating revisions, about 9 months     |

NixOS config and secrets live in git — out of scope.

### Ownership and permissions

The NAS squashes every file to one account, and the mirror is stored with modes
`750`/`640`, so ownership and modes are not kept. Each backup path declares its
`owner` and `group` instead, and `server-restore` applies them. Executable bits
are lost; the only ones that matter are Forgejo's git hooks, which can be
regenerated (see [Forgejo](./forgejo.md#backups)).

### When the NAS is unavailable

- **Down when the backup starts** — the run fails and sends a notification.
- **Reboots during the backup** — the NFS mount is `hard`, so the run pauses and
  resumes when the NAS returns.
- **Stays down** — the run is stopped after an hour and sends a notification.
  The next run brings the mirror back in line.

## Monitoring

Notifications go to ntfy (topics `backups` and `disk`):

| Problem                          | Raised by                                 |
| -------------------------------- | ----------------------------------------- |
| A backup run fails or times out  | `ntfy-backup-failure`, with the run's log |
| A rebuilt server is not restored | `ntfy-backup-failure`: backup is refused  |
| No successful backup for 30 h    | `server-health-check`, daily at 09:00     |
| Root filesystem over 85% full    | `server-health-check`, daily at 09:00     |
| Disk reports a SMART problem     | `smartd`                                  |

## NAS setup

1. Create a shared folder at `/volume1/server_backup` with a quota (100 GB)
2. Enable NFSv4.1 in **Control Panel → File Services → NFS**
3. Edit the share's NFS permissions: allow `192.168.0.20`, **Squash → Map all
   users to admin**
4. Limit the shared folder's permissions to the admin account. The files are
   group-readable by `users`, which every local NAS account belongs to
5. Enable **data checksum for advanced data integrity** on the share (bit rot
   protection for backup data)
6. Configure Hyper Backup as in the table above, with client-side encryption for
   the off-site copy

Keep the Hyper Backup encryption key, the sops admin key and an export of the
Vaultwarden vault somewhere that does not depend on this server.

## Verification

```bash
# Check next run time
systemctl list-timers server-backup.timer

# Trigger a manual run
sudo systemctl start server-backup

# View the last run's output, including the rsync summary
journalctl -u server-backup --no-pager -o cat

# When the last successful backup finished
cat /var/lib/server-backup/last-success
```

## Restore

`server-restore` restores one service from the mirror. It stops the service,
copies its directories back, replaces its database with the dump (once the dump
passes an integrity check), sets ownership and starts it again:

```bash
# List the services that can be restored
server-restore

sudo server-restore vikunja
```

Files in the backup replace their live versions. Live files that are not in the
backup are left alone.

To go back to an older revision, restore it from Hyper Backup into a directory
and point `--from` at it:

```bash
sudo server-restore vikunja --from /path/to/restored/mirror
```

The mirror is also a plain copy of the files, so a single file can be copied
back by hand. Set its ownership afterwards.

Revisions made before `server-restore` existed keep Jellyfin under `jellyfin/`
and `jellyfin-db/`, not `jellyfin/config/` and `jellyfin/db/`. Rename those two
directories in the restored copy before using `--from` for Jellyfin.

A backup and a restore never run at the same time: a restore refuses to start
during a backup, and a backup that comes due during a restore waits for it.

If a restore fails partway, it says which service was affected and which units
it left stopped. The service's data may then be incomplete, so fix the problem
and restore that service again, which also starts it.

### Test restore

`--test` restores under a scratch directory instead of `/` and leaves the
running service alone. Use it to check that a backup is complete and readable;
the restore fails if a database does not pass an integrity check:

```bash
sudo server-restore vikunja --test /var/tmp/restore-test
sudo rm -r /var/tmp/restore-test
```

### Rebuilding the server

A freshly installed server starts every service with empty state, and mirroring
that would overwrite the good copy on the NAS. The backup guards against this:
it refuses to run, and sends a failure notification, on a server that has never
completed a backup (no `/var/lib/server-backup/last-success`) while the mirror
holds one. So a rebuilt server can be restored at any time.

1. Re-encrypt the secrets for the new host key (see
   [Migrating to a New Server](./secrets.md#migrating-to-a-new-server)) and
   rebuild
2. Run `sudo server-restore --all`, which restores every service and then lets
   backups run again

Restoring a single service does not lift the guard. To lift it by hand, for
example to keep the new server's data and let it replace the mirror, or if the
stamp was deleted on a healthy server:

```bash
sudo touch /var/lib/server-backup/last-success
```

Two things to know about lifting the guard:

- `--all` restores nothing if the mirror lacks a required path, such as a
  service added after the last backup. Restore the other services one at a time,
  then lift the guard by hand.
- `touch` makes the stale backup check see a fresh backup, so it stays quiet for
  30 hours even if no backup completes.

The guard only recognises a rebuilt server. If one service loses its data on an
otherwise healthy server, the next backup mirrors that loss, so restore the
service before midnight or recover it from a Hyper Backup revision.

## Adding a new service

When adding a new container or service that has state worth backing up:

1. **Identify the data path** — usually a bind mount in the Arion compose file
   (e.g. `/var/lib/<service>/`)

2. **Declare it** in the service's module. Names that share a first component
   (`<service>/…`) are restored together:

   ```nix
   services.backup.paths = map (path: path // {
     # Who owns the data, and what to stop while restoring it
     owner = "1000";
     group = "1000";
     units = [ "arion-<service>.service" ];
   }) [
     {
       name = "<service>/db";
       source = "/var/lib/<service>/data.db";
       method = "sqlite-dump";
     }
     {
       name = "<service>/files";
       source = "/var/lib/<service>/files";
       method = "copy-dir";
     }
   ];
   ```

3. **Exclude a live database from its directory.** If a `copy-dir` source
   contains a database that is also dumped, add `exclude = [ "data.db*" ];` to
   the `copy-dir` path, and keep the dump's `name` outside that directory's
   `name`.

4. **Mark late-created directories** with `optional = true;` if the app only
   creates them on first use. Any other missing source fails the backup.
