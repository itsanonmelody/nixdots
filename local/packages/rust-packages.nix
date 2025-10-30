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
  music-discord-rpc =
    pkgs.callPackage ({
      pkgs,
        lastfmApiKeyFile ? "/dev/null",
        ...
    }:
    buildRustPackage rec {
      pname = "music-discord-rpc";
      version = "0.6.2";
      src = pkgs.fetchFromGitHub {
        owner = "patryk-ku";
        repo = "${pname}";
        tag = "v${version}";
        hash = "sha256-Sc7K9xD+l48w5xXLWjSsw1eq+x0xP8QHMioPaulPP2E=";
      };

      cargoHash = "sha256-nHG6W6WbMNVmsnG1f5o0obp5SEUI4UIyyJDvgS6sUzA=";

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
