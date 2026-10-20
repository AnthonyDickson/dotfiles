# Kavita

E-book and comic server at `https://kavita.s.anthonyd.co.nz`, running
`linuxserver/kavita` as an Arion project. Kavita handles its own logins, so
Caddy does not put Authelia in front of it (OPDS readers and mobile apps cannot
follow the login redirect).

## State

State lives under `/var/lib/kavita` (created at boot by `systemd.tmpfiles`),
owned by uid **1000** / gid **100** to match `PUID` / `PGID`:

| Path                     | Container path | Contents                               |
| ------------------------ | -------------- | -------------------------------------- |
| `/var/lib/kavita/config` | `/config`      | `kavita.db`, covers, bookmarks, themes |
| `/var/lib/kavita/data`   | `/data` (ro)   | The library, under `media/books/`      |

Library paths are stored in the database as container paths
(`/data/media/books`), matching the old NAS layout. Keep files under that folder
rather than adding a new mount, or Kavita treats the series as new and loses
reading progress.

Backups dump `kavita.db` and hardlink `config/` and `data/` into
`/mnt/backups/kavita/` (see [Backups](./backups.md)).

## Adding books

Kavita expects one folder per series:

```
media/books/
├── Some Series/
│   ├── Some Series v01.epub
│   └── Some Series v02.epub
└── A Standalone Book/
    └── A Standalone Book.epub
```

The desktop is the machine with SSH access to the server, so copy from there.
The library is owned by uid 1000, so stage the files in your home directory
first and move them into place with `sudo`:

```shell
scp -r 'Some Series' server:
ssh -t server "sudo mv ~/'Some Series' /var/lib/kavita/data/media/books/ && \
  sudo chown -R 1000:100 /var/lib/kavita/data"
```

Files copied from macOS can bring `.DS_Store` files along. To clear them out:

```shell
ssh -t server 'sudo find /var/lib/kavita/data -name .DS_Store -delete'
```

## Scanning

Kavita scans every library once a day (change this under **Settings → Tasks →
Library Scan**). To pick up new books straight away, open **Settings →
Libraries** in the web UI and click the scan button next to the library, or
choose **Scan Library** from the library's menu in the sidebar.

To scan automatically, turn on **Settings → General → Folder Watching**. Kavita
waits 10 minutes after a change before it scans.

## Removing books

Delete the series folder on the server, then scan the library. Kavita removes
series whose files have disappeared:

```shell
ssh -t server "sudo rm -r /var/lib/kavita/data/media/books/'Some Series'"
```

## Upgrading

The image is pinned in `arion-compose.nix`. Bump the tag, deploy, and check the
Kavita release notes first for breaking changes. Database migrations only run
forward, so restore `kavita.db` from backup if you need to roll back.
