{ ... }:

{
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--advertise-routes=192.168.0.0/24" ];
    extraSetFlags = [ "--accept-dns=false" ];
  };
}
