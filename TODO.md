# TODOs

Things to work on for the server config

## Monitoring

- [ ] Host-level monitoring
  - [ ] Caddy health check (`localhost:2019`) and cert expiry
  - [ ] Authelia health check
  - [ ] Docker daemon (`systemctl is-active docker`)
  - [ ] NFS mount (`/mnt/backups` reachable)
  - [ ] Disk space thresholds on `/` and `/var`
  - [ ] systemd timer last-run status for `server-backup.timer`
