{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "NotoSansM Nerd Font";
    };
  };
}
