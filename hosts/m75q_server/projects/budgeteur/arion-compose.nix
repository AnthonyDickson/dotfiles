# ~/nixos-config/arion-compose.nix
{ secretPath, ... }: {
  project.name = "budgeteur-rs";

  services.web.service = {
    image = "ghcr.io/anthonydickson/budgeteur:0.30.3";

    command = [
      "server"
      "--address" "0.0.0.0"
      "--port" "8080"
      "--db-path" "/app/data/budgeteur.db"
      "--log-path" "/app/data/debug.log"
      "--timezone" "Pacific/Auckland"
      "--tui-public-keys-path" "/app/data/tui_public_keys.toml"
    ];

    ports = [ "8080:8080" ];

    # Reference the decrypted secret file rather than hardcoding the value
    env_file = [ secretPath ];

    volumes = [
      "/var/lib/budgeteur:/app/data"  # fixed path instead of ${PWD}
    ];

    healthcheck = {
      test = ["CMD" "wget" "--no-verbose" "--tries=1" "--spider" "http://127.0.0.1:8080/api/health"];
      interval = "30s";
      timeout = "5s";
      retries = 3;
      start_period = "5s";
    };

    labels = {
      "homepage.group" = "Services";
      "homepage.name" = "Budgeteur";
      "homepage.href" = "https://budgeteur.s.anthonyd.co.nz";
      "homepage.description" = "Personal budgeting app";
      "homepage.icon" = "mdi-finance";
    };

    restart = "unless-stopped";
  };
}
