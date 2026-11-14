{ config, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.arion.backend = "docker";

  # Each image tag bump leaves the old image behind. This removes images that
  # no container uses; --all, because those images are still tagged and so
  # are not "dangling". It leaves containers alone, unlike
  # virtualisation.docker.autoPrune (`docker system prune`), which would also
  # remove a stopped service's container and with it the image.
  systemd.services.docker-image-prune = {
    description = "Remove Docker images that no container uses";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.virtualisation.docker.package}/bin/docker image prune --all --force";
    };
    startAt = "weekly";
  };
}
