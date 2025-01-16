{ pkgs, lib, ... }:
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
            "position": "top",
            "height": 30,
            "spacing": 0,
            "modules-left": [
              "hyprland/workspaces",
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
          @define-color main rgb(80, 75, 68);
          @define-color mainShade rgb(56, 52, 47);
          @define-color mainTint rgb(110, 104, 94);
          @define-color secondary rgb(225, 211, 191);
          @define-color accentRed rgb(228, 52, 71);

          * {
            padding: 0;
            margin: 0;
            border: none;
            border-radius: 0;
            font-family: "ProFont IIx Nerd Font", "NotoMono Nerd Font Mono", monospace;
            font-size: 12px;
            min-height: 30px;
          }

          window#waybar {
            background: @main;
            min-height: 30px;
          }

          tooltip {
            background: @mainShade;
            border: 2px solid @main;
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
