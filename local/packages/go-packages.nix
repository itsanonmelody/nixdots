{ nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  inherit (pkgs)
    lib
    buildGoModule;
in
{
  gosumemory = buildGoModule rec {
    pname = "gosumemory";
    version = "1.3.9";
    src = pkgs.fetchFromGitHub {
      owner = "l3lackShark";
      repo = "gosumemory";
      rev = "${version}";
      sha256 = "";
    };
  };
}
