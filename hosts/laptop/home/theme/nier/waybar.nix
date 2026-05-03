{ config, local, pkgs, lib, ... }:
let
  theme = config.hjem.users.dev.theme;
  colors = theme.colors;

  inherit (local.lib.colors)
    toHexStringRgb
    toRgbString;
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.profont
  ];
  
  hjem.users.dev.files = {
    ".config/waybar/config" = {
      text =
        ''
          {
            "name": "main-bar",
            "reload_style_on_change": true,
            "layer": "top",
            "position": "top",
            "height": 30,
            "spacing": 0,
            "modules-left": [
              "hyprland/workspaces",
              "niri/workspaces",
              "mpris",
            ],
            "modules-center": [
              "custom/time",
              "clock",
              "custom/user",
            ],
            "modules-right": [
              "disk",
              "memory",
              "cpu",
              "wireplumber",
              "backlight",
              "battery",
              "network",
              "custom/shutdown",
            ],
            "hyprland/workspaces": {
              "format": "{icon}",
              "format-icons": {
                "1": "𐄫",
                "2": "𐄬",
                "3": "𐄭",
                "4": "𐄮",
                "5": "𐄯",
                "6": "𐄰",
              },
            },
            "niri/workspaces": {
              "format": "{icon}",
              "format-icons": {
                "1": "𐄫",
                "2": "𐄬",
                "3": "𐄭",
                "4": "𐄮",
                "5": "𐄯",
                "6": "𐄰",
              },
            },
            "mpris": {
              "interval": 1,
              "format": "",
              "format-paused": " {artist} - {title}",
              "format-playing": " {artist} - {title}",
              "tooltip-format": "({status}) {player} [{position}/{length}]\n{dynamic}",
              "dynamic-order": [ "title", "artist", "album" ],
              "dynamic-separator": "\n",
              "align": 0,
              "justify": "left",
              "max-length": 50,
            },
            "custom/time": {
              "exec": "date +%H:%M",
              "interval": 5,
              "format": " {}",
              "tooltip": false,
            },
            "clock": {
              "timezone": "Europe/Berlin",
              "locale": "de_DE.utf8",
              "format": " {:%a, %d.%m}",
              "tooltip-format": "<tt><small>{calendar}</small></tt>",
              "calendar": {
                "mode": "year",
                "mode-mon-col": 3,
                "weeks-pos": "left",
                "format": {
                  "months": "<span color='#${toHexStringRgb colors.secondaryTint}'><b>{}</b></span>",
                  "days": "<span color='#${toHexStringRgb colors.mainTint}'><b>{}</b></span>",
                  "weeks": "<span color='#${toHexStringRgb colors.secondaryShade}'><b>W{}</b></span>",
                  "weekdays": "<span color='#${toHexStringRgb colors.secondaryShade}'><b>{}</b></span>",
                  "today": "<span color='#${toHexStringRgb colors.secondaryShade}'><b>{}</b></span>",
                },
              },
              "actions": {
                "on-click-right": "mode",
                "on-click-forward": "tz_up",
                "on-click-backward": "tz_down",
                "on-scroll-up": "shift_up",
                "on-scroll-down": "shift_down",
              },
            },
            "custom/user": {
              "exec": "echo -n $USER",
              "interval": "once",
              "format": " {}",
              "tooltip": false,
            },
            "disk": {
              "format": " {percentage_used}%",
            },
            "memory": {
              "format": " {percentage}%",
            },
            "cpu": {
              "format": "󰘚 {usage}%",
            },
            "wireplumber": {
              "format": "{icon} {volume}%",
              "format-muted": "󰝟 {volume}%",
              "format-icons": [ "󰕿", "󰖀", "󰕾" ],
            },
            "backlight": {
              "format": "{icon} {percent}%",
              "format-icons": [
                "󰃚", "󰃛", "󰃜", "󰃝", "󰃞", "󰃟", "󰃠",
              ],
              "tooltip": false,
            },
            "battery": {
              "bat": "BAT1",
              "format": "{icon} {capacity}%",
              "format-charging": "󰂄 {capacity}%",
              "format-plugged": " {capacity}%",
              "format-icons": [
                "󰁺", "󰁻", "󰁼", "󰁽", "󰁾",
                "󰁿", "󰂀", "󰂁", "󰂂", "󰁹",
              ],
              "states": {
                "warning": 40,
                "critical": 20,
              },
            },
            "network": {
              "format": "󰈂",
              "format-ethernet": "󰈁",
              "format-wifi": "{icon}",
              "format-icons": [ "󰢼", "󰢽", "󰢾" ],
              "tooltip-format": "Disabled",
              "tooltip-format-disconnected": "Disconnected",
              "tooltip-format-ethernet": "{ifname}/{ipaddr}",
              "tooltip-format-wifi": "{ifname}/{ipaddr} ({signalStrength}%)"
            },
            "custom/shutdown": {
              "exec": "echo 󰐦",
              "interval": "once",
              "tooltip": false,
            },
          }
        '';
    };
    ".config/waybar/style.css" = {
      text =
        ''
          @define-color main ${toRgbString colors.main};
          @define-color mainShade ${toRgbString colors.mainShade};
          @define-color mainTint ${toRgbString colors.mainTint};
          @define-color secondary ${toRgbString colors.secondary};
          @define-color accentRed ${toRgbString colors.accents.red};

          * {
            padding: 0;
            margin: 0;
            border: none;
            border-radius: 0;
            font-family: "${theme.fonts.main}", "${theme.fonts.fallback}", monospace;
            font-size: 12px;
            font-weight: bold;
            min-height: 30px;
          }

          window#waybar {
            background: @main;
            min-height: 30px;
          }

          tooltip {
            background: @main;
            border: none;
          }

          tooltip label {
            padding: 0 10px;
            color: @secondary;
          }

          .module {
            background: @secondary;
            color: @main;
            min-width: 30px;
          }

          .modules-right .module {
            margin-left: 2px;
            min-width: 70px;
          }

          #workspaces button {
            padding: 0;
            background: @main;
            color: @secondary;
            font-family: "${theme.fonts.mainMono}", "${theme.fonts.fallbackMono}", monospace;
            min-width: 30px;
          }

          #workspaces button:hover {
            background: @mainShade;
            box-shadow: none;
          }

          #workspaces button label {
            font-size: 20px;
          }

          #workspaces button.active {
            background: @secondary;
            color: @main;
          }

          #workspaces button.empty {
            color: @mainTint;
          }

          #workspaces button.urgent {
            background: @accentRed;
          }

          #mpris {
            padding: 0 10px;
            background: @main;
            color: @secondary;
          }

          #mpris:hover {
            background: @mainShade;
          }

          #custom-time,
          #custom-user {
            min-width: 80px;
          }

          #clock {
            padding: 0 10px;
            margin: 0 2px;
          }

          #network,
          #custom-shutdown {
            font-family: "${theme.fonts.mainMono}", "${theme.fonts.fallbackMono}", monospace;
            font-size: 20px;
            min-width: 30px;
          }

          #network.disabled {
            background: @main;
            color: @mainTint;
          }
        '';
    };
  };
}
