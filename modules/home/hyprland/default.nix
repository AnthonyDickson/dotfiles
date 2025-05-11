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

          background =  {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = 0.7;
              contrast = 0.7;
          };

          label = [
            {
              monitor = "";
              text = "$TIME";
              text_align = "center";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 110;
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

          input-field =  {
              size = "400, 50";
              position = "0, -80";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              outline_thickness = 0;
              placeholder_text = "Password...";
          };
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
          timeout = 300;                        # 5 min
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

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = ["clock"];
        modules-right = ["cpu" "memory" "network" "pulseaudio"];

        "hyprland/workspaces" = {
          persistent-workspaces = {
            "*" = 4;
          };
        };
        "hyprland/window" = {
          format = "{class} - {title}";
          max-length = 32;
        };

        clock = {
          format = "{:%a, %d %b %H:%M}";
          tooltip = false;
        };

        cpu = {
           interval = 5;
           format = "CPU {icon0}{icon1}{icon2}{icon3}";
           format-icons = [
              "<span color='#69ff94'>▁</span>"
              "<span color='#2aa9ff'>▂</span>"
              "<span color='#f8f8f2'>▃</span>"
              "<span color='#f8f8f2'>▄</span>"
              "<span color='#ffffa5'>▅</span>"
              "<span color='#ffffa5'>▆</span>"
              "<span color='#ff9977'>▇</span>"
              "<span color='#dd532e'>█</span>"
           ];
        };
        memory = {
          interval = 10;
          format = "RAM {used:0.1f}G/{total:0.1f}G";
        };
        network = {
          interval = 5;
          family = "ipv4";
          # TODO: Print ipv4 address on local network
          format = "{ifname} ↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}";
          format-disconnected = "No Internet Connection";
        };

        pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            # TODO: Fix way showing mute icon when computer is not muted
            format-muted =  "";
            format-icons =  {
                "alsa_output.pci-0000_00_1f.3.analog-stereo" =  "";
                "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" =  "";
                headphone =  "";
                hands-free =  "";
                headset =  "";
                phone =  "";
                phone-muted =  "";
                portable =  "";
                car =  "";
                default =  ["" ""];
            };
            scroll-step = 1;
            # TODO: Add on click to open audio management program
        };
      };
    };
    style = ./waybar.css;
  };

  services = {
    dunst.enable = true;
    hyprpolkitagent.enable = true;
  };

  services.hyprpaper = {
    enable = true;
  };
}
