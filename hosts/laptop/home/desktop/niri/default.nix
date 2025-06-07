{ inputs, local, config, pkgs, lib, ... }:
let
  theme = config.hjem.users.dev.theme;

  inherit (local.lib.colors)
    toHexStringRgb;
in
{
  users.users.dev.packages = with pkgs; [
    mako
  ];
  
  hjem.users.dev.files = {
    ".config/wallpaper" = {
      source = "${inputs.self}/wallpaper/${theme.wallpaper}";
    };
    ".config/wlr-which-key/config.yaml" = {
      text =
        ''
          font: ${theme.fonts.mainMono} 10
          background: "#${toHexStringRgb theme.colors.main}d0"
          color: "#${toHexStringRgb theme.colors.secondary}"
          border: "#${toHexStringRgb theme.colors.secondaryTint}"
          separator: " ↦ "
          border_width: 1
          corner_r: 0
          padding: 10
          #rows_per_column: 10

          anchor: bottom
          margin_bottom: 15

          #inhibit_compositor_keyboard_shortcuts: true

          menu:
            "C":
              desc: Quit niri
              cmd: niri msg action quit
            "c":
              desc: Column positioning commands
              submenu:
                "c":
                  desc: Center column
                  cmd: niri msg action center-column
                "C":
                  desc: Center all visible columns
                  cmd: niri msg action center-visible-columns
            "f":
              desc: Column expansion commands
              submenu:
                "f":
                  desc: Maximise column
                  cmd: niri msg action maximize-column
                "F":
                  desc: Expand column to available width
                  cmd: niri msg action expand-column-to-available-width
            "F":
              desc: Fullscreen window
              cmd: niri msg action fullscreen-window
            "t":
              desc: Toggle column tabbed display
              cmd: niri msg action toggle-column-tabbed-display
            "p":
              desc: Power off monitors
              cmd: niri msg action power-off-monitors
            "o":
              desc: Toggle overview
              cmd: niri msg action toggle-overview
            "s":
              desc: Set dynamic screencast target
              submenu:
                "s":
                  desc: Select focused window
                  cmd: niri msg action set-dynamic-cast-window
                "m":
                  desc: Select focused monitor
                  cmd: niri msg action set-dynamic-cast-monitor
                "c":
                  desc: Clear dynamic cast target
                  cmd: niri msg action clear-dynamic-cast-target
        '';
    };
    ".config/niri/config.kdl" = {
      text =
        ''
          spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
          spawn-at-startup "${pkgs.waybar}/bin/waybar"
          spawn-at-startup "${pkgs.playerctl}/bin/playerctld"

          prefer-no-csd

          environment {
            DISPLAY ":0"

            GTK_THEME ""
            QT_QPA_PLATFORMTHEME "qt6ct"
            QT_STYLE_OVERRIDE "Adwaita-Dark"
            XCURSOR_THEME "nier-cursors"
            XCURSOR_SIZE "24"

            XDG_DESKTOP_DIR "$HOME/Desktop"
            XDG_DOCUMENTS_DIR "$HOME/Documents"
            XDG_DOWNLOAD_DIR "$HOME/Downloads"
            XDG_MUSIC_DIR "$HOME/Music"
            XDG_PICTURES_DIR "$HOME/Pictures"
            XDG_PUBLICSHARE_DIR "$HOME/Public"
            XDG_TEMPLATES_DIR "$HOME/Templates"
            XDG_VIDEOS_DIR "$HOME/Videos"
          }

          input {
            keyboard {
              xkb {
                layout "eu"
              }

              numlock
            }

            mouse {
              accel-profile "flat"
            }

            warp-mouse-to-focus
          }

          output "eDP-1" {
            mode "1920x1080@60.003"
          }

          output "Microstep MSI MAG 256F BC1H175301673" {
            mode "1920x1080@179.998"
          }

          layout {
            gaps 0

            preset-column-widths {
              proportion 0.25
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
              proportion 0.75
            }

            default-column-width { proportion 0.5; }

            preset-window-heights {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
            }

            focus-ring {
              off
            }

            border {
              width 2
              active-color "#${toHexStringRgb theme.colors.secondary}"
              inactive-color "#${toHexStringRgb theme.colors.mainTint}"
              urgent-color "#${toHexStringRgb theme.colors.accents.red}"
            }

            tab-indicator {
              gap 0
              width 5
              active-color "#${toHexStringRgb theme.colors.secondary}"
              inactive-color "#${toHexStringRgb theme.colors.mainTint}"
              urgent-color "#${toHexStringRgb theme.colors.accents.red}"
            }

            struts {
              left 15
              right 15
            }
          }

          window-rule {
            open-maximized true
          }

          window-rule {
            match app-id="kitty"
            open-maximized false
          }

          window-rule {
            match app-id="Emacs"
            open-maximized false
          }

          window-rule {
            match app-id="wasistlos"
            block-out-from "screen-capture"
          }

          window-rule {
            match app-id="gcr-prompter"
            block-out-from "screen-capture"
          }

          window-rule {
            match app-id="Signal"
            block-out-from "screen-capture"
          }

          hotkey-overlay {
            skip-at-startup
          }

          gestures {
            hot-corners {
              off
            }
          }

          binds {
            Mod+T hotkey-overlay-title="Open a terminal instance: kitty" { spawn "${pkgs.kitty}/bin/kitty"; }
            Mod+R hotkey-overlay-title="Run an Application: rofi" { spawn "${pkgs.rofi-wayland}/bin/rofi" "-show" "drun"; }
            Mod+X hotkey-overlay-title="Run subcommands: wlr-which-key" { spawn "${pkgs.wlr-which-key}/bin/wlr-which-key"; }

            Mod+C { close-window; }

            Mod+S { switch-preset-column-width; }
            Mod+Shift+S { switch-preset-window-height; }
            Mod+Ctrl+S { reset-window-height; }

            Mod+BracketLeft { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }
            Mod+Comma { consume-window-into-column; }
            Mod+Period { expel-window-from-column; }

            Mod+F { focus-column-right; }
            Mod+B { focus-column-left; }
            Mod+N { focus-window-down; }
            Mod+P { focus-window-up; }
            Mod+Right { focus-column-right; }
            Mod+Left { focus-column-left; }
            Mod+Down { focus-window-down; }
            Mod+Up { focus-window-up; }

            Mod+Ctrl+F { move-column-right; }
            Mod+Ctrl+B { move-column-left; }
            Mod+Ctrl+N { move-window-down; }
            Mod+Ctrl+P { move-window-up; }
            Mod+Ctrl+Right { move-column-right; }
            Mod+Ctrl+Left { move-column-left; }
            Mod+Ctrl+Down { move-window-down; }
            Mod+Ctrl+Up { move-window-up; }

            Mod+A { focus-column-first; }
            Mod+E { focus-column-last; }
            Mod+Home { focus-column-first; }
            Mod+End { focus-column-last; }

            Mod+Ctrl+A { move-column-to-first; }
            Mod+Ctrl+E { move-column-to-last; }
            Mod+Ctrl+Home { move-column-to-first; }
            Mod+Ctrl+End { move-column-to-last; }

            Mod+U { focus-workspace-up; }
            Mod+D { focus-workspace-down; }
            Mod+Page_Up { focus-workspace-up; }
            Mod+Page_Down { focus-workspace-down; }

            Mod+Ctrl+U { move-column-to-workspace-up; }
            Mod+Ctrl+D { move-column-to-workspace-down; }
            Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
            Mod+Ctrl+Page_Down { move-column-to-workspace-down; }

            Mod+Shift+U { move-workspace-up; }
            Mod+Shift+D { move-workspace-down; }
            Mod+Shift+Page_Up { move-workspace-up; }
            Mod+Shift+Page_Down { move-workspace-down; }

            Mod+Shift+F { focus-monitor-right; }
            Mod+Shift+B { focus-monitor-left; }
            Mod+Shift+N { focus-monitor-down; }
            Mod+Shift+P { focus-monitor-up; }
            Mod+Shift+Right { focus-monitor-right; }
            Mod+Shift+Left { focus-monitor-left; }
            Mod+Shift+Down { focus-monitor-down; }
            Mod+Shift+Up { focus-monitor-up; }

            Mod+Ctrl+Shift+F { move-column-to-monitor-right; }
            Mod+Ctrl+Shift+B { move-column-to-monitor-left; }
            Mod+Ctrl+Shift+N { move-column-to-monitor-down; }
            Mod+Ctrl+Shift+P { move-column-to-monitor-up; }
            Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }
            Mod+Ctrl+Shift+Left { move-column-to-monitor-left; }
            Mod+Ctrl+Shift+Down { move-column-to-monitor-down; }
            Mod+Ctrl+Shift+Up { move-column-to-monitor-up; }

            Mod+Ctrl+Shift+U { move-workspace-to-monitor-previous; }
            Mod+Ctrl+Shift+D { move-workspace-to-monitor-next; }
            Mod+Ctrl+Shift+Page_Up { move-workspace-to-monitor-previous; }
            Mod+Ctrl+Shift+Page_Down { move-workspace-to-monitor-next; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }

            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }
            Mod+Shift+Minus { set-window-height "-10%"; }
            Mod+Shift+Equal { set-window-height "+10%"; }

            Mod+V { toggle-window-floating; }
            Mod+Shift+V { switch-focus-between-floating-and-tiling; }

            Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }

            XF86MonBrightnessUp allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume"  "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%+"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume"  "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%-"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

            XF86AudioPlay allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "--player" "playerctld" "play-pause"; }
            XF86AudioStop allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "--player" "playerctld" "stop"; }
            XF86AudioPrev allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "--player" "playerctld" "previous"; }
            XF86AudioNext allow-when-locked=true { spawn "${pkgs.playerctl}/bin/playerctl" "--player" "playerctld" "next"; }
          }
        '';
    };
  };
}
