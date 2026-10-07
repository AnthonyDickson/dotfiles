{ secretPath }:
{
  project.name = "paperless";

  services.broker = {
    service = {
      image = "redis:8.8.0-alpine";
      hostname = "paperless-redis";

      sysctls = {
        "net.core.somaxconn" = "511";
      };

      volumes = [
        "/var/lib/paperless/redis:/data"
      ];

      restart = "unless-stopped";
    };
  };

  services.webserver = {
    service = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.15";

      ports = [ "8777:8000" ];

      depends_on = [
        "broker"
        "gotenberg"
        "tika"
      ];

      # Expected to define PAPERLESS_ADMIN_PASSWORD and PAPERLESS_SECRET_KEY
      env_file = [ secretPath ];

      environment = {
        USERMAP_UID = "1000";
        USERMAP_GID = "100";

        PAPERLESS_ADMIN_USER = "anthony";
        PAPERLESS_ADMIN_MAIL = "admin@anthond.co.nz";

        PAPERLESS_REDIS = "redis://paperless-redis:6379";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";

        PAPERLESS_TIME_ZONE = "Pacific/Auckland";
        PAPERLESS_URL = "https://paperless.s.anthonyd.co.nz";
        PAPERLESS_ALLOWED_HOSTS = "paperless.s.anthonyd.co.nz";
        PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.s.anthonyd.co.nz";
        # Caddy runs on the host; the container sees the Docker bridge gateway
        PAPERLESS_TRUSTED_PROXIES = "172.16.0.0/12";

        PAPERLESS_FILENAME_FORMAT = "{{created_year}}/{{correspondent}}/{{created}} {{title}}";
        PAPERLESS_ENABLE_UPDATE_CHECK = "enable";
        PAPERLESS_OCR_LANGUAGES = "eng";
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
        PAPERLESS_OPTIMIZE_THUMBNAILS = "false";
        PAPERLESS_TASK_WORKERS = "2";
        PAPERLESS_THREADS_PER_WORKER = "2";
        PAPERLESS_EMAIL_TASK_CRON = "disable";
      };

      volumes = [
        "/var/lib/paperless/data:/usr/src/paperless/data"
        "/var/lib/paperless/media:/usr/src/paperless/media"
        "/var/lib/paperless/export:/usr/src/paperless/export"
        "/var/lib/paperless/consume:/usr/src/paperless/consume"
      ];

      healthcheck = {
        test = [ "CMD" "curl" "-fs" "-S" "--max-time" "2" "http://localhost:8000" ];
        interval = "30s";
        timeout = "10s";
        retries = 5;
      };

      labels = {
        "homepage.group" = "Productivity";
        "homepage.name" = "Paperless-ngx";
        "homepage.href" = "https://paperless.s.anthonyd.co.nz";
        "homepage.description" = "Document management";
        "homepage.icon" = "sh-paperless-ngx";
      };

      restart = "unless-stopped";
    };

    out.service.deploy.resources.limits = {
      cpus = "2.0";
      memory = "2gb";
    };
  };

  services.gotenberg.service = {
    image = "gotenberg/gotenberg:8.34.0";

    command = [
      "gotenberg"
      "--chromium-disable-javascript=true"
      "--chromium-allow-list=file:///tmp/.*"
    ];

    restart = "unless-stopped";
  };

  services.tika.service = {
    image = "apache/tika:3.3.1.0";

    restart = "unless-stopped";
  };
}
