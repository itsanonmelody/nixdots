{
  description = "Melody's Nix Flake for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs }:
    let
      local = import ./local;
    in
      {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; inherit local; };
      modules = [
        ./hosts/laptop/configuration.nix
      ];
    };
  };
}
