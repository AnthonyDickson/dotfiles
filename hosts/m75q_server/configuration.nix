{ config, pkgs, ... }:

let
  ports = {
    ssh = 22;
    dns = 53;
    unbound = 5353;
    http = 80;
    https = 443;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./projects/homepage/homepage-config.nix
  ];

  # NFS mount for NAS media
  services.rpcbind.enable = true;

  fileSystems."/mnt/media" = {
    device = "192.168.0.10:/volume1/data/media";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "intr" ];
  };

  fileSystems."/mnt/backups" = {
    device = "192.168.0.10:/volume1/server_backup";
    fsType = "nfs";
    options = [ "nfsvers=4.1" "noatime" "hard" "intr" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "SERVER-A"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."anthonyd" = {
    isNormalUser = true;
    description = "Anthony Dickson";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINygoylEUyT2/RFaPKwugriJP9ZvDTB7KropfmhpHBht anthony@m75q"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLcXHe9+g2j9F6EavUQLw3A5XhoX5NXlj/0R41aff46 anthony@Anthonys-MacBook-Pro.local"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Create Jellyfin state directories at boot
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/config 0755 1000 303 -"
    "d /var/lib/jellyfin/cache 0755 1000 303 -"
    "d /var/backup 0755 root root -"
    "d /var/log/backups 0755 root root -"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    yazi
    nixd
    fzf
    btop
    bat
    git
    lazygit
    lsd
    duf
    dust
    starship
    zellij
    # Install sops and age CLI tools for managing secrets
    sops
    age
    arion
  ];

  environment.enableAllTerminfo = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.bash = {
    interactiveShellInit = ''
      # Auto CD to last opened dir
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      # fzf support
      source ${pkgs.fzf}/share/fzf/completion.bash
      source ${pkgs.fzf}/share/fzf/key-bindings.bash

      # Starship prompt
      # Only use symbols if we are NOT in a native Linux TTY
      if [ "$TERM" = "linux" ]; then
        eval "$(starship init bash --print-full-init)"
        export STARSHIP_CONFIG=/etc/starship-tty.toml
      else
        eval "$(starship init bash)"
      fi
    '';
  };

  # Write a simplified text-only configuration specifically for the TTY screen
  environment.etc."starship-tty.toml".text = ''
    format = "$all"
    [character]
    success_symbol = "[>](bold green)"
    error_symbol = "[x](bold red)"
  '';

  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/nixos_config
      IdentitiesOnly yes
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ ports.ssh ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--advertise-routes=192.168.0.0/24" ];
    extraSetFlags = [ "--accept-dns=false" ];
  };

  # DNS
  # ---

  services.dnsmasq = {
    enable = true;
    settings = {
      address = [
        "/anthonyd.co.nz/192.168.0.10"
        "/s.anthonyd.co.nz/192.168.0.20"
      ];
      server = [ "127.0.0.1#${toString ports.unbound}" ];
    };
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        port = ports.unbound;
        interface = [ "127.0.0.1" ];
      };
      remote-control = {
        control-enable = true;
        control-interface = [ "127.0.0.1" ]; # Restrict to localhost
      };
    };
  };

  # Secrets
  # -------

  sops = {
    defaultSopsFormat = "dotenv";

    # Tell sops-nix to use the server's SSH host key for decryption
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.budgeteur-env = {
      sopsFile = ./projects/budgeteur/secrets.env;
    };

    secrets.cloudflare_api_token = {
      sopsFile = ./cloudflare_secrets.env;
      owner = "caddy";
    };

    # Authelia — each secret is exposed as a file path that Authelia
    # reads at runtime via the _FILE environment variables set by the module.
    secrets.authelia-jwt = {
      sopsFile = ./authelia_secrets.yaml;
      format = "yaml";
      key = "AUTHELIA_JWT_SECRET";
      owner = "authelia-main";
    };
    secrets.authelia-session = {
      sopsFile = ./authelia_secrets.yaml;
      format = "yaml";
      key = "AUTHELIA_SESSION_SECRET";
      owner = "authelia-main";
    };
    secrets.authelia-storage-key = {
      sopsFile = ./authelia_secrets.yaml;
      format = "yaml";
      key = "AUTHELIA_STORAGE_ENCRYPTION_KEY";
      owner = "authelia-main";
    };
    secrets.authelia-user-anthonyd-hash = {
      sopsFile = ./authelia_secrets.yaml;
      format = "yaml";
      key = "AUTHELIA_USER_ANTHONYD_HASH";
      owner = "authelia-main";
    };
  };

  # sops template — inject the password hash into a users.yml at activation
  # time. The plaintext hash never touches the Nix store.
  sops.templates."authelia-users.yml" = {
    owner = "authelia-main";
    path = "/var/lib/authelia-main/users.yml";
    content = ''
      users:
        anthonyd:
          displayname: "Anthony Dickson"
          password: "${config.sops.placeholder.authelia-user-anthonyd-hash}"
          email: anthony.dickson9656@gmail.com
          groups:
            - admins
    '';
  };

  # Docker
  # -------

  virtualisation.docker.enable = true;
  virtualisation.arion.backend = "docker";

  services.homepage-config.enable = true;

  virtualisation.arion.projects = {
    budgeteur.settings.imports = [
      (import ./projects/budgeteur/arion-compose.nix {
        secretPath = config.sops.secrets.budgeteur-env.path;
      })
    ];

    homepage.settings.imports = [
      (import ./projects/homepage/arion-compose.nix { })
    ];

    jellyfin.settings.imports = [
      (import ./projects/jellyfin/arion-compose.nix { })
    ];
  };

  # Reverse Proxy
  # -------------

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-8yZDrejNKsaUnUaTUFYbarWNmxafqp2z2rWo+XRsxV8=";
    };

    globalConfig = ''
      email anthony.dickson9656@gmail.com

      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';

    extraConfig = ''
      (authelia) {
        forward_auth localhost:9091 {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }
      }
    '';

    virtualHosts = {
      # Authelia portal — no auth guard on this one
      "auth.s.anthonyd.co.nz" = {
        extraConfig = ''
          reverse_proxy localhost:9091
        '';
      };

      "budgeteur.s.anthonyd.co.nz" = {
        extraConfig = ''
          import authelia
          reverse_proxy localhost:8080
        '';
      };

      "homepage.s.anthonyd.co.nz" = {
        extraConfig = ''
          import authelia
          reverse_proxy localhost:3000
        '';
      };

      "jellyfin.s.anthonyd.co.nz" = {
        extraConfig = ''
          reverse_proxy localhost:8096
        '';
      };
    };
  };

  # Point caddy's env to the sops-managed secret path
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.secrets.cloudflare_api_token.path;
  };

  # Auth
  # ----

  services.authelia.instances.main = {
    enable = true;

    # The module sets the _FILE environment variables that Authelia reads
    # at startup for secrets — no plaintext secrets reach the Nix store.
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia-jwt.path;
      sessionSecretFile = config.sops.secrets.authelia-session.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia-storage-key.path;
    };

    settings = {
      theme = "dark";

      authentication_backend.file = {
        path = "/var/lib/authelia-main/users.yml";
        watch = true;
      };

      session = {
        name = "authelia_session";
        expiration = "1h";
        inactivity = "5m";
        cookies = [{
          domain = "s.anthonyd.co.nz";
          authelia_url = "https://auth.s.anthonyd.co.nz";
        }];
      };

      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      totp = {
        issuer = "anthonyd.co.nz";
        period = 30;
        skew = 1;
      };

      webauthn = {
        display_name = "Anthony's Server";
        attestation_conveyance_preference = "indirect";
        selection_criteria = {
          user_verification = "preferred";
        };
      };

      # Filesystem notifier: enrollment links are written to a local file.
      # Replace with SMTP once Stalwart is set up.
      notifier.filesystem.filename =
        "/var/lib/authelia-main/notifications.txt";

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "budgeteur.s.anthonyd.co.nz";
            policy = "bypass";
            resources = ["^/api.*$"];
          }
          {
            domain = "*.s.anthonyd.co.nz";
            policy = "two_factor";
          }
        ];
      };
    };
  };

  # Firewall
  # --------

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [
      ports.dns
      ports.http
      ports.https
    ];
    allowedTCPPorts = [
      ports.dns
      ports.http
      ports.https
    ];
  };

  # Ensure Jellyfin only starts after the NFS media mount is available
  systemd.services.arion-jellyfin = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };

  # Backup
  # ------

  systemd.services.server-backup = let
    backupScript = pkgs.writeShellScriptBin "server-backup" ''
      set -euo pipefail

      STAGING=/var/backup
      NAS=/mnt/backups

      if ! grep -q " /mnt/backups " /proc/mounts; then
        echo "Backup NFS mount not available"
        exit 1
      fi

      mkdir -p "$NAS"
      rm -rf "$STAGING"/*
      mkdir -p "$STAGING"/{budgeteur,authelia,jellyfin,homepage}

      echo "Dumping Budgeteur database..."
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/budgeteur/budgeteur.db \
        ".backup $STAGING/budgeteur/budgeteur.db"

      echo "Dumping Authelia database..."
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/authelia-main/db.sqlite3 \
        ".backup $STAGING/authelia/db.sqlite3"

      echo "Linking Jellyfin config..."
      cp -al /var/lib/jellyfin/config/* "$STAGING/jellyfin/" || true

      echo "Linking Homepage config..."
      cp -al /var/lib/homepage/config/* "$STAGING/homepage/" || true

      LOGDIR=/var/log/backups
      mkdir -p "$LOGDIR"
      LOGFILE="$LOGDIR/$(date +%Y-%m-%d_%H-%M-%S).log"

      echo "Syncing to NAS (log: $LOGFILE)..."
      ${pkgs.rsync}/bin/rsync -rltD --chmod=D755,F644 --delete --stats \
        "$STAGING"/ "$NAS"/ > "$LOGFILE" 2>&1

      echo "Backup complete"
    '';
  in {
    description = "Stage and sync server backups to NAS";
    after = [ "mnt-backups.mount" "network-online.target" ];
    wants = [ "mnt-backups.mount" "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${backupScript}/bin/server-backup";
    };
  };

  systemd.timers.server-backup = {
    description = "Daily server backup to NAS";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = 600;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
