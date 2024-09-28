{ config, lib, ... }:
let
  wallpaper = config.home.wallpaper;
in
with lib;
{
  options.home.wallpaper = mkOption {
    type = types.path;
    default = null;
  };

  config = mkIf (wallpaper != null) {
    home.file.wallpaper = {
      enable = true;
      source = wallpaper;
      target = ".config/wallpaper";
      force = true;
    };
  };
}
