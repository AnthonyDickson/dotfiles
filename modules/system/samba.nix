{pkgs, ...}:
let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  share_name = "NAS-A";
  mount_point = "/media/nas";
  credentials_path = "/etc/nixos/smb-secrets";
in
{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];
  fileSystems = {
    "${mount_point}/home" = {
      # Probably requires Tailscale to be on to work
      device = "//${share_name}/home";
      fsType = "cifs";
      # Specify so that volumes are mounted as user.
      # This prevents requiring sudo to read/write files, be careful!
      options = ["${automount_opts},credentials=${credentials_path},uid=1000,gid=100"];
    };
  };
}
