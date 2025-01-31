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
{ local, pkgs, ... }:
{
  imports = [
    ./desktop/hyprland
    ./theme/nier
    ./programs/kitty.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20" # Vintage Story dependency
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
    vintagestory
    xournalpp
    zoom-us
  ] ++ (with pkgs; [ # programs that I had configs before
    xivlauncher
    ncmpcpp
    spotify
    discord
    thunderbird
    floorp
  ]) ++ (with local.pkgs; [
    rustPackages.mpris-discord-rpc # systemd service needed
  ]);
}
