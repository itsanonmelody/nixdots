{ config, lib, pkgs, ... }:
with lib;
let
  terminal = "kitty";
  file-manager = "${terminal} yazi";
  launcher-cmd = "rofi -show drun";
  pomodoro = rec {
    cmd = "pomodoro";
    wmClass = "io.gitlab.idevecore.Pomodoro";
    windowRules = [
      "float,class:(${wmClass})"
      "pin,class:(${wmClass})"
      "size 285 415,class:(${wmClass}),title:(Pomodoro)"
    ];
  };
  initialBackgroundColor = strings.removePrefix "#"
    config.home.initialBackgroundColor;
in
{
  home.packages = with pkgs;
    [
      brightnessctl
      grim
      inotify-tools
      playerctl
      swww
      wl-clipboard

      (writeShellScriptBin "hyprland-login"
        ''
          hyprland-autoswww &
          waybar &
        '')
      (writeShellScriptBin "hyprland-logout"
        ''
          pkill waybar
          swww kill
        '')
      (writeShellScriptBin "hyprland-autoswww"
        ''
          export SWWW_TRANSITION=any
          export SWWW_TRANSITION_DURATION=2
          export SWWW_TRANSITION_FPS=60

          swww-daemon &
          swww clear ${initialBackgroundColor}
          swww img --resize fit "$HOME/.config/wallpaper"

          while :
          do
            if inotifywait -P -e'close_write,create,delete_self,modify,move_self,moved_to' "$HOME/.config/wallpaper";
            then
              swww img --resize fit "$HOME/.config/wallpaper"
            fi
          done
        '')
      (writeShellScriptBin "hyprland-toggle-pomodoro"
        ''
          if hyprctl clients | grep '${pomodoro.wmClass}'
          then
            hyprctl dispatch closewindow '${pomodoro.wmClass}'
          else
            hyprctl dispatch exec ${pomodoro.cmd}
          fi
        '')
      (writeShellScriptBin "hyprland-movefocus"
        ''
          declare -r OK=0
          declare -r NOK=1

          if [ $# -eq 0 ]
          then
            >&2 echo "Usage: $(basename $0) (l|u|r|d)"
            return 1
            exit 1
          fi

          window=`hyprctl activewindow`
          if [ ":$window" = ":Invalid" ]
          then
            >&2 echo "No active window"
            return 1
            exit 1
          fi

          window_id=`head -n 1 <<< "$window" | awk '{print $2}'`
          group_windows=(`grep grouped <<< "$window" | sed 's/grouped://;s/,/ /g' | xargs`)
          group_count=''${#windows[@]}

          is_grouped=$NOK
          group_first=
          group_last=
          if [ "''${group_windows[0]}" != '0' ]
          then
            is_grouped=$OK
            group_first=''${group_windows[0]}
            group_last=''${group_windows[$((group_count-1))]}
          fi

          if [ ":$1" = ":l" ]
          then
            if [ $is_grouped -eq $OK ] \
              && [ ":$window_id" != ":$group_first" ]
            then
              hyprctl dispatch changegroupactive b
            else
              hyprctl dispatch movefocus l
            fi
          elif [ ":$1" = ":u" ]
          then
            hyprctl dispatch movefocus u
          elif [ ":$1" = ":r" ]
          then
            if [ $is_grouped -eq $OK ] \
              && [ ":$window_id" != ":$group_last" ]
            then
              hyprctl dispatch changegroupactive f
            else
              hyprctl dispatch movefocus r
            fi
          elif [ ":$1" = ":d" ]
          then
            hyprctl dispatch movefocus d
          else
            >&2 echo "Unknown argument '$1'"
            >&2 echo "Usage: $(basename $0) (l|u|r|d)"
            return 1
            exit 1
          fi
        '')
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    xwayland.enable = true;

    # Only possible with Flakes
    # plugins = [ ];

    settings = {
      monitor = [
        "eDP-1,1920x1080@144,0x0,1"
      ];
      workspace = [
        "1,monitor:eDP-1,persistent:true"
        "2,monitor:eDP-1,persistent:true"
        "3,monitor:eDP-1,persistent:true"
        "4,monitor:eDP-1,persistent:true"
        "5,monitor:eDP-1,persistent:true"
        "6,monitor:eDP-1,persistent:true"
      ];
      windowrulev2 = [
        "tile,class:(steam),title:^Big-Picture-Mod(e|us)$"
        "float,class:(pavucontrol)"
        "size 475 500,class:(pavucontrol)"
      ] ++ pomodoro.windowRules;
      exec-once = [
        "hyprland-login"
      ];
      env = [
        "XCURSOR,24"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(fc9afaee) rgba(a37cffee) 30deg";
        "col.inactive_border" = "rgb(595959)";
        layout = "dwindle";
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      decoration = {
        rounding = 10;
        drop_shadow = false;

        blur = {
          enabled = true;
          popups = true;
          size = 4;
          passes = 2;
        };
      };
      animations = {
        enabled = true;
        bezier = [
          "myBezier,0.05,0.9,0.1,1.05"
        ];
        animation = [
          "windows,1,7,myBezier"
          "windowsOut,1,7,default,popin 80%"
          "border,1,10,default"
          "borderangle,1,8,default"
          "fade,1,7,default"
          "workspaces,1,6,default"
        ];
      };
      gestures = {
        workspace_swipe = false;
      };
      input = {
        kb_layout = "de";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        #resolve_binds_by_sym = true;
        accel_profile = "flat";
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };
      device = [
        {
          name = "keychron-k8-pro-keyboard";
          kb_layout = "us-dpe,eu";
          kb_variant = ",";
          kb_model = ",";
          kb_options = "grp:shift_caps_toggle";
          kb_rules = "";
        }
        {
          name = "keychron-keychron-k8-pro";
          kb_layout = "us-dpe,eu";
          kb_variant = ",";
          kb_model = ",";
          kb_options = "grp:shift_caps_toggle";
          kb_rules = "";
        }
        {
          name = "keychron-keychron-k8-pro-keyboard";
          kb_layout = "us-dpe,eu";
          kb_variant = ",";
          kb_model = ",";
          kb_options = "grp:shift_caps_toggle";
          kb_rules = "";
        }
      ];
      misc = {
        disable_hyprland_logo = true;
      };

      "$mainMod" = "SUPER";
      "$logoutCmd" = "hyprland-logout; hyprctl dispatch exit";
      bind = [
        "$mainMod,Q,exec,${terminal}"
        "$mainMod,C,killactive,"
        "$mainMod,M,exec,$logoutCmd"
        "$mainMod,E,exec,${file-manager}"
        "$mainMod,V,togglefloating,"
        "$mainMod,R,exec,${launcher-cmd}"
        "$mainMod,P,exec,hyprland-toggle-pomodoro"
        "$mainMod,F,fullscreen,0"
        "$mainMod,G,togglegroup,"
        "$mainMod,S,pin,active"

        "$mainMod,H,exec,hyprland-movefocus l"
        "$mainMod,J,exec,hyprland-movefocus d"
        "$mainMod,K,exec,hyprland-movefocus u"
        "$mainMod,L,exec,hyprland-movefocus r"

        "$mainMod ALT,H,movefocus,l"
        "$mainMod ALT,J,movefocus,d"
        "$mainMod ALT,K,movefocus,u"
        "$mainMod ALT,L,movefocus,r"

        "$mainMod,1,workspace,1"
        "$mainMod,2,workspace,2"
        "$mainMod,3,workspace,3"
        "$mainMod,4,workspace,4"
        "$mainMod,5,workspace,5"
        "$mainMod,6,workspace,6"

        "$mainMod SHIFT,1,movetoworkspace,1"
        "$mainMod SHIFT,2,movetoworkspace,2"
        "$mainMod SHIFT,3,movetoworkspace,3"
        "$mainMod SHIFT,4,movetoworkspace,4"
        "$mainMod SHIFT,5,movetoworkspace,5"
        "$mainMod SHIFT,6,movetoworkspace,6"

        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioStop,exec,playerctl stop"
        ",XF86AudioPrev,exec,playerctl previous"
        ",XF86AudioNext,exec,playerctl next"

        ",Print,exec,grim -t png - | wl-copy -t image/png"
      ];
      binde = [
        ",XF86AudioLowerVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"

        ",XF86MonBrightnessUp,exec,brightnessctl set 5%+"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
      ];
      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];
    };
  };
}
