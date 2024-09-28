{ config, pkgs, ... }:
{
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override {
      visualizerSupport = true;
    };
    settings = {
      visualizer_data_source = "/tmp/mpd.fifo";
      visualizer_output_name = "Visualizer Feed";
      visualizer_in_stereo = "yes";
      visualizer_type = "spectrum";
      visualizer_look = "+|";
    };
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

        audio_output {
          type "fifo"
          name "Visualizer Feed"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };
    mpdris2.enable = true;
    mpd-discord-rpc.enable =
      config.programs.vencord.enable;
  };

  home.packages = with pkgs; [ mpd-notification ];

  systemd.user = {
    enable = true;
    services.mpd-notification = {
      Unit = {
        Description = "Notification Daemon for MPD";
        Documentation = "https://github.com/eworm-de/mpd-notification";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.mpd-notification}/bin/mpd-notification";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
