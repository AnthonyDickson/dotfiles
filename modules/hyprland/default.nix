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
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, N, movefocus, l"
        "$mod, O, movefocus, r"
        "$mod, E, movefocus, d"
        "$mod, I, movefocus, u"
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
              font_size = 72;
              font_family = "Sans";
              rotate = 0;
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = ''cmd[update:60000] echo $(date +"%A, %-d %b")'';
              text_align = "center";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 36;
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

  services = {
    dunst.enable = true;
    hyprpolkitagent.enable = true;
  };
}
