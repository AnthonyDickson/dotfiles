{
  description = "My NixOS system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    # TODO: Re-enable Walker once nix.flake is added back
    # walker.url = "github:abenz1267/walker";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      # TODO: Re-enable Walker once nix.flake is added back
      # walker,
      stylix,
      ...
    }@inputs:
    let
      username = "anthony";
    in
    {
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
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                username = username;
                mainMonitor = "DP-1";
                secondaryMonitor = "desc:AOC Q27G2G4 0x0000175D";
              };
              home-manager.users.${username} = {
                imports = [
                  ./hosts/m75q/home.nix
                  # TODO: Re-enable Walker once nix.flake is added back
                  # walker.homeManagerModules.default
                ];
              };
            }
          ];
        };
      };
    };
}
