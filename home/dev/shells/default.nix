{ pkgs, ...}:
{
  home.packages = [
    (pkgs.writeShellScriptBin "nix-shelld"
      ''
        nix-shell "${./.}/$1"
      '')
  ];
}
