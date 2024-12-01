let
  pkgs = import <nixos-unstable/nixpkgs> {};
in
pkgs.mkShellNoCC {
  packages = with pkgs;
    [
      typst
      tinymist
    ];
}