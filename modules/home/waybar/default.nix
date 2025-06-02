{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [
          "cpu"
          "memory"
          "network"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "custom/ncspot"
          "pulseaudio"
          "custom/ime"
          "clock"
        ];

        "hyprland/workspaces" = {
          persistent-workspaces = {
            "*" = 4;
          };
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
          format-muted = "";
          format-icons = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            phone-muted = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };
          scroll-step = 1;
          on-click = "pwvucontrol";
        };

        "custom/ncspot" = {
          exec = ./ncspot.sh;
          interval = 1;
          format = "{icon} {text}";
          format-icons = {
            default = "";
          };
          hide-empty-text = true;
          max-length = 32;
          toolbar = true;
          toolbar-format = "{text}";
          on-click = ./focus-ncspot.sh;
        };
        "custom/ime" = {
          exec = ./current_ime.sh;
          interval = 2;
          format = "{text}";
          max-length = 8;
          toolbar = true;
          toolbar-format = "{text}";
        };
      };
    };
    style = ./waybar.css;
  };
}
