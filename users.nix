{ config, lib, pkgs, ... }:
let
  user-secrets = import ./user-secrets.nix;
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
  imports = [
    <home-manager/nixos>
  ];

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

  home-manager = {
    # Home Manager conflicts with Firefox UWU
    backupFileExtension = "backup-" + lib.readFile "${
      pkgs.runCommand "timestamp" {
        env.when = builtins.currentTime;
      }
      "echo -n `date -d @$when +%Y%m%d%H%M%S` > $out"
    }";
    extraSpecialArgs = { local = import ./local; };
    users = {
      root = {
        imports = [ ./home/root ];
      };
      dev = {
        imports = [ ./home/dev ];
      };
    };
  };
}
