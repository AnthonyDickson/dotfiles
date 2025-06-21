{lib, ...}:
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
          format = "{:%H:%M} ";
          format-alt = "{:%a, %d %b %H:%M} ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#f5e0dc'><b>{}</b></span>";
              days = "<span color='#f2cdcd'><b>{}</b></span>";
              weeks = "<span color='#a6e3a1'><b>W{}</b></span>";
              weekdays = "<span color='#fab387'><b>{}</b></span>";
              today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          interval = 5;
          format = lib.mkDefault "CPU {icon0}{icon1}{icon2}{icon3}";
          format-icons = [
            "<span color='#74c7ec'>▁</span>"
            "<span color='#89dceb'>▂</span>"
            "<span color='#94e2d5'>▃</span>"
            "<span color='#a6e3a1'>▄</span>"
            "<span color='#f9e2af'>▅</span>"
            "<span color='#fab387'>▆</span>"
            "<span color='#eba0ac'>▇</span>"
            "<span color='#f38ba8'>█</span>"
          ];
        };
        memory = {
          interval = 10;
          format = " {percentage}%";
          tooltip-format = "RAM {used:0.1f}G/{total:0.1f}G";
        };
        network = {
          interval = 5;
          family = "ipv4";
          format-ethernet = "󰈁 ↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}";
          format-wifi = "󰖩 {essid} ({signalStrength}) ↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}";
          format-disconnected = "󰈂 No Internet Connection";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
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
          scroll-step = 5;
          on-click = "pwvucontrol";
        };

        "custom/ncspot" = {
          exec = ./ncspot.sh;
          interval = 1;
          format = "{text} {icon}";
          format-icons = {
            default = "";
          };
          hide-empty-text = true;
          max-length = 32;
          tooltip-format = "{text}";
          on-click = ./focus-ncspot.sh;
        };
        "custom/ime" = {
          exec = ./current_ime.sh;
          interval = 2;
          format = "{text}";
          max-length = 8;
          tooltip = false;
        };
      };
    };
    style = ./waybar.css;
  };
}
