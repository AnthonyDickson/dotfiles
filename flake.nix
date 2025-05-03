{
  description = "My NixOS and Darwin system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Homebrew management
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    inputs@{
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      catppuccin,
      ...
    }:
    let
      username = "anthony";
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#darwin
      darwinConfigurations = {
        darwin = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            username = username;
          };
          modules = [
            ./darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./darwin/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
          ];
        };
      };

      # Build NixOS flake using:
      # $ sudo nixos-rebuild build --flake .#nixos
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            username = username;
          };
          modules = [
            ./nixos/configuration.nix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./nixos/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
      };

      # Build M93p (NixOS) flake using:
      # $ sudo nixos-rebuild build --flake .#m93p
      nixosConfigurations = {
        m93p = nixpkgs.lib.nixosSystem {
          specialArgs = {
            username = username;
          };
          modules = [
            ./m93p/configuration.nix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./m93p/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
      };
    };
}
