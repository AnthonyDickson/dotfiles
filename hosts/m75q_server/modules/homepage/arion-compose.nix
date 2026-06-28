{ ... }: {
  project.name = "homepage";

  services.homepage.service = {
    image = "ghcr.io/gethomepage/homepage:v1.13.2";

    network_mode = "host";

    environment = {
      HOMEPAGE_ALLOWED_HOSTS = "homepage.s.anthonyd.co.nz";
      PUID = "1000";
      PGID = "131";
    };

    volumes = [
      "/var/lib/homepage/config:/app/config"
      "/var/lib/homepage/config/images:/app/public/images"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
      "/:/host:ro"
      "/sys:/sys:ro"
    ];

    restart = "unless-stopped";
  };
}
