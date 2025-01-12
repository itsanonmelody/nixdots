{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
{
  minimal-nixos = stdenv.mkDerivation {
    pname = "minimal-nixos-grub-theme";
    version = "cefbbf6";
    src = pkgs.fetchFromGitHub {
      owner = "MrVivekRajan";
      repo = "Grub-Themes";
      rev = "cefbbf6a13b9bb3405c66219a5b4ead5d4f31fca";
      sha256 = "0x9qnnzwanh11mhnikv6r1rwpc8xk70pr9py89snsrf55g4ndwb7";
    };
    
    dontBuild = true;
    installPhase =
      ''
        mkdir -p $out/grub/themes
        cp -R $src/Minimal/NIXOS $out/grub/themes/minimal-nixos
      '';
  };
}
