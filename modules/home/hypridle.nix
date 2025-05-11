{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 300; # 5 min
          on-timeout = "loginctl lock-session"; # lock screen on timeout
        }
        {
          timeout = 930; # 15.5 min
          on-timeout = "hyprctl dispatch dpms off"; # screen off on timeout
          on-resume = "hyprctl dispatch dpms on"; # screen on on activity
        }
        {
          timeout = 930; # 15.5 min
          on-timeout = "systemctl suspend"; # suspend pc
        }
      ];
    };
  }; 
}
