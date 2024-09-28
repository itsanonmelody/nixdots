{ osConfig, lib, pkgs, ... }:
lib.warnIf (!osConfig.programs.gamemode.enable)
  ''
    Feral's GameMode CPU optimisations are required to run XIVLauncher.Core optimally!
    To enable it, add the following option in the NixOS configuration:
      > programs.gamemode.enable = true;
  ''
{
  home.packages = with pkgs;
    [
      # Required for auto login.
      keepassxc
      wineWowPackages.stableFull
      xivlauncher
    ];

  nixpkgs.overlays = [
    (if (osConfig.programs.gamemode.enable)
      then
      (final: prev: {
        xivlauncher = prev.xivlauncher.overrideAttrs {
          # XIVLauncher requires libgamemodeauto.o.0 to enable
          # Feral's GameMode CPU optimisations.
          desktopItems = [
            # Taken from https://github.com/NixOS/nixpkgs/blob/nixos-24.05/pkgs/by-name/xi/xivlauncher/package.nix
            (pkgs.makeDesktopItem {
              name = "xivlauncher";
              exec = "gamemoderun XIVLauncher.Core";
              icon = "xivlauncher";
              desktopName = "XIVLauncher";
              comment = prev.xivlauncher.meta.description;
              categories = [ "Game" ];
              startupWMClass = "XIVLauncher.Core";
            })
          ];
        };
      })
      else (_: _: {}))
  ];
}
