{ lib, hostname, ... }:

{
  xdg.configFile."niri/config.kdl".text = ''
    input {
        focus-follows-mouse
        keyboard {
            repeat-delay 600
            repeat-rate 40
            xkb {
                layout "us"
            }
        }
        mouse {
            accel-profile "flat"
        }
        touchpad {
            tap
            natural-scroll
        }
    }

    layout {
        gaps 6
        border {
            width 2
            active-color "#57ca57"
            inactive-color "#5a5a5a"
        }

        focus-ring {
            width 0
        }
    }

    prefer-no-csd

    spawn-at-startup "qs"

    window-rule {
        geometry-corner-radius 16
        clip-to-geometry true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Shift+E { quit; }
        Mod+Shift+Q { close-window; }

        Mod+Return { spawn "foot"; }
        Mod+D { spawn "qs" "ipc" "call" "launcher" "toggle"; }
        Mod+Shift+S { spawn "sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"; }

        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioPause { spawn "playerctl" "pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }
        XF86AudioStop { spawn "playerctl" "stop"; }
        XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+J     { move-window-down; }
        Mod+Ctrl+K     { move-window-up; }
        Mod+Ctrl+L     { move-column-right; }

        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        Mod+Shift+T { toggle-window-floating; }
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up   { focus-workspace-up; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+Shift+U { move-workspace-down; }
        Mod+Shift+I { move-workspace-up; }
        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }
        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }
        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }
    }

    window-rule {
        draw-border-with-background false
        shadow {
            off
        }
    }

    window-rule {
      open-fullscreen false
    }
  '' + lib.optionalString (hostname == "ladmin") ''

    output "DP-1" {
        mode "2560x1440@165.080"
        variable-refresh-rate
        position x=0 y=0
    }

    output "DP-2" {
        mode "2560x1440@59.951"
        transform "90"
        position x=2560 y=-715
    }
  '' + lib.optionalString (hostname == "ladmin-laptop") ''

    output "eDP-1" {
        mode "2800x1600"
        scale 1.75
        variable-refresh-rate
    }
  '';
}
