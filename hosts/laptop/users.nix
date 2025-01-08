{ config, lib, pkgs, ... }:
{
  imports = [
    ./home/dev.nix
  ];
  
  users.mutableUsers = false;
  users.users = {
    root = {
      isSystemUser = true;
      home = "/root";
      hashedPasswordFile = "/etc/nixos/password/root";
    };
    dev = {
      isNormalUser = true;
      home = "/home/dev";
      extraGroups = [
        "gamemode"
        "lp"
        "networkmanager"
        "scanner"
        "video"
        "wheel"
      ];
      hashedPasswordFile = "/etc/nixos/password/dev";
    };
  };
}
