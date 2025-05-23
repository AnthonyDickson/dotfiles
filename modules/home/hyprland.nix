{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, F, exec, firefox"
        "$mod, K, exec, kitty"
        "$mod, space, exec, walker"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, L, exec, loginctl lock-session && systemctl suspend"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        # Windows
        "$mod, N, movefocus, l"
        "$mod, O, movefocus, r"
        "$mod, E, movefocus, d"
        "$mod, I, movefocus, u"
        "$mod SHIFT, N, movewindow, l"
        "$mod SHIFT, O, movewindow, r"
        "$mod SHIFT, E, movewindow, d"
        "$mod SHIFT, I, movewindow, u"
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
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioStop, exec, playerctl --all-players stop"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];
      exec-once = [
        "walker --gapplication-service"
        "dunst"
        "waybar"
        "hyprpaper"
      ];
      windowrulev2 = [
        "float, title:^(Picture-in-Picture|Firefox)$"
        "size 400 225, title:^(Picture-in-Picture|Firefox)$"
        "pin, title:^(Picture-in-Picture|Firefox)$"
        # 20 100%-w-20 positions the window at the bottom-left with a 20 pixel margin
        "move onscreen 20 100%-w-20, title:^(Picture-in-Picture|Firefox)$"
      ];
    };
  };
}
