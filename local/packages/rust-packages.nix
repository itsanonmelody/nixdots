{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  inherit (pkgs.rustPlatform)
    buildRustPackage;
in
{
  gst-plugin-spotify =
    buildRustPackage rec {
      pname = "gst-plugin-spotify";
      version = "0.14.0-alpha.1";
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "GStreamer";
        repo = "gst-plugins-rs";
        rev = "c7c71a830c27f29dc4283804b5755b57048fc660";
        sha256 = "1sfygxvxqjiwszz9dq494i34xss15sjkbx4hyfp4yjc3162a1k5n";
      };

      useFetchCargoVendor = true;
      cargoHash = "sha256-bSlt6PR0EkTvtd83Qk2XKjOLx0hUW7AObCyWaJd1aQc=";
      cargoBuildFlags = [
        "-p gst-plugin-spotify"
      ];
      cargoTestFlags = [
        "-p gst-plugin-spotify"
      ];

      nativeBuildInputs = with pkgs; [
        cargo-c
        pkg-config
      ];

      buildInputs = with pkgs; [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        openssl
      ];

      postInstall =
        ''
          chmod -R +w $out
          mkdir -p $out/lib/gstreamer-1.0
          mv $out/lib/libgstspotify.so $out/lib/gstreamer-1.0
        '';
    };
  mpris-discord-rpc =
    pkgs.callPackage ({
      pkgs,
        lastfmApiKeyFile ? "/dev/null",
        ...
    }:
    buildRustPackage rec {
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
          echo LASTFM_API_KEY=$(cat ${lastfmApiKeyFile}) > .env
        '';
    }) { };
}
