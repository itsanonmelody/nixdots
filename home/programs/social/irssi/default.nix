{ pkgs, ... }:
{
  programs.irssi = {
    enable = true;
  };

  xdg.desktopEntries.irssi = {
    name = "Irssi";
    genericName = "IRC Client";
    exec = "${pkgs.irssi}/bin/irssi";
    terminal = true;
  };
}
