{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
    ] ++ (with pkgs; [
      git
      sbcl
    ]);
  };
}
