{
  # TODO: Split into modules
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
        "$mod, N, movefocus, l"
        "$mod, O, movefocus, r"
        "$mod, E, movefocus, d"
        "$mod, I, movefocus, u"
        "$mod SHIFT, N, movewindow, l"
        "$mod SHIFT, O, movewindow, r"
        "$mod SHIFT, E, movewindow, d"
        "$mod SHIFT, I, movewindow, u"
        "$mod, A, workspace, 1"
        "$mod, R, workspace, 2"
        "$mod, S, workspace, 3"
        "$mod, T, workspace, 4"
        "$mod SHIFT, A, movetoworkspace, 1"
        "$mod SHIFT, R, movetoworkspace, 2"
        "$mod SHIFT, S, movetoworkspace, 3"
        "$mod SHIFT, T, movetoworkspace, 4"
      ];
      exec-once = [
        "walker --gapplication-service"
        "dunst"
      ];
    };
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    walker = {
      enable = true;
      runAsService = true;
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
            disable_loading_bar = true;
            grace = 15;
            hide_cursor = true;
            no_fade_in = false;
          };

          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = 0.7;
              contrast = 0.7;
            }
          ];


          label = [
            {
              monitor = "";
              text = "$TIME";
              text_align = "center";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 118;
              font_family = "Sans";
              rotate = 0;
              position = "0, 120";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = ''cmd[update:60000] echo $(date +"%A, %-d %b")'';
              text_align = "center";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 34;
              font_family = "Sans";
              rotate = 0;
              position = "0, 0";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "400, 50";
              position = "0, -80";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              font_color = "rgb(202, 211, 245)";
              inner_color = "rgb(91, 96, 120)";
              outer_color = "rgb(24, 25, 38)";
              outline_thickness = 0;
              placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
            }
          ];
        };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";      # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session";   # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 900;                        # 15 min
          on-timeout = "loginctl lock-session"; # lock screen on timeout
        }
        {
          timeout = 930;                            # 15.5 min
          on-timeout = "hyprctl dispatch dpms off"; # screen off on timeout
          on-resume = "hyprctl dispatch dpms on";   # screen on on activity
        }
        {
          timeout = 930;                    # 15.5 min
          on-timeout = "systemctl suspend"; # suspend pc
        }
      ];
    };
  };

  services = {
    dunst.enable = true;
    hyprpolkitagent.enable = true;
  };
}
