let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2893f56de08021cffd9b6b6dfc70fd9ccd51eb60.tar.gz") { };
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
