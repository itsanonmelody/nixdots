{ lib, ... }:
{
  hjem.users.dev.files = {
    ".config/waybar/config" = {
      text =
        ''
          {
            "name": "main-bar",
            "reload_style_on_change": true,
            "position": "top",
            "height": 30,
            "spacing": 4,
            "modules-left": [
              "hyprland/workspaces",
              "mpris",
            ],
            "modules-center": [
              "custom/time",
              "clock",
              "user",
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
            "mpris": {
              "format": "{status}: {dynamic}",
              "dynamic-len": 40,
              "title-len": 40,
            },
            "custom/time": {
              "exec": "date +%H:%M",
              "interval": 5,
            },
            "clock": {
              "format": "{:%a, %d.%m}",
              "timezone": "Europe/Berlin",
              "locale": "de_DE.utf8",
            },
            "user": {
              "format": "{user}"
            },
            "custom/shutdown": {
              "exec": "echo 󰐦",
              "interval": "once",
            },
          }
        '';
    };
  };
}
