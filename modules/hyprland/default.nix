{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, F, exec, firefox"
        "$mod, K, exec, kitty"
        "$mod, space, exec, walker"
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

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  services = {
    dunst.enable = true;
    hyprpolkitagent.enable = true;
  };
}
