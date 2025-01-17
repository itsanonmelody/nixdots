{ ... }:
{
  imports = [
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

  hjem.users.dev.theme = {
    initialBackgroundColor = "000000";
    wallpaper = "nier/wp3633244.png";
  };
}
