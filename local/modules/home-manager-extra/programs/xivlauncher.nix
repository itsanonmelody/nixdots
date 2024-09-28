{ config, osConfig, lib, pkgs, ... }:
let
  inherit (lib) generators lists types;
  inherit (lib) mkIf;
  inherit (lib.options) mkOption mkPackageOption;

  cfg = config.programs.xivlauncher;

  homeDir = config.home.homeDirectory;

  toUpperFirst = str:
    let
      inherit (builtins) stringLength substring;
      inherit (lib.strings) toUpper;
      len = stringLength str;
    in
      if (len < 2) then (toUpper str)
      else let
        firstChar = substring 0 1 str;
        rest = substring 1 (len - 1) str;
      in "${toUpper firstChar}${rest}";

  mkKeyValue = k: v:
    generators.mkKeyValueDefault {} "=" (toUpperFirst k) v;

  toINI = generators.toINIWithGlobalSection { inherit mkKeyValue; };
  
  mkEnableOption = name: defaultValue:
    mkOption {
      type = types.bool;
      default = defaultValue;
      example = true;
      description = "Whether to enable ${name}.";
    };

  mkDisableOption = name: defaultValue:
    mkOption {
      type = types.bool;
      default = defaultValue;
      example = true;
      description = "Whether to disable ${name}.";
    };

  xivlauncherSettings = with types;
    submodule {
      options = {
        # Hidden configurations
        acceptLanguage = mkOption {
          type = str;
          default = "ja";
        };
        isAutologin = mkEnableOption "auto login" false;
        completedFts = mkEnableOption "FTS" false;
        doVersionCheck = mkEnableOption "version check" true;
        fontPxSize = mkOption {
          type = ints.unsigned;
          default = 22;
        };
        isEncryptArgs = mkEnableOption "encrypted arguments" true;
        globalScale = mkOption {
          type = numbers.positive;
          default = 1;
        };

        # Game options
        gamePath = mkOption {
          type = str;
          default = "${homeDir}/.xlcore/ffxiv";
        };
        gameConfigPath = mkOption {
          type = str;
          default = "${homeDir}/.xlcore/ffxivConfig";
        };
        additionalArgs = mkOption {
          type = str;
          default = "";
        };
        clientLanguage = mkOption {
          type = enum [ "Japanese" "English" "German" "French" ];
          default = "English";
        };
        dpiAwareness = mkOption {
          type = enum [ "Aware" "Unaware" ];
          default = "Unaware";
        };
        isFt = mkEnableOption "FFXIV Free Trial account" false;
        isOtpServer = mkEnableOption "OTP macros" false;
        isIgnoringSteam = mkEnableOption "ignore steam" false;
        isUidCacheEnabled = mkEnableOption "uid cache" false;

        # Patching options
        patchPath = mkOption {
          type = str;
          default = "${homeDir}/.xlcore/patch";
        };
        patchAcquisitionMethod = mkOption {
          type = enum [
            "NetDownloader"
            "MonoTorrentNetFallback"
            "MonoTorrentAriaFallback"
            "Aria"
          ];
          default = "Aria";
        };
        patchSpeedLimit = mkOption {
          type = ints.unsigned;
          default = 0;
        };
        keepPatches = mkEnableOption "keep patches option" false;

        # WINE options
        wineStartupType = mkOption {
          type = enum [ "Managed" "Custom" ];
          default = if (cfg.winePackage == null)
            then "Managed" else "Custom";
        };
        wineBinaryPath = mkOption {
          type = (either path pathInStore);
          default = if (cfg.winePackage == null)
            then /usr/bin
            else "${cfg.winePackage}/bin";
        };
        wineDebugVars = mkOption {
          type = str;
          default = "-all";
        };
        gameModeEnabled = mkEnableOption "Feral's GameMode CPU optimisations" cfg.useGamemode;
        dxvkAsyncEnabled = mkEnableOption "DXVK ASYNC" false;
        eSyncEnabled = mkEnableOption "ESync" true;
        fSyncEnabled = mkEnableOption "FSync" false;
        setWin7 = mkEnableOption "Windows 7 default" true;
        dxvkHudType = mkOption {
          type = enum [ "None" "Fps" "Full" ];
          default = "None";
        };

        # Dalamud options
        dalamudEnabled = mkEnableOption "Dalamud" true;
        dalamudLoadMethod = mkOption {
          type = enum [ "EntryPoint" "DllInject" "ACLonly" ];
          default = "EntryPoint";
        };
        dalamudLoadDelay = mkOption {
          type = ints.unsigned;
          default = 0;
        };
        dalamudManualInjectionEnabled = mkEnableOption "Dalamud manual injection" false;

        # Troubleshooting options
        fixLDP = mkDisableOption "gameoverlayrenderer.so" false;
        fixIM = mkDisableOption "XMODIFIERS" false;
        fixLocale = mkDisableOption "system locale" false;
      };
    };
in
{
  options.programs.xivlauncher = {
    enable = mkEnableOption "XIVLauncher" false;
    useGamemode = mkEnableOption "Feral's GameMode CPU optimisations" false;
    useSteamRun = mkEnableOption "Steam Runtime" true;
    winePackage = mkPackageOption pkgs "WINE" {
      nullable = true;
      default = null;
    };
    settings = mkOption {
      type = types.nullOr xivlauncherSettings;
      default = null;
    };
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

    home.packages = [
      (pkgs.xivlauncher.override {
        useSteamRun = cfg.useSteamRun;
      })
    ] ++ lists.optional (cfg.winePackage != null) cfg.winePackage;

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

    # XIVLauncher won't start if we don't make a copy
    # of the configuration file. How the program interacts
    # with either symbolic links or read-only files breaks it.
    home.activation.copyXIVLauncherSettings =
      let
        source = config.home.file.".xlcore/launcher.ini".source;
        target = "${homeDir}/.xlcore/launcher.ini";
      in
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        $VERBOSE_ECHO '${source} -> ${target}'
        $DRY_RUN_CMD cp --remove-destination --no-preserve=mode '${source}' '${target}'
      '';

    home.file.".xlcore/launcher.ini" =
      mkIf (cfg.settings != null) {
        source = pkgs.writeText ".xlcore/launcher.ini"
          (toINI { globalSection = cfg.settings; });
      };
  };
}
