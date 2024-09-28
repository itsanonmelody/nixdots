{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "NotoSansM Nerd Font";
    theme = "gruvbox-dark-hard";
  };
}
