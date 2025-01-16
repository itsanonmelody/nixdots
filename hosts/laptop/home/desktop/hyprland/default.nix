{ inputs, local, config, pkgs, lib, ... }:
let
  inherit (local.lib.generators) toHyprlang;

  theme = import ../../theme/nier;

  autoswwwScript = pkgs.writeShellScript "hyprland-autoswww"
    ''
      export SWWW_TRANSITION=any
      export SWWW_TRANSITION_DURATION=2
      export SWWW_TRANSITION_FPS=60

      ${pkgs.swww}/bin/swww-daemon &
      ${pkgs.swww}/bin/swww clear ${theme.initialBackgroundColor}
      ${pkgs.swww}/bin/swww img  --transition-type grow --transition-pos 0.7,0.5 --resize fit "$HOME/.config/wallpaper"

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
      ${pkgs.playerctl}/bin/playerctld &
    '';
  shutdownScript = pkgs.writeShellScript "hyprland-shutdown"
    ''
      pkill playerctld
      pkill waybar
      ${pkgs.swww}/bin/swww kill
    '';
in
{
  imports = [
    ../../theme/nier/waybar.nix
  ];
  
  users.users.dev.packages = with pkgs; [
    mako
  ];
  
  hjem.users.dev.files = {
    ".config/wallpaper" = {
      source = "${inputs.self}/wallpaper/${theme.wallpaper}";
    };
    ".config/uwsm/env" = lib.mkIf config.programs.hyprland.withUWSM {
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
    ".config/uwsm/env-hyprland" = lib.mkIf config.programs.hyprland.withUWSM {
      text =
        ''
          export AQ_DRM_DEVICES="/dev/dri/card2:/dev/dri/card1"
        '';
    };
    ".config/hypr/hyprland.conf" = {
      text =
        lib.strings.optionalString (!config.programs.hyprland.withUWSM) ''
          env = XCURSOR_THEME,Adwaita
          env = XCURSOR_SIZE,24

          env = XDG_DESKTOP_DIR,$HOME/Desktop
          env = XDG_DOCUMENTS_DIR,$HOME/Documents
          env = XDG_DOWNLOAD_DIR,$HOME/Downloads
          env = XDG_MUSIC_DIR,$HOME/Music
          env = XDG_PICTURES_DIR,$HOME/Pictures
          env = XDG_PUBLICSHARE_DIR,$HOME/Public
          env = XDG_TEMPLATES_DIR,$HOME/Templates
          env = XDG_VIDEOS_DIR,$HOME/Videos

          env = AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1

        '' + ''
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
          bind = ,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl --player playerctld play-pause
          bind = ,XF86AudioStop,exec,${pkgs.playerctl}/bin/playerctl --player playerctld stop
          bind = ,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl --player playerctld previous
          bind = ,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl --player playerctld next

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
  };
}
