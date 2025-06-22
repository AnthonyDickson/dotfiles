{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, W, exec, firefox"
        "$mod, K, exec, kitty"
        "$mod, space, exec, walker"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, L, exec, loginctl lock-session && hyprctl dispatch dpms off && systemctl suspend"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, period, exec, walker -m emojis"
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
        # Workspaces
        "$mod, A, workspace, 1"
        "$mod, R, workspace, 2"
        "$mod, S, workspace, 3"
        "$mod, T, workspace, 4"
        "$mod SHIFT, A, movetoworkspace, 1"
        "$mod SHIFT, R, movetoworkspace, 2"
        "$mod SHIFT, S, movetoworkspace, 3"
        "$mod SHIFT, T, movetoworkspace, 4"
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
        "walker --gapplication-service"
        "dunst"
        "waybar"
        "hyprpaper"
        "fcitx5 -d"
      ];
      windowrulev2 = [
        "float, title:^(Picture-in-Picture|Firefox)$"
        "size 400 225, title:^(Picture-in-Picture|Firefox)$"
        "pin, title:^(Picture-in-Picture|Firefox)$"
        # positions the window at the bottom-right with a 20 pixel margin
        "move onscreen 100%-w-20 100%-w-20, title:^(Picture-in-Picture|Firefox)$"
      ];
      general = {
        "gaps_in" = 5; # pixels
        "gaps_out" = 10; # pixels
      };
      decoration = {
        rounding = 5; # pixels
      };
    };
  };
}
