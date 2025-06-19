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

    hyprland.url = "github:hyprwm/Hyprland";
    walker.url = "github:abenz1267/walker";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      catppuccin,
      walker,
      stylix,
      ...
    }@inputs:
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
            ./hosts/darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./hosts/darwin/home.nix
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
            ./hosts/nixos/configuration.nix
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
                  ./hosts/nixos/home.nix
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
            inherit inputs;
            username = username;
            hostname = "m93p";
          };
          modules = [
            ./hosts/m93p/configuration.nix
            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./hosts/m93p/home.nix
                  catppuccin.homeModules.catppuccin
                  walker.homeManagerModules.default
                ];
              };
            }
          ];
        };
      };

      # Build M75q (NixOS) flake using:
      # $ sudo nixos-rebuild build --flake .#m75q
      nixosConfigurations = {
        m75q = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            username = username;
            hostname = "m75q";
          };
          modules = [
            ./hosts/m75q/configuration.nix
            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                username = username;
              };
              home-manager.users.${username} = {
                imports = [
                  ./hosts/m75q/home.nix
                  catppuccin.homeModules.catppuccin
                  walker.homeManagerModules.default
                ];
              };
            }
          ];
        };
      };
    };
}
