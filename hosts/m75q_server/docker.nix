{ pkgs, config, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.arion.backend = "docker";

  # Install sops and age CLI tools for managing secrets
  environment.systemPackages = with pkgs; [
    sops
    age
    arion
  ];

  imports = [ ./sops.nix ];
  virtualisation.arion.projects = {
    budgeteur.settings.imports = [
      (import ./projects/budgeteur/arion-compose.nix {
        secretPath = config.sops.secrets.budgeteur-env.path;
      })
    ];
  };
}
