{
  description = "Melody's Nix Flake for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/laptop/configuration.nix
      ];
    };
  };
}
