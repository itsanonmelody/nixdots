{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  inherit (lib) isStorePath mkIf mkOption;
  inherit (lib.attrsets) mergeAttrsList;

  cfg = config.programs.vencord;

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

  defaultPlugins = {
    BadgeAPI = {
      enabled = true;
    };
    CommandsAPI = {
      enabled = true;
    };
    ContextMenuAPI = {
      enabled = true;
    };
    NoticesAPI = {
      enabled = true;
    };
    NoTrack = {
      enabled = true;
      disableAnalytics = true;
    };
    Settings = {
      enabled = true;
      settingsLocation = "aboveNitro";
    };
    SupportHelper = {
      enabled = true;
    };
  };

  vencordSettings = with types;
    submodule {
      options = {
        autoUpdate = mkEnableOption "auto update" true;
        autoUpdateNotification =
          mkEnableOption "auto update notification" true;
        useQuickCss = mkEnableOption "custom css" true;
        themeLinks = mkOption {
          type = listOf str;
          default = [];
        };
        enabledThemes = mkOption {
          type = listOf str;
          default = builtins.map builtins.baseNameOf cfg.themes;
        };
        enableReactDevtools = mkEnableOption "react developer tools" false;
        frameless = mkDisableOption "window frames" false;
        transparent = mkEnableOption "window transparency" false;
        winCtrlQ = mkEnableOption "WinCtrlQ" false;
        disableMinSize = mkDisableOption "minimum window size" false;
        winNativeTitleBar = mkEnableOption "Windows native title bar" false;
        plugins = mkOption {
          type = attrs;
          default = defaultPlugins;
        };
        notifications = mkOption {
          type = submodule {
            options = {
              timeout = mkOption {
                type = ints.unsigned;
                default = 5000;
              };
              position = mkOption {
                type = enum [ "bottom-right" "top-right" ];
                default = "bottom-right";
              };
              useNative = mkOption {
                type = enum [ "not-focused" "always" "never" ];
                default = "not-focused";
              };
              logLimit = mkOption {
                type = ints.unsigned;
                default = 50;
              };
            };
          };
        };
      };
      # Cloud is not listed here because it won't be needed.
    };
in
{
  options.programs.vencord = with types;
    {
      enable = mkEnableOption "Vencord" false;
      # Not sure how useful this option is.
      quickCss = {
        type = nullOr (either path lines);
        default = null;
      };
      themes = mkOption {
        type = listOf path;
        default = [];
      };
      settings = mkOption {
        type = nullOr vencordSettings;
        default = null;
      };
    };

  config =
    let
      finalSettings = mergeAttrsList [
        (if (cfg.settings != null) then cfg.settings else { })
        {
          plugins = mergeAttrsList [
            defaultPlugins
            (if (cfg.settings != null) then cfg.settings.plugins else { })
          ];
        }
      ];
      themeSymLinks =
        builtins.map (theme:
          let
            filename = builtins.baseNameOf theme;
          in
          {
            "${config.xdg.configHome}/Vencord/themes/${filename}" = {
              source = config.lib.file.mkOutOfStoreSymlink theme;
            };
          }) cfg.themes;
    in
    mkIf cfg.enable {
      home.packages = [
        (pkgs.discord.override { withVencord = true; })
      ];

      home.file = mergeAttrsList themeSymLinks;

      xdg.configFile = mergeAttrsList [
        (mkIf (cfg.quickCss != null) {
          "Vencord/settings/quickCss.css" = {
            source =
              if builtins.isPath cfg.quickCss
                  || isStorePath cfg.quickCss
                then cfg.quickCss
                else pkgs.writeText "Vencord/settings/quickCss.css"
                  cfg.quickCss;
          };
        })
        (mkIf (cfg.settings != null) {
          "Vencord/settings/settings.json" = {
            source = pkgs.writeText "Vencord/settings/settings.json"
              (builtins.toJSON finalSettings);
          };
        })
      ];
    };
}
