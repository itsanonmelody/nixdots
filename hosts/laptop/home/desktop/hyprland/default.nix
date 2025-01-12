{ local, pkgs, ... }:
let
  inherit (local.lib.generators) toHyprlang;

  theme = import ../../theme/styley;

  autoswwwScript = pkgs.writeShellScript "hyprland-autoswww"
    ''
      export SWWW_TRANSITION=any
      export SWWW_TRANSITION_DURATION=2
      export SWWW_TRANSITION_FPS=60

      ${pkgs.swww}/bin/swww-daemon &
      ${pkgs.swww}/bin/swww clear ${theme.initialBackgroundColor}
      ${pkgs.swww}/bin/swww img --resize fit "$HOME/.config/wallpaper"

      while :; do
        if ${pkgs.inotify-tools}/bin/inotifywait -P -e'close_write,create,delete_self,modify,move_self,moved_to' "$HOME/.config/wallpaper"; then
          ${pkgs.swww}/bin/swww img --resize fit "$HOME/.config/wallpaper"
        fi
        sleep 0.1s
      done
    '';
  startupScript = pkgs.writeShellScript "hyprland-startup"
    ''
      ${autoswwwScript} &
      ${pkgs.waybar}/bin/waybar &
    '';
  shutdownScript = pkgs.writeShellScript "hyprland-shutdown"
    ''
      pkill waybar
      ${pkgs.swww}/bin/swww kill
    '';
