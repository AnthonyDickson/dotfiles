{mainMonitor, secondaryMonitor, ...}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = [
        "${mainMonitor}, 3840x2160@60, 0x0, 1.5"
        "${secondaryMonitor}, 2560x1440@60, auto-left, 1.0, transform, 3"
      ];
      workspace = [
        "1, monitor:${mainMonitor}, persistent:true, default:true, on-created-empty:firefox"
        "2, monitor:${mainMonitor}, persistent:true"
        "3, monitor:${mainMonitor}, persistent:true"
        "4, monitor:${mainMonitor}, persistent:true, on-created-empty:mail"
        "5, monitor:${secondaryMonitor}, persistent:true, default:true"
        "6, monitor:${secondaryMonitor}, persistent:true"
        "7, monitor:${secondaryMonitor}, persistent:true"
        "8, monitor:${secondaryMonitor}, persistent:true"
        "special:mail, on-created-empty:thunderbird"
      ];  
      bind = [
        # Applications
        "$mod, W, exec, firefox"
        "$mod, K, exec, kitty"
        "$mod, M, togglespecialworkspace, mail"
        # System
        "$mod, space, exec, walker"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, L, exec, loginctl lock-session && hyprctl dispatch dpms off && systemctl suspend"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, period, exec, walker -m symbols"
        ## Screenshots
        ", PRINT, exec, hyprshot --output-folder ~/Pictures --freeze --mode output"
        "$mod, PRINT, exec, hyprshot --output-folder ~/Pictures --freeze --mode window"
        "$mod SHIFT, PRINT, exec, hyprshot --output-folder ~/Pictures --freeze --mode region"
        # Windows
        "$mod, N, movefocus, l"
        "$mod, O, movefocus, r"
        "$mod, E, movefocus, d"
        "$mod, I, movefocus, u"
        "$mod SHIFT, N, movewindow, l"
        "$mod SHIFT, O, movewindow, r"
        "$mod SHIFT, E, movewindow, d"
        "$mod SHIFT, I, movewindow, u"
        "$mod, F, togglefloating"
        ## Groups
        "$mod, G, togglegroup"
        "$mod, TAB, changegroupactive, f"
        "$mod SHIFT, TAB, changegroupactive, b"
        "$mod ALT, N, moveintogroup, l"
        "$mod ALT, O, moveintogroup, r"
        "$mod ALT, E, moveintogroup, d"
        "$mod ALT, I, moveintogroup, u"
        # Workspaces
        "$mod, A, workspace, 1"
        "$mod, R, workspace, 2"
        "$mod, S, workspace, 3"
        "$mod, T, workspace, 4"
        "$mod, Z, workspace, 5"
        "$mod, X, workspace, 6"
        "$mod, C, workspace, 7"
        "$mod, D, workspace, 8"
        "$mod SHIFT, A, movetoworkspace, 1"
        "$mod SHIFT, R, movetoworkspace, 2"
        "$mod SHIFT, S, movetoworkspace, 3"
        "$mod SHIFT, T, movetoworkspace, 4"
        "$mod SHIFT, Z, movetoworkspace, 5"
        "$mod SHIFT, X, movetoworkspace, 6"
        "$mod SHIFT, C, movetoworkspace, 7"
        "$mod SHIFT, D, movetoworkspace, 8"
      ];
      # Bind mouse
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      # Bind when _l_ocked and when the key r_e_peats.
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
      # Bind when _l_ocked
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, fish ${./playerctl-current-player-play-pause.fish}"
        ", XF86AudioStop, exec, fish ${./playerctl-current-player-stop.fish}"
        ", XF86AudioPrev, exec, fish ${./playerctl-current-player-previous.fish}"
        ", XF86AudioNext, exec, fish ${./playerctl-current-player-next.fish}"
        "$mod, XF86AudioPlay, exec, playerctl play-pause --all-players"
        "$mod, XF86AudioStop, exec, playerctl stop --all-players"
        "$mod SHIFT, L, exec, hyprctl dispatch dpms off && systemctl suspend"
      ];
      exec-once = [
        "NIXOS_OZONE_WL=1 walker --gapplication-service"
        "dunst"
        "waybar"
        "hyprpaper"
        "fcitx5 -d"
      ];
      windowrulev2 = [
        # PiP for Firefox
        "float, title:^(Picture-in-Picture|Firefox)$"
        "size 400 225, title:^(Picture-in-Picture|Firefox)$"
        "pin, title:^(Picture-in-Picture|Firefox)$"
        ## positions the window at the bottom-right with a 20 pixel margin
        "move onscreen 100%-w-20 100%-w-20, title:^(Picture-in-Picture|Firefox)$"
        # Special Workspace Startup Apps
        "workspace special:mail, title:^(.*Thunderbird)$"
      ];
      general = {
        "gaps_in" = 5; # pixels
        "gaps_out" = 5; # pixels
      };
      decoration = {
        rounding = 5; # pixels
      };
    };
  };
}
