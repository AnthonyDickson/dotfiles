{ ... }: {
  sops = {
    # Tell sops-nix to use the server's SSH host key for decryption
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.budgeteur-env = {
      sopsFile = ./projects/budgeteur/secrets.env;
      format = "dotenv";
      path = "/run/secrets/budgeteur.env";
    };
  };
}
