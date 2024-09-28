{ local, pkgs, ... }:
{
  imports = builtins.concatLists [
    (with local.modules; [
      home-manager-extra
    ])
    [
      ./themes/styley2
      ./desktops/hyprland
      ./programs/editor/helix
      ./programs/file-manager/yazi
      ./programs/game/xivlauncher
      ./programs/launcher/rofi
      ./programs/multiplexer/zellij
      ./programs/music/ncmpcpp
      ./programs/music/spotify
      ./programs/notification/mako
      ./programs/password-manager/bitwarden
      ./programs/shell/zsh
      ./programs/social/discord
      ./programs/social/thunderbird
      ./programs/terminal/kitty
      ./programs/web-browser/firefox
      ./programs/widget/waybar
      ./shells
    ]
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
  home.packages = builtins.concatLists [
    (with pkgs; [
      logseq
      lutris
      pavucontrol
      pomodoro-gtk
      signal-desktop
    ])
    (with local; [
      scripts.touchp
    ])
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
