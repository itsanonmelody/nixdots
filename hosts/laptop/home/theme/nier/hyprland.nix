{ config, local, ... }:
let
  theme = config.hjem.users.dev.theme;
  colors = theme.colors;

  inherit (local.lib.colors)
    toHexStringRgb;
in
{
  hjem.users.dev.files = {
    ".config/hypr/theme.conf" = {
      text =
        ''
          # hyprlang noerror false

          general {
            border_size = 2
            gaps_in = 0
            gaps_out = 0
            col.inactive_border = rgb(${toHexStringRgb colors.main})
            col.active_border = rgb(${toHexStringRgb colors.mainTint})
            
          }

          decoration {
            shadow:enabled = false
            blur {
              enabled = false
              popups = true
              size = 4
              passes = 2
            }
          }

          animations:enabled = false

          group {
            col.border_active = rgb(${toHexStringRgb colors.mainTint})
            col.border_inactive = rgb(${toHexStringRgb colors.main})
            col.border_locked_active = rgb(${toHexStringRgb colors.mainTint})
            col.border_locked_inactive = rgb(${toHexStringRgb colors.main})

            groupbar {
              enabled = true
              font_size = 12
              height = 20
              text_color = rgb(${toHexStringRgb colors.mainTint})
              col.active = rgb(${toHexStringRgb colors.mainTint})
              col.inactive = rgb(${toHexStringRgb colors.main})
              col.locked_active = rgb(${toHexStringRgb colors.mainTint})
              col.locked_inactive = rgb(${toHexStringRgb colors.main})
            }
          }

          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
            font_family = ${theme.fonts.main}, ${theme.fonts.fallback}, Mono
          }

          cursor {
            enable_hyprcursor = false
          }
        '';
    };
  };
}
