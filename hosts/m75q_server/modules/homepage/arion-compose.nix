{ secretPath }:
{
  project.name = "homepage";

  services.homepage = {
    service = {
      image = "ghcr.io/gethomepage/homepage:v2.4.0";

      network_mode = "host";

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
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/:/host:ro"
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
