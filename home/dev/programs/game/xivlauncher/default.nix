{ pkgs, ... }:
{
  home.packages = with pkgs;
    [
      # Required for auto login.
      keepassxc
      wineWowPackages.stable
      xivlauncher
    ];
}
