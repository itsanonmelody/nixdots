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
      version = "0.15.0-alpha.1";
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "GStreamer";
        repo = "gst-plugins-rs";
        rev = "cfe5da44cb4f5724334e1bd992fb6c4e918e3506";
        hash = "sha256-EfaYEPjVZe7xCNKVGzc+JNmO/bbmct5jhq85x3b9zN4=";
      };

      cargoHash = "sha256-U8L49O0clM6Q9qIw4XKB6gYXGPta8o6qPY2WLCbkEcw=";
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

      cargoHash = "sha256-779NyaCFtuUZJgtd7RCplqbHUvm5UTQI3z6oe+5MZIU=";

      nativeBuildInputs = with pkgs; [
        pkg-config
        boost
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
