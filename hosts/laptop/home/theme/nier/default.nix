{ local, ... }:
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
        mkColorRgb;
    in
      {
        initialBackgroundColor = "000000";
        wallpaper = "nier/wp3633244.png";
        fonts = {
          main = "ProFont IIx Nerd Font Mono";
          fallback = "NotoMono Nerd Font";
        };
        colors = {
          main = mkColorRgb 56 52 47;
          mainShade = mkColorRgb 30 28 25;
          mainTint = mkColorRgb 122 115 104;
          secondary = mkColorRgb 225 211 191;
          secondaryShade = mkColorRgb 192 180 163;
          secondaryTint = mkColorRgb 238 224 202;
          accents = {
            red = mkColorRgb 228 52 71;
          };
        };
      };
}
