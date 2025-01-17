{ ... }:
{
  hjem.users.dev.files = {
    ".config/hypr/theme.conf" = {
      text =
        ''
          general {
            border_size = 2
            gaps_in = 0
            gaps_out = 0
            col.inactive_border = rgb(504b44)
            col.active_border = rgb(e1d3bf)
            
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
            col.border_active = rgb(e1d3bf)
            col.border_inactive = rgb(7a7368)
            col.border_locked_active = rgb(e1d3bf)
            col.border_locked_inactive = rgb(7a7368)

            groupbar {
              enabled = true
              font_size = 12
              height = 20
              text_color = rgb(e1d3bf)
              col.active = rgb(e1d3bf)
              col.inactive = rgb(504b44)
              col.locked_active = rgb(e1d3bf)
              col.locked_inactive = rgb(504b44)
            }
          }

          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
            font_family = "ProFont IIx Nerd Font, NotoMono Nerd Font Mono, Mono"
          }
        '';
    };
  };
}
