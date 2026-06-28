{ ... }:

{
  services.rpcbind.enable = true;

  fileSystems."/mnt/media" = {
    device = "192.168.0.10:/volume1/data/media";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "intr" ];
  };

  fileSystems."/mnt/backups" = {
    device = "192.168.0.10:/volume1/server_backup";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "intr" ];
  };
}
