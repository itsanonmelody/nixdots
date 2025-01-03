{ config, lib, pkgs, ... }:
{
  users.users = {
    root = {
      isSystemUser = true;
      home = "/root";
    };
    dev = {
      isNormalUser = true;
      home = "/home/dev";
      extraGroups =
        [
          "gamemode"
          "lp"
          "networkmanager"
          "scanner"
          "video"
          "wheel"
        ];
    };
  };
}