in
{
  users.users.dev.packages = with pkgs; [
    mako
  ];
  
  hjem.users.dev.files = {
    ".config/wallpaper" = {
      source = theme.wallpaper;
    };
    ".config/uwsm/env" = {
      text =
        ''
          export XCURSOR_THEME=Adwaita
          export XCURSOR_SIZE=24

          export XDG_DESKTOP_DIR="$HOME/Desktop"
          export XDG_DOCUMENTS_DIR="$HOME/Documents"
          export XDG_DOWNLOAD_DIR="$HOME/Downloads"
          export XDG_MUSIC_DIR="$HOME/Music"
          export XDG_PICTURES_DIR="$HOME/Pictures"
          export XDG_PUBLICSHARE_DIR="$HOME/Public"
          export XDG_TEMPLATES_DIR="$HOME/Templates"
          export XDG_VIDEOS_DIR="$HOME/Videos"
        '';
    };
    ".config/uwsm/env-hyprland" = {
      text =
        ''
          export AQ_DRM_DEVICES="/dev/dri/card2:/dev/dri/card1"
        '';
    };
    ".config/hypr/hyprland.conf" = {
      text =
        ''
          exec-once = ${startupScript}
          exec-shutdown = ${shutdownScript}

          monitor = eDP-1,1920x1080@144,0x0,1

          workspace = 1,monitor:eDP-1,persistent:true
          workspace = 2,monitor:eDP-1,persistent:true
          workspace = 3,monitor:eDP-1,persistent:true
          workspace = 4,monitor:eDP-1,persistent:true
          workspace = 5,monitor:eDP-1,persistent:true
          workspace = 6,monitor:eDP-1,persistent:true

          windowrulev2 = tile,class:(steam),title:^Big-Picture-Mod(e|us)$

          general {
            gaps_in = 0
            gaps_out = 0
            layout = dwindle
          }

          dwindle {
            pseudotile = true
            preserve_split = true
          }

          decoration {
            shadow:enabled = false
            blur {
              enabled = true
              popups = true
              size = 4
              passes = 2
            }
          }

          animations:enabled = true

          gestures:workspace_swipe = false

          input {
            kb_layout = eu
            kb_variant = 
            kb_model = 
            kb_options = 
            kb_rules = 

            accel_profile = flat
            sensitivity = 0

            touchpad:natural_scroll = false
          }

          device {
            name = at-translated-set-2-keyboard
            kb_layout = de
            kb_variant = 
            kb_model = 
            kb_options = 
            kb_rules = 
          }

          misc {
            disable_hyprland_logo = true
            vfr = true
          }

          $mainMod = SUPER
          bind = $mainMod,Q,exec,${pkgs.kitty}/bin/kitty
          bind = $mainMod,C,killactive,
          bind = $mainMod,M,exit,
          bind = $mainMod,E,exec,${pkgs.kitty}/bin/kitty ${pkgs.yazi}/bin/yazi
          bind = $mainMod,V,togglefloating,
          bind = $mainMod,R,exec,${pkgs.rofi-wayland}/bin/rofi -show drun
          bind = $mainMod,F,fullscreen,0

          bind = $mainMod,H,movefocus,l
          bind = $mainMod,J,movefocus,d
          bind = $mainMod,K,movefocus,u
          bind = $mainMod,L,movefocus,r

          bind = $mainMod,1,workspace,1
          bind = $mainMod,2,workspace,2
          bind = $mainMod,3,workspace,3
          bind = $mainMod,4,workspace,4
          bind = $mainMod,5,workspace,5
          bind = $mainMod,6,workspace,6

          bind = $mainMod SHIFT,1,movetoworkspace,1
          bind = $mainMod SHIFT,2,movetoworkspace,2
          bind = $mainMod SHIFT,3,movetoworkspace,3
          bind = $mainMod SHIFT,4,movetoworkspace,4
          bind = $mainMod SHIFT,5,movetoworkspace,5
          bind = $mainMod SHIFT,6,movetoworkspace,6

          bind = ,XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          bind = ,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause
          bind = ,XF86AudioStop,exec,${pkgs.playerctl}/bin/playerctl stop
          bind = ,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous
          bind = ,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next

          bind = ,Print,exec,${pkgs.grim}/bin/grim -t png - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
          bind = ALT,Print,exec,${pkgs.grim}/bin/grim -t png -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png

          binde = ,XF86AudioLowerVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-
          binde = ,XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+
          binde = ,XF86MonBrightnessUp,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%+
          binde = ,XF86MonBrightnessDown,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%-

          bindm = $mainMod,mouse:272,movewindow
          bindm = $mainMod,mouse:273,resizewindow
        '';
    };
    ".config/mako/config" = {
      text =
        ''
          anchor=top-right
          default-timeout=5000
          layer=overlay
        '';
    };
    ".config/waybar/config" = {
      text =
        ''
          {
            "name": "main-bar",
            "reload_style_on_change": true,
            "position": "top",
            "height": 30,
            "spacing": 4,
            "modules-left": [
              "hyprland/workspaces",
            ],
            "modules-center": [
              "clock",
            ],
            "modules-right": [
              "network",
              "wireplumber",
              "backlight",
              "battery",
            ],
          }
        '';
    };
    ".config/waybar/style.css" = {
      text =
        ''
          * {
            /* `otf-font-awesome` is required to be installed for icons */
            font-family: NotoSansM Nerd Font, sans-serif;
            font-size: 13px;
          }
        
          window#waybar {
            background-color: rgba(43, 48, 59, 0.5);
            border-bottom: 3px solid rgba(100, 114, 125, 0.5);
            color: #ffffff;
            transition-property: background-color;
            transition-duration: .5s;
          }
        
          window#waybar.hidden {
            opacity: 0.2;
          }
        
          /*
          window#waybar.empty {
            background-color: transparent;
          }
          window#waybar.solo {
            background-color: #FFFFFF;
          }
          */
        
          window#waybar.termite {
            background-color: #3F3F3F;
          }
        
          window#waybar.chromium {
            background-color: #000000;
            border: none;
          }
        
          button {
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each button name */
            border: none;
            border-radius: 0;
          }
        
          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #ffffff;
          }
        
          /* you can set a style on hover for any module like this */
          #pulseaudio:hover {
            background-color: #a37800;
          }
        
          #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #ffffff;
          }
        
          #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
          }
        
          #workspaces button.empty {
            color: #999999;
          }
        
          #workspaces button.active {
            background-color: #64727D;
          }
        
          #workspaces button.focused {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
          }
        
          #workspaces button.urgent {
            background-color: #eb4d4b;
          }
        
          #mode {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
          }
        
          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #wireplumber,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #scratchpad,
          #power-profiles-daemon,
          #mpd {
            padding: 0 10px;
            color: #ffffff;
          }
        
          #window,
          #workspaces {
            margin: 0 4px;
          }
        
          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
          }
        
          /* If workspaces is the rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
          }
        
          #clock {
            background-color: #64727D;
          }
        
          #battery {
            background-color: #ffffff;
            color: #000000;
          }
        
          #battery.charging, #battery.plugged {
            color: #ffffff;
            background-color: #26A65B;
          }
        
          @keyframes blink {
            to {
                background-color: #ffffff;
                color: #000000;
            }
          }
        
          /* Using steps() instead of linear as a timing function to limit cpu usage */
          #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: #ffffff;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: steps(12);
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }
        
          #power-profiles-daemon {
            padding-right: 15px;
          }
        
          #power-profiles-daemon.performance {
            background-color: #f53c3c;
            color: #ffffff;
          }
        
          #power-profiles-daemon.balanced {
            background-color: #2980b9;
            color: #ffffff;
          }
        
          #power-profiles-daemon.power-saver {
            background-color: #2ecc71;
            color: #000000;
          }
        
          label:focus {
            background-color: #000000;
          }
        
          #cpu {
            background-color: #2ecc71;
            color: #000000;
          }
        
          #memory {
            background-color: #9b59b6;
          }
        
          #disk {
            background-color: #964B00;
          }
        
          #backlight {
            background-color: #90b1b1;
          }
        
          #network {
            background-color: #2980b9;
          }
        
          #network.disconnected {
            background-color: #f53c3c;
          }
        
          #pulseaudio {
            background-color: #f1c40f;
            color: #000000;
          }
        
          #pulseaudio.muted {
            background-color: #90b1b1;
            color: #2a5c45;
          }
        
          #wireplumber {
            background-color: #fff0f5;
            color: #000000;
          }
        
          #wireplumber.muted {
            background-color: #f53c3c;
          }
        
          #custom-media {
            background-color: #66cc99;
            color: #2a5c45;
            min-width: 100px;
          }
        
          #custom-media.custom-spotify {
            background-color: #66cc99;
          }
        
          #custom-media.custom-vlc {
            background-color: #ffa000;
          }
        
          #temperature {
            background-color: #f0932b;
          }
        
          #temperature.critical {
              background-color: #eb4d4b;
          }
        
          #tray {
              background-color: #2980b9;
          }
        
          #tray > .passive {
              -gtk-icon-effect: dim;
          }
        
          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #eb4d4b;
          }
        
          #idle_inhibitor {
              background-color: #2d3436;
          }
        
          #idle_inhibitor.activated {
            background-color: #ecf0f1;
            color: #2d3436;
          }
        
          #mpd {
            background-color: #66cc99;
            color: #2a5c45;
          }
        
          #mpd.disconnected {
            background-color: #f53c3c;
          }
        
          #mpd.stopped {
            background-color: #90b1b1;
          }
        
          #mpd.paused {
            background-color: #51a37a;
          }
        
          #language {
            background: #00b093;
            color: #740864;
            padding: 0 5px;
            margin: 0 5px;
            min-width: 16px;
          }
        
          #keyboard-state {
            background: #97e1ad;
            color: #000000;
            padding: 0 0px;
            margin: 0 5px;
            min-width: 16px;
          }
        
          #keyboard-state > label {
            padding: 0 5px;
          }
        
          #keyboard-state > label.locked {
            background: rgba(0, 0, 0, 0.2);
          }
        
          #scratchpad {
            background: rgba(0, 0, 0, 0.2);
          }
        
          #scratchpad.empty {
          	background-color: transparent;
          }
        
          #privacy {
            padding: 0;
          }
        
          #privacy-item {
            padding: 0 5px;
            color: white;
          }
        
          #privacy-item.screenshare {
            background-color: #cf5700;
          }
        
          #privacy-item.audio-in {
            background-color: #1ca000;
          }
        
          #privacy-item.audio-out {
            background-color: #0069d4;
          }
        '';
    };
  };
}
