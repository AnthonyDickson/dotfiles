{ ... }:

{
  networking.hostName = "SERVER-A";

  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 53 80 443 ];
    allowedTCPPorts = [ 53 80 443 ];
  };
}
