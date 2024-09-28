{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop/hyprland
    ./programs/editor/helix
    ./programs/file-manager/yazi
    ./programs/launcher/rofi
    ./programs/music/spotify
    ./programs/notification/mako
    ./programs/shell/zsh
    ./programs/social/discord
    ./programs/social/thunderbird
    ./programs/terminal/kitty
    ./programs/web-browser/firefox
    ./programs/widgets/waybar
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz")
        {
          inherit pkgs;
        };
    };
  };
  home.packages = with pkgs;
    [
      pavucontrol
      signal-desktop
    ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.stateVersion = "24.05";
}
