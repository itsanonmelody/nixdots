{ pkgs, ... }:
{
  home.packages = with pkgs;
    [
      # Required for auto login.
      keepassxc
      wineWowPackages.stableFull
    ];
  
  programs.xivlauncher = {
    enable = true;
    useGamemode = true;
  };
}
