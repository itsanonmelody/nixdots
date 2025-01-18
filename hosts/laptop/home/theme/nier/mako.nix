{ config, local, ... }:
let
  theme = config.hjem.users.dev.theme;
  colors = theme.colors;

  inherit (local.lib.colors)
    toHexStringRgb;
in
{
  hjem.users.dev.files = {
    ".config/mako/config" = {
      text =
        ''
          font=${theme.fonts.main},${theme.fonts.fallback},monospace 9
          background-color=#${toHexStringRgb colors.main}
          text-color=#${toHexStringRgb colors.secondary}
          border-size=2
          border-color=#${toHexStringRgb colors.secondary}
          default-timeout=5000
          max-visible=3
          layer=overlay
          anchor=top-right
        '';
    };
  };
}
