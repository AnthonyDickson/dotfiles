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
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager, stylix }: {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#darwin
    darwinConfigurations = {
      darwin = nix-darwin.lib.darwinSystem {
        modules = [ 
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.anthony = import ./hosts/darwin/home.nix;
          }
        ];
      };
    };

    # Build NixOS flake using:
    # $ darwin-rebuild build --flake .#nixos
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.anthony = import ./hosts/nixos/home.nix;
          }
          stylix.nixosModules.stylix
        ];
      };
    };

    # Build M93p (NixOS) flake using:
    # $ darwin-rebuild build --flake .#m93p
    nixosConfigurations = {
      m93p = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/m93p/configuration.nix
        ];
      };
    };
  };
}
