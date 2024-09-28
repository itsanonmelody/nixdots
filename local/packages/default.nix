let
  pkgs = import <nixpkgs> { };
in
with pkgs;
{
  plover = callPackage ./plover { };
}
