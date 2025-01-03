{ config, lib, pkgs, ... }:
let
  user-secrets = builtins.fromTOML (builtins.readFile ./user-secrets.toml);
  getUserPassword = user:
    if (builtins.hasAttr "password" user-secrets.${user})
      && !(builtins.hasAttr "hashedPassword" user-secrets.${user})
    then user-secrets.${user}.password
    else null;
  getUserHashedPassword = user:
    if (builtins.hasAttr "hashedPassword" user-secrets.${user})
    then user-secrets.${user}.hashedPassword
    else null;
in
{
  users.mutableUsers = false;
  users.users = {
    root = {
      isSystemUser = true;
      home = "/root";
      password = getUserPassword "root";
      hashedPassword = getUserHashedPassword "root";
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
      password = getUserPassword "dev";
      hashedPassword = getUserHashedPassword "dev";
    };
  };
}
