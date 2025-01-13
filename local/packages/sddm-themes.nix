{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
{
  eucalyptus-drop = stdenv.mkDerivation rec {
    pname = "sddm-eucalyptus-drop";
    version = "2.0.0";
    src = pkgs.fetchFromGitLab {
      owner = "Matt.Jolly";
      repo = "sddm-eucalyptus-drop";
      rev = "c80e4fc24f229c21718d22ea7c498ccc3f54a4f7";
      sha256 = "03chmcpzzmqaf6ikcpl31hr53jd9iazp7wn11bxf9dc78gfrbbn2";
    };

    dontBuild = true;
    installPhase =
      ''
        mkdir -p $out/share/sddm/themes
        cp -R $src $out/share/sddm/themes/eucalyptus-drop
      '';
  };
}
