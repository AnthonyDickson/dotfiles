{ hostname, ... }:
let
  localsend = 53317;
in
{
  networking.hostName = hostname; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ localsend ];
    allowedUDPPorts = [ localsend ];
  };
}
