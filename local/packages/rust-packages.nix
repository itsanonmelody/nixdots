{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
in
{
  mpris-discord-rpc =
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "mpris-discord-rpc";
      version = "0.2.1";
      src = pkgs.fetchFromGitHub {
        owner = "patryk-ku";
        repo = "mpris-discord-rpc";
        tag = "v${version}";
        sha256 = "08msdnzza0fsl9gpia87p24zzhc1xwfncvmcvym8zjs2fh856ih3";
      };

      cargoHash = "sha256-PHKyzqtDWt4e9yM6iGwgvk1R/vxnjvjIwIqYN1gKzn4=";

      nativeBuildInputs = with pkgs; [
        pkg-config
      ];

      buildInputs = with pkgs; [
        dbus
        openssl
      ];

      preBuild =
        ''
          echo LASTFM_API_KEY= > .env
        '';
    };
}
