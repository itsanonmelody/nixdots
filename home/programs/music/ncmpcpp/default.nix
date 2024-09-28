{ config, ... }:
{
  programs.ncmpcpp = {
    enable = true;
  };

  xdg.desktopEntries.ncmpcpp = {
    name = "ncmpcpp";
    genericName = "CLI Music Player";
    exec = "ncmpcpp";
    terminal = true;
    categories = [ "AudioVideo" "Audio" "Music" "Player" ];
  };

  services = {
    mpd = {
      enable = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Output"
        }
      '';
    };
    mpdris2.enable = true;
    mpd-discord-rpc.enable =
      config.programs.vencord.enable;
  };
}
