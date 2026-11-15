{ pkgs, username, ... }:
{
  imports = [
    ./../../modules/home
    ./../../modules/home/nerd-fonts.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Spotlight doesn't index symlinked apps, so copy them instead.
  targets.darwin = {
    copyApps.enable = true;
    linkApps.enable = false;
  };

  # Same scheme as modules/system/stylix on NixOS.
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
  };

  programs = {
    bat.enable = true;
    btop.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    lazygit.enable = true;

    fish = {
      # Installed system-wide on NixOS by modules/system/fish.nix.
      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      loginShellInit = ''
        # Nix's PATH setup lives in /etc/zshrc, which fish doesn't read.
        fish_add_path --prepend --move /nix/var/nix/profiles/default/bin $HOME/.nix-profile/bin
        # The login shell is still zsh, so point tools that read $SHELL
        # (e.g. zellij) at fish.
        set -gx SHELL ${pkgs.fish}/bin/fish
      '';
    };

    ghostty = {
      # nixpkgs only ships the prebuilt binary on macOS.
      package = pkgs.ghostty-bin;
      settings = {
        # Start fish from Ghostty so the login shell stays zsh.
        command = "${pkgs.fish}/bin/fish --login";
        macos-option-as-alt = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "server" = {
          hostname = "100.111.59.85";
          port = 22;
          user = "anthonyd";
          identityFile = "~/.ssh/nixos_server";
          identitiesOnly = true;
        };
        "nas" = {
          hostname = "dsm.nas.anthonyd.co.nz";
          port = 22;
          user = "anthony";
          identityFile = "~/.ssh/dsm";
          identitiesOnly = true;
        };
      };
    };
  };
}
