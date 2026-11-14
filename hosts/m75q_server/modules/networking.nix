{ ... }:

{
  networking.hostName = "SERVER-A";

  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    # 443 for HTTP/3; HTTP on port 80 is TCP only
    allowedUDPPorts = [ 53 443 ];
    allowedTCPPorts = [ 53 80 443 ];
  };
}
