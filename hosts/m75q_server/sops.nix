{ ... }: {
  sops = {
    defaultsSopsFormat = "dotenv";

    # Tell sops-nix to use the server's SSH host key for decryption
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.budgeteur-env = {
      sopsFile = ./projects/budgeteur/secrets.env;
    };

    secrets.cloudflare_api_token = {
      sopsFile = ./cloudflare_secrets.env;
      owner ="caddy";
    };
  };
}
