{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
{
  nier-cursors = stdenv.mkDerivation rec {
    pname = "nier-cursors";
    version = "2020-08-25";
    src = pkgs.fetchzip {
      url = "https://github.com/Beinsezii/NieR-Cursors/releases/download/${version}/Nier_Cursors_${version}.tar.xz";
      sha256 = "1f28hcv1byq22scsf486zxqspsydv07i653gcvc423c9fx131h3b";
    };

    dontBuild = true;
    installPhase =
      ''
        runHook preInstall

        mkdir -p $out/share/icons/nier-cursors
        cp -r $src/* $out/share/icons/nier-cursors

        runHook postInstall
      '';
  };
}
