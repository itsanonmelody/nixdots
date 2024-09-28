{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  environment.systemPackages = with pkgs;
    [
      gamemode
    ];
}
