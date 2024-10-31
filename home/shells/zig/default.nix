let
  pkgs = import <nixos-unstable/nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs;
    [
      git
      zig
      zls
      gdb
    ];
}
