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

    virtualHosts."budgeteur.s.anthonyd.co.nz" = {
      extraConfig = ''
        reverse_proxy localhost:8080
      '';
    };

    virtualHosts."homepage.s.anthonyd.co.nz" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  # Point caddy's env to the sops-managed secret path
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.secrets.cloudflare_api_token.path;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
