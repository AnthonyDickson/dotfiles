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

- [ ] Host-level monitoring
  - [ ] Caddy health check (`localhost:2019`) and cert expiry
  - [ ] Authelia health check
  - [ ] Docker daemon (`systemctl is-active docker`)
  - [ ] NFS mount (`/mnt/backups` reachable)
  - [ ] Disk space thresholds on `/` and `/var`
  - [ ] systemd timer last-run status for `server-backup.timer`
