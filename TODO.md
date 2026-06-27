# TODOs

Things to work on for the server config

## Refactoring

- [ ] Consider modularising server config.
      Go from a modules config spread across many technical layers to service modules that define the whole stack.

## Migration from NAS

- [ ] Plan out paperless migration
      - Will likely move all data to the server and backup via scripts
      - The media is under /.../data/paperless-ngx
      - The app state is under /.../docker/paperless-ngx
- [ ] Vikunja?
- [ ] Forgejo?
- [ ] Vaultwarden?
- Media management (e.g., Sonarr) will stay on the NAS due to the size of my library

## Backups

- [ ] Is it worth backing up homepage? It is entirely declaritive.

## Monitoring

- [ ] Add `OnFailure=` notification for `server-backup.service` (ntfy or similar)
- [ ] Notify on services going down?
