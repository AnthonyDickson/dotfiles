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

    # System-wide styling/theming
    stylix = {
      url = "github:danth/stylix";
    };

    # Declarative Homebrew management
    nix-homebrew = { url = "github:zhaofengli-wip/nix-homebrew"; };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, home-manager, stylix, nix-homebrew, catppuccin, ... }: 
    let
      username = "anthony";
    in {
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
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { username = username; };
            home-manager.users.${username} = {
              imports = [
                ./hosts/darwin/home.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
    };

    # Build NixOS flake using:
    # $ darwin-rebuild build --flake .#nixos
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { username = username; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { username = username; };
            home-manager.users.${username} = import ./hosts/nixos/home.nix;
          }
          stylix.nixosModules.stylix
        ];
      };
    };

    # Build M93p (NixOS) flake using:
    # $ darwin-rebuild build --flake .#m93p
    nixosConfigurations = {
      m93p = nixpkgs.lib.nixosSystem {
        specialArgs = {
            username = username;
          };
        modules = [
          ./hosts/m93p/configuration.nix
          catppuccin.nixosModules.catppuccin
        ];
      };
    };
  };
}
