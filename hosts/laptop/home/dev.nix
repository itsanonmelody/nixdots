# TODO: Configure the following programs
# - hyprland
# - yazi
# - rofi
# - ncmpcpp
# - spotify
# - mako
# - zsh
# - discord
# - thunderbird
# - kitty
# - firefox
# - waybar
{ pkgs, ... }:
{
  imports = [
    ./desktop/hyprland
  ];
  
  users.users.dev.packages = with pkgs; [
    adwaita-qt
    adwaita-icon-theme

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
  ] ++ (with pkgs; [ # programs that I had configs before
    xivlauncher
    ncmpcpp
    spotify
    mako
    discord
    thunderbird
    firefox
  ]);
}
