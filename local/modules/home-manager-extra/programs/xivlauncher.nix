{ config, osConfig, lib, pkgs, ... }:
let
  cfg = config.programs.xivlauncher;
in
with lib;
{
  options.programs.xivlauncher = {
    enable = mkEnableOption "XIVLauncher";
    useGamemode = mkEnableOption "Feral's GameMode CPU optimisations";
    useSteamRun = mkEnableOption "Steam Runtime";
  };

  config = mkIf cfg.enable {
    assertions = lists.optional cfg.useGamemode
      {
        assertion = osConfig.programs.gamemode.enable;
        message = ''
          The 'gamemode' package is required to enable Feral's GameMode
          CPU optimisations for XIVLauncher! To enable it, add the following
          option in your NixOS configuration:
          > programs.gamemode.enable = true;
        '';
      };

    programs.xivlauncher.useSteamRun = mkDefault true;

    home.packages = [
      (pkgs.xivlauncher.override {
        useSteamRun = cfg.useSteamRun;
      })
    ];

    nixpkgs.overlays = lists.optional cfg.useGamemode
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
      });
  };
}
