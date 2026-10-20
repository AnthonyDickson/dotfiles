{ secretPath }:
{
  project.name = "homepage";

  # Gives Homepage read-only access to the container endpoints it uses, instead
  # of the Docker socket itself, which would let it control the host as root.
  # Homepage reaches it through a unix socket, so nothing listens on TCP.
  services.docker-proxy = {
    service = {
      image = "wollomatic/socket-proxy:1.13.1";

      # nobody, in the docker group to open the Docker socket
      user = "65534:131";
      network_mode = "none";
      capabilities.ALL = false;

      command = [
        "-proxysocketendpoint=/run/docker-proxy/docker.sock"
        # Group-accessible so Homepage, also in the docker group, can connect
        "-proxysocketendpointfilemode=0660"
        # Container list, inspect (status and health) and stats
        "-allowGET=(/v1\\.[0-9]+)?/containers/(json|[a-zA-Z0-9_.-]+/(json|stats))"
        "-allowhealthcheck"
        "-watchdoginterval=3600"
        "-stoponwatchdog"
        "-shutdowngracetime=5"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/run/homepage-docker:/run/docker-proxy"
      ];

      healthcheck = {
        test = [ "CMD" "./healthcheck" ];
        interval = "30s";
        timeout = "5s";
        retries = 2;
      };

      restart = "unless-stopped";
    };

    out.service = {
      read_only = true;
      security_opt = [ "no-new-privileges" ];
      deploy.resources.limits.memory = "64mb";
    };
  };

  services.homepage = {
    service = {
      image = "ghcr.io/gethomepage/homepage:v2.4.0";

      network_mode = "host";

      depends_on = [ "docker-proxy" ];

      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "homepage.s.anthonyd.co.nz";
        PUID = "1000";
        PGID = "131";

        HOMEPAGE_AUTH_ENABLED = "true";
        HOMEPAGE_EXTERNAL_URL = "https://homepage.s.anthonyd.co.nz";
        HOMEPAGE_OIDC_ISSUER = "https://auth.s.anthonyd.co.nz";
        HOMEPAGE_OIDC_CLIENT_ID = "homepage";
        HOMEPAGE_OIDC_NAME = "Authelia";
        HOMEPAGE_OIDC_SCOPE = "openid email profile";
      };

      # Expected to define HOMEPAGE_AUTH_SECRET and HOMEPAGE_OIDC_CLIENT_SECRET
      env_file = [ secretPath ];

      volumes = [
        "/var/lib/homepage/config:/app/config"
        "/var/lib/homepage/config/images:/app/public/images"
        "/run/homepage-docker:/run/docker-proxy:ro"
        # Any directory on the root filesystem gives the disk widget its usage,
        # without exposing the host's files
        "/var/lib/homepage/rootfs:/host:ro"
        "/sys:/sys:ro"
      ];

      restart = "unless-stopped";
    };

    out.service.deploy.resources.limits = {
        cpus = "1.0";
        memory = "256mb";
      };
    };
}
