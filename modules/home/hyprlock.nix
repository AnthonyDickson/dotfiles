let
  mainMonitor = "DP-1";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 15;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.7;
        contrast = 0.7;
      };

      label = [
        {
          monitor = mainMonitor;
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
          monitor = mainMonitor;
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

      input-field = {
        size = "400, 50";
        position = "0, -80";
        monitor = mainMonitor;
        dots_center = true;
        fade_on_empty = false;
        outline_thickness = 0;
        placeholder_text = "Password...";
      };
    };
  };
}
