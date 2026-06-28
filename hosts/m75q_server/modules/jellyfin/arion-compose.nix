{ ... }: {
  project.name = "jellyfin";

  services.jellyfin.service = {
    image = "jellyfin/jellyfin:10.11.11";

    ports = [ "8096:8096" ];

    environment = {
      TZ = "Pacific/Auckland";
    };

    volumes = [
      "/var/lib/jellyfin/config:/config"
      "/var/lib/jellyfin/cache:/cache"
      "/mnt/media:/media:ro"
    ];

    user = "1000:303";

    devices = [
      "/dev/dri:/dev/dri"
    ];

    healthcheck = {
      test = ["CMD" "curl" "-f" "http://127.0.0.1:8096/health"];
      interval = "30s";
      timeout = "5s";
      retries = 3;
      start_period = "10s";
    };

    labels = {
      "homepage.group" = "Media";
      "homepage.name" = "Jellyfin";
      "homepage.href" = "https://jellyfin.s.anthonyd.co.nz";
      "homepage.description" = "Media server";
      "homepage.icon" = "sh-jellyfin";
    };

    restart = "unless-stopped";
  };
}
