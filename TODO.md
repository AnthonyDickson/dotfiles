# TODOs

Things to work on for the server config

## Migration from NAS

- [ ] Plan out paperless migration
      - Will likely move all data to the server and backup via scripts
      - The media is under /.../data/paperless-ngx
      - The app state is under /.../docker/paperless-ngx
- [ ] Vikunja?
- [ ] Forgejo?
- [ ] Vaultwarden?
- Media management (e.g., Sonarr) will stay on the NAS due to the size of my library

## Monitoring

- [ ] Add `OnFailure=` notification for `server-backup.service` (ntfy or similar)
- [ ] Notify on services going down?
