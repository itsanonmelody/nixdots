{ config, lib, pkgs, ... }:
{
  imports = [
    <home-manager/nixos>
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
      extraGroups =
        [
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
        imports = [ ./home/root.nix ];
      };
      dev = {
        imports = [ ./home/dev.nix ];
      };
    };
  };
}
