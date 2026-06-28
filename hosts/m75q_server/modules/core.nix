{ pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Time zone
  time.timeZone = "Pacific/Auckland";

  # Internationalisation
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

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User account
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

  # Nix settings
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

  # System packages
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
    sops
    age
    arion
  ];

  environment.enableAllTerminfo = true;

  # Default editor
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Bash interactive shell setup
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

  # Text-only starship config for TTY
  environment.etc."starship-tty.toml".text = ''
    format = "$all"
    [character]
    success_symbol = "[>](bold green)"
    error_symbol = "[x](bold red)"
  '';

  # SSH — GitHub-specific key
  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/nixos_config
      IdentitiesOnly yes
  '';

  # OpenSSH daemon
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # SOPS base config — per-service secrets are in their respective modules
  sops.defaultSopsFormat = "dotenv";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
