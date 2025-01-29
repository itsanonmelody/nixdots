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
# - floorp
# - waybar
{ pkgs, ... }:
{
  imports = [
    ./desktop/hyprland
    ./theme/nier
    ./programs/kitty.nix
  ];
  
  users.users.dev.packages = with pkgs; [
    anki
    cockatrice
    filezilla
    libreoffice
    lutris
    mangohud
    obsidian
    prismlauncher
    qt6ct
    revolt-desktop
    signal-desktop
    strawberry
    vial
    xournalpp
    zoom-us
  ] ++ (with pkgs; [ # programs that I had configs before
    xivlauncher
    ncmpcpp
    spotify
    discord
    thunderbird
    floorp
  ]);
}
