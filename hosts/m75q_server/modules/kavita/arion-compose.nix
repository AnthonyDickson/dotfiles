{ ... }: {
  project.name = "kavita";

  services.kavita = {
    service = {
      image = "linuxserver/kavita:v0.9.1.4-ls128";

      ports = [ "5000:5000" ];

      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Pacific/Auckland";
      };

      # Library paths in the database are under /data, as on the NAS
      volumes = [
        "/var/lib/kavita/config:/config"
        "/var/lib/kavita/data:/data:ro"
      ];

      healthcheck = {
        test = ["CMD" "curl" "-f" "http://127.0.0.1:5000/api/health"];
        interval = "30s";
        timeout = "5s";
        retries = 3;
        start_period = "30s";
      };

      labels = {
        "homepage.group" = "Media";
        "homepage.name" = "Kavita";
        "homepage.href" = "https://kavita.s.anthonyd.co.nz";
        "homepage.description" = "E-book and comic server";
        "homepage.icon" = "sh-kavita";
      };

      restart = "unless-stopped";
    };

    out.service.deploy.resources.limits.memory = "1gb";
  };
}
