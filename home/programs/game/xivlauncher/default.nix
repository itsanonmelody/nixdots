{ pkgs, ... }:
{
  # Required for auto login.
  home.packages = [ pkgs.keepassxc ];
  
  programs.xivlauncher = {
    enable = true;
    useGamemode = true;
    winePackage = pkgs.wineWowPackages.stableFull;
    settings = {
      isAutologin = true;
      clientLanguage = "German";
      isIgnoringSteam = true;
      dxvkAsyncEnabled = true;
      eSyncEnabled = true;
      fSyncEnabled = true;
      dxvkHudType = "Fps";
      dalamudEnabled = false;
    };
  };
}
