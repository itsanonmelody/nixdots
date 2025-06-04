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
{ local, pkgs, lib, ... }:
{
  imports = [
    ./desktop/niri
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
    in-formant
    inkscape-with-extensions
    krita
    libreoffice
    lutris
    mangohud
    obsidian
    osu-lazer-bin
    prismlauncher
    qpwgraph
    qt6ct
    revolt-desktop
    signal-desktop-bin
    (symlinkJoin {
      name = "strawberry-spotify";
      paths = [ strawberry ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild =
        ''
          wrapProgram $out/bin/strawberry \
            --suffix GST_PLUGIN_PATH : ${lib.makeLibraryPath [ local.pkgs.rustPackages.gst-plugin-spotify]}
        '';
    })
    sonusmix
    superTuxKart
    vial
    vintagestory
    xournalpp
    zoom-us
  ] ++ (with pkgs; [ # programs that I had configs before
    xivlauncher
    ncmpcpp
    spotify
    discord
    vesktop
    thunderbird
    floorp
  ]) ++ (with local.pkgs; [
    (rustPackages.mpris-discord-rpc.override {
      lastfmApiKeyFile = "/etc/nixos/secret/lastfm/api-key";
    }) # systemd service needed
  ]);

  hjem.users.dev = {
    files = {
      ".config/pipewire/pipewire.conf.d/99-input-denoising.conf" = {
        text =
          ''
            context.modules = [
              {
                name = libpipewire-module-filter-chain
                args = {
                  node.description = "Noise Canceling Source"
                  media.name = "Noise Canceling source"
                  filter.graph = {
                    nodes = [
                      {
                        type = ladspa
                        name = rnnoise
                        plugin = ${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so
                        label = noise_suppressor_mono
                        control = {
                          "VAD Threshold (%)" = 50.0
                          "VAD Grace Period (ms)" = 200
                          "Retroactive VAD Grace (ms)" = 0
                        }
                      }
                    ]
                  }
                  capture.props = {
                    node.name = "capture.rnnoise_source"
                    node.passive = true
                    audio.rate = 48000
                  }
                  playback.props = {
                    node.name = "rnnoise_source"
                    media.class = Audio/Source
                    audio.rate = 48000
                  }
                }
              }
            ]
          '';
      };
    };
  };
}
