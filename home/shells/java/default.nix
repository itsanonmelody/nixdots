let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs;
    [
      git
      jdk
      gradle
    ];
}
