{ inputs, local, config, pkgs, lib, ... }:
let
  inherit (local.lib.generators) toHyprlang;

  theme = config.hjem.users.dev.theme;

  # Hyprland doesn't load the cursor theme correctly with Inherits.
  # The theme's cursor icons are overriden by Adwaita's.
  nierCursors = local.pkgs.cursorIcons.nier-cursors.overrideAttrs {
    postInstall =
      ''
        chmod -R +w $out/share/icons/nier-cursors
        sed -i -e 's/Inherits=.*//g' $out/share/icons/nier-cursors/index.theme
      '';
  };

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
  captureScript = pkgs.writeShellScript "hyprland-capture"
    ''
      COMMANDS=()
      SAVE_TO_FILE=
      while [ $# -gt 0 ]; do
        case $1 in
          --save)
            SAVE_TO_FILE=YES
            shift
            ;;
          -*|--*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
          *)
            COMMANDS+=("$1")
            shift
            ;;
        esac
      done

      if [ ":''${COMMANDS[0]}" = ":screen" ]; then
        if [ -n "$SAVE_TO_FILE" ]; then
          OUTPUT_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}
          OUTPUT_FILE=$(date +'screenshot-%Y%m%d%H%M%S.png')
          ${pkgs.grim}/bin/grim -t png -l 3 "$OUTPUT_DIR/$OUTPUT_FILE"
        else
          ${pkgs.grim}/bin/grim -t png -l 3 -\
            | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        fi
      elif [ ":''${COMMANDS[0]}" = ":region" ]; then
        # Disable Hyprland key binds.
        hyprctl dispatch submap noop

        REGION_WMCLASS="capture-region-temp"
        if [ -n "$SAVE_TO_FILE" ]; then
          OUTPUT_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}
          OUTPUT_FILE=$(date +'screenshot-%Y%m%d%H%M%S.png')
          ${pkgs.grim}/bin/grim -t png -l 0 -\
            | ${pkgs.feh}/bin/feh --class "$REGION_WMCLASS" -F - &
          ${pkgs.grim}/bin/grim -t png -l 3 \
            -g "$(${pkgs.slurp}/bin/slurp)" \
            "$OUTPUT_DIR/$OUTPUT_FILE"
          kill $!
        else
          TMP_FILE=$(mktemp)
          ${pkgs.grim}/bin/grim -t png -l 0 -\
            | ${pkgs.feh}/bin/feh --class "$REGION_WMCLASS" -F - &
          if ${pkgs.grim}/bin/grim -t png -l 3 -g "$(${pkgs.slurp}/bin/slurp)" "$TMP_FILE"; then
            ${pkgs.wl-clipboard}/bin/wl-copy -t image/png < "$TMP_FILE"
          fi
          kill $!
          rm -- "$TMP_FILE"
        fi

        # Restore Hyprland key bindings.
        hyprctl dispatch submap reset
      elif [ ":''${COMMANDS[0]}" = ":activewindow" ]; then
        ACTIVE_WINDOW="$(hyprctl -j activewindow)"
        if [ -z "$ACTIVE_WINDOW" ] || [ "$ACTIVE_WINDOW" = "{}" ]; then
          echo "No active windows found" >&2
          exit 1
        fi

        POS=($(${pkgs.jq}/bin/jq -n --argjson window "$ACTIVE_WINDOW" '$window.at[]'))
        SIZE=($(${pkgs.jq}/bin/jq -n --argjson window "$ACTIVE_WINDOW" '$window.size[]'))
        REGION="''${POS[0]},''${POS[1]} ''${SIZE[0]}x''${SIZE[1]}"

        if [ -n "$SAVE_TO_FILE" ]; then
          OUTPUT_DIR=''${XDG_PICTURES_DIR:-$HOME/Pictures}
          OUTPUT_FILE=$(date +'screenshot-%Y%m%d%H%M%S.png')
          ${pkgs.grim}/bin/grim -t png -l 3 -g "$REGION" "$OUTPUT_DIR/$OUTPUT_FILE"
        else
          ${pkgs.grim}/bin/grim -t png -l 3 -g "$REGION" -\
            | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        fi
      else
        echo "Unknown command: ''${COMMANDS[0]}" >&2
        exit 1
      fi
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
  users.users.dev.packages = with pkgs; [
    mako
  ];
  
  hjem.users.dev.files = {
    ".local/share/icons/nier-cursors" = {
      source = "${nierCursors}/share/icons/nier-cursors";
    };
    ".config/wallpaper" = {
      source = "${inputs.self}/wallpaper/${theme.wallpaper}";
    };
    ".config/uwsm/env" = lib.mkIf config.programs.hyprland.withUWSM {
      text =
        ''
          export GTK_THEME=
          export QT_QPA_PLATFORMTHEME=qt6ct
          export QT_STYLE_OVERRIDE=Adwaita-Dark
          export XCURSOR_THEME=nier-cursors
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
          env = GTK_THEME,
          env = QT_QPA_PLATFORMTHEME,qt6ct
          env = QT_STYLE_OVERRIDE,Adwaita-Dark
          env = XCURSOR_THEME,nier-cursors
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
          exec-once = hyprctl setcursor nier-cursors 24
          exec-once = ${startupScript}
          exec-shutdown = ${shutdownScript}

          monitor = eDP-1,1920x1080@144,0x0,1

          # hyprlang noerror true
          source = ~/.config/hypr/theme.conf
          # hyprlang noerror false

          workspace = 1,monitor:eDP-1,persistent:true
          workspace = 2,monitor:eDP-1,persistent:true
          workspace = 3,monitor:eDP-1,persistent:true
          workspace = 4,monitor:eDP-1,persistent:true
          workspace = 5,monitor:eDP-1,persistent:true
          workspace = 6,monitor:eDP-1,persistent:true

          # Window rules for capture region.
          windowrule = fullscreen,class:^capture-region-temp$
          windowrule = noanim,class:^capture-region-temp$
          windowrule = noinitialfocus,class:^capture-region-temp$
          windowrule = pin,class:^capture-region-temp$

          windowrule = tile,class:(steam),title:^Big-Picture-Mod(e|us)$

          general:layout = dwindle

          dwindle {
            pseudotile = true
            preserve_split = true
          }

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

          misc:vfr = true

          $mainMod = SUPER
          submap = noop
          # Panic reset
          bind = SUPER CTRL SHIFT ALT,Escape,submap,reset
          submap = reset

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

          bind = ,Print,exec,${captureScript} screen
          bind = ALT,Print,exec,${captureScript} region
          bind = $mainMod,Print,exec,${captureScript} activewindow
          bind = CTRL,Print,exec,${captureScript} screen --save
          bind = CTRL ALT,Print,exec,${captureScript} region --save
          bind = CTRL $mainMod,Print,exec,${captureScript} activewindow --save

          binde = ,XF86AudioLowerVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-
          binde = ,XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+
          binde = ,XF86MonBrightnessUp,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%+
          binde = ,XF86MonBrightnessDown,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%-

          bindm = $mainMod,mouse:272,movewindow
          bindm = $mainMod,mouse:273,resizewindow
        '';
    };
  };
}
