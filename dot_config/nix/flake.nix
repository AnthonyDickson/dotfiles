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
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager }: {
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

    nixosConfigurations = {
      nix = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/nix/configuration.nix
        ];
      };
    };
  };
}
