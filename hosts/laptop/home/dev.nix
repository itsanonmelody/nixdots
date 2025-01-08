{ pkgs, ... }:
{
  users.users.dev.packages = with pkgs; [
    adwaita-qt
    gnome.adwaita-icon-theme

    anki
    cockatrice
    filezilla
    libreoffice
    lutris
    mangohud
    obsidian
    prismlauncher
    revolt-desktop
    signal-desktop
    vial
    xournalpp
    zoom-us
  ];
}
