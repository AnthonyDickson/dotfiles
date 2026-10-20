{
  # Rootless only: the system daemon's docker group is root-equivalent.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
