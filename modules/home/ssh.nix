# SSH profiles shared by every host. The server domain resolves to the LAN IP via
# dnsmasq at home and to the Tailscale IP elsewhere.
{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "server" = {
        hostname = "anthonyd.co.nz";
        port = 22;
        user = "anthonyd";
        identityFile = "~/.ssh/server";
        identitiesOnly = true;
      };
      "nas" = {
        hostname = "dsm.nas.anthonyd.co.nz";
        port = 22;
        user = "anthony";
        identityFile = "~/.ssh/nas";
        identitiesOnly = true;
      };
    };
  };
}
