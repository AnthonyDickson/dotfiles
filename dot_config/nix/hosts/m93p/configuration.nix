# Config for my Lenovo M93p Tiny server
#
# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, username, ... }:

{ imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "m93p"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/"; networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = { LC_ADDRESS = "en_NZ.UTF-8"; LC_IDENTIFICATION = "en_NZ.UTF-8"; LC_MEASUREMENT = "en_NZ.UTF-8"; LC_MONETARY = "en_NZ.UTF-8"; LC_NAME = "en_NZ.UTF-8"; LC_NUMERIC = "en_NZ.UTF-8"; LC_PAPER = 
    "en_NZ.UTF-8"; LC_TELEPHONE = "en_NZ.UTF-8"; LC_TIME = "en_NZ.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = { layout = "us"; variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    # packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwdgNUV5+JjsTN90SG/UxMSjbP3i/aO+kzsUW0CW4F41Nb7PYCvjXNkrx/OGNrKkaOpzlFONL3B6k0Dcf81cIXtkjFFG1ebiTHP2VCt9EmZKA/9dCR68t26HRMFVLy8ynDj+MnR7h0MNJTMeHuL1mve9rZau+qGIDQwzWlamqaHZt74aBCqjMRJudLDzRQYrkewU7k7LvdNyG/GtEV7Hk4lxv1j83k9RrAeIuGBHSpNa3+lhThTSv5OOiFk1J5TFZKdS+FJngxYyGczWNijw/5tmLCaNP4uMVR01L7JHRTzWwuLzUROH5PbOd4NDD94iEJsEh8R8XKPKSrhYbiPxJvT/xQwNzQimlgUSOII9mBL3tnJFWBVnjtAphVl83k8rQT7VhELp+e/EStuAslX6g3oKSeQtuPM0WaJpeFkXVwoqzfv0XvnqNzlA75P6vQEL12+/GhorsE/HTjBVtPg5db7axAzWYV8B3+Cwa58ogKTlt4A7BFgLS7M1ZRkZc1fz3xMQJublNHqtxlj8vOGcLbb5/NaKlJ7xsSxzrU/U9oEU0aAp9OR76LnK2Uu51MuF+UU4f+cOsrHoZFfTTU6c3OcYM3C9R9hhx4ocpI+iPOAMK21LmVVAIcDiOZz78rFFL45dpvBMa/H7V7kidFYFpmRA2eKqx8peIMj5ou/ZI/tw== anthony@anthonys-macbook-pro.persian-hake.ts.net"
    ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = username;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    cargo
    (python3.withPackages (ps: with ps; [
      pip
      setuptools
    ]))
    nodejs

    git
    gh
    lazygit
    chezmoi
    unzip
    fd
    fzf
    ripgrep
    wget
    neovim

    lsd
    dust
    duf
    tealdeer
    bat
    btop

    cloudflared
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cm = "chezmoi";
      lg = "lazygit";
      l = "lsd";
      update = "sudo nixos-rebuild switch";
    };

    histSize = 10000;
  };

  # List services that you want to enable:
  services.tailscale.enable = true;

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      # The key below is a one-off key, if it does not work generate a new one at https://login.tailscale.com/admin/settings/keys
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kjLcGYyE7211CNTRL-DXsLGV42Uj5DFuuFVAcJj5RYCFwAFy1bW
    '';
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    # Always allow traffic from tailscale network
    trustedInterfaces = [ "tailscale0" ];
    # Allow HTTP and HTTPS traffic over public internet. 
    allowedTCPPorts = [ 80 443 ];
  };

  # Makes brute force attacks for guessing credentials difficult.
  services.fail2ban.enable = true;

  # Start preconfigured cloudflared tunnel.
  #
  # For details on how to configure a tunnel, see:
  # https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel/
  systemd.services.cloudflared-tunnel = {
    wantedBy = [ "multi-user.target"];
    after = [ "network.target" ];
    description = "cloudflared tunnel for anthonydickson.com.";
    serviceConfig = {
      Type = "notify";
      User = "anthony";
      ExecStart = ''${pkgs.cloudflared}/bin/cloudflared tunnel run m93p'';
    };
  };

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [ ... ]; Or disable the firewall altogether. networking.firewall.enable = false;

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and database versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the 
  # release version of the first install of this system. Before changing this value read the documentation for this option (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}

