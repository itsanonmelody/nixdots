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
    (rustPackages.mpris-discord-rpc.override {
      lastfmApiKeyFile = "/etc/nixos/secret/lastfm/api-key";
    }) # systemd service needed
  ]);
}
