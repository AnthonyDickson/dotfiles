{ ... }:

{
  # nofail: a NAS outage at boot leaves the mounts down instead of failing
  # remote-fs.target. Jellyfin and the backup wait for their mount anyway.
  fileSystems."/mnt/media" = {
    device = "192.168.0.10:/volume1/data/media";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "nofail" ];
  };

  fileSystems."/mnt/backups" = {
    device = "192.168.0.10:/volume1/server_backup";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "nofail" ];
  };
}
