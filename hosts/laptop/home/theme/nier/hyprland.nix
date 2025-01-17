{ ... }:
{
  hjem.users.dev.files = {
    ".config/hypr/theme.conf" = {
      text =
        ''
          general {
            gaps_in = 0
            gaps_out = 0
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

          misc:disable_hyprland_logo = true
        '';
    };
  };
}
