{ local, pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./kitty.nix
    ./mako.nix
    ./waybar.nix
  ];
  
  hjem.extraModules = [
    ({ lib, ... }: {
      options = {
        theme = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
        };
      };
    })
  ];

  hjem.users.dev.theme =
    let
      inherit (local.lib.colors)
        mkColorRgb
        toHexStringRgb;
    in
      rec {
        initialBackgroundColor = toHexStringRgb colors.mainShade;
        wallpaper = "nier/wp3633244.png";
        fonts = rec {
          main = "ProFont IIx Nerd Font";
          mainMono = "${main} Mono";
          fallback = "NotoMono Nerd Font";
          fallbackMono = "${fallback} Mono";
        };
        colors = {
          main = mkColorRgb 56 52 47;
          mainShade = mkColorRgb 38 34 30;
          mainTint = mkColorRgb 122 115 104;
          secondary = mkColorRgb 225 211 191;
          secondaryShade = mkColorRgb 192 180 163;
          secondaryTint = mkColorRgb 238 224 202;
          accents = {
            red = mkColorRgb 228 52 71;
          };
        };
      };

  hjem.users.dev.files = {
    ".local/share/icons/Adwaita" = {
      source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
    };
  };
}
