let
    pkgs = import <nixos-unstable/nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs;
    [
      verilog
      gtkwave
      yosys
      graphviz
    ];
}
