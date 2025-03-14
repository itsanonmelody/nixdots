{ config, local, ... }:
let
  theme = config.hjem.users.dev.theme;
  colors = theme.colors;

  inherit (local.lib.colors)
    toHexStringRgb;
in
{
  hjem.users.dev.files = {
    ".config/kitty/kitty.d/theme.conf" = {
      text =
        ''
          font_family family="${theme.fonts.mainMono}"
          bold_font auto
          italic_font auto
          bold_italic_font auto
          font_size 10

          background #${toHexStringRgb colors.mainShade}
          foreground #${toHexStringRgb colors.secondaryShade}
        '';
    };
  };
}
