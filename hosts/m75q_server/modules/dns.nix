{ ... }:

let
  unboundPort = 5353;
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [
        "/anthonyd.co.nz/192.168.0.10"
        "/s.anthonyd.co.nz/192.168.0.20"
      ];
      server = [ "127.0.0.1#${toString unboundPort}" ];
    };
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        port = unboundPort;
        interface = [ "127.0.0.1" ];
      };
      remote-control = {
        control-enable = true;
        control-interface = [ "127.0.0.1" ];
      };
    };
  };
}
