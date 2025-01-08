{ local, pkgs, lib, ... }:
{
  imports = builtins.concatLists [
    (with local.modules; [
      home-manager-extra
    ])
    [
      ./themes/styley2
      ./desktops/hyprland
      ./programs/editor/emacs
      ./programs/editor/helix
      ./programs/editor/neovim
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
      ./programs/social/irssi
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
      adwaita-qt
      adwaita-icon-theme

      anki
      cockatrice
      filezilla
      libreoffice
      # Temporary: insecure electron package
      # logseq
      lutris
      mangohud
      obsidian
      pavucontrol
      pomodoro-gtk
      prismlauncher
      revolt-desktop
      signal-desktop
      vial
      xournalpp
      zoom-us
    ])
    (with local; [
      #pkgs.plover
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

  home.stateVersion = "24.11";
}
