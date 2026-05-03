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

  nixpkgs.config.permittedInsecurePackages = with pkgs; [
    "dotnet-runtime-7.0.20" # Vintage Story dependency
    fluffychat.name # Due to deprecated dependency libolm
    olm.name
  ];
  
  users.users.dev.packages = with pkgs; [
    anki
    blender
    blockbench
    cockatrice
    filezilla
    fluffychat
    foliate
    gimp3
    hledger
    in-formant
    inkscape-with-extensions
    krita
    libreoffice
#    lutris
    mangohud
    nautilus
    obsidian
    osu-lazer-bin
    picard
    (prismlauncher.override {
      additionalLibs = [
        jemalloc
      ] ++ (with xorg; [
        libxkbcommon
        libxt
        libxtst
      ]);

      additionalPrograms = [
        jdk21
        waywall
      ];
      
      jdks = [
        jdk17
        jdk21
        jdk25
      ];
    })
    pwvucontrol
    qpwgraph
    qt6Packages.qt6ct
    revolt-desktop
    signal-desktop
    strawberry
    supertuxkart
    vial
    vintagestory
    vlc
    wasistlos
    xournalpp
    zoom-us
  ] ++ (with pkgs; [ # programs that I had configs before
    xivlauncher
    discord
    vesktop
    thunderbird
  ]) ++ (with local.pkgs; [
    (rustPackages.music-discord-rpc.override {
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
      ".config/systemd/user/music-discord-rpc.service" = {
        text =
          ''
            [Unit]
            Description=Cross-platform Discord rich presence for music with album cover and progress bar support.
            After=network.target
            
            [Service]
            ExecStart=${local.pkgs.rustPackages.music-discord-rpc}/bin/music-discord-rpc
            Restart=always
            RestartSec=10
            StandardOutput=journal
            StandardError=journal
            
            [Install]
            WantedBy=default.target
          '';
      };
    };
  };
}
