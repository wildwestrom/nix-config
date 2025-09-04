{ ... }:
{
  programs = {
    waybar = {
      enable = true;
      style = ''
        * {
            font-family: JetBrainsMono NF, monospace;
            font-size: 13px;
        }
      '';
      settings = {
        mainBar = {
          # "layer" = "top"; # Waybar at top layer
          position = "top"; # Waybar position (top|bottom|left|right)
          # height = 30; # Waybar height (to be removed for auto height)
          spacing = 4; # Gaps between modules (4px)
          # Choose the order of the modules
          modules-left = [
            "sway/workspaces"
            "sway/mode"
            "custom/media"
          ];
          modules-center = [ "sway/window" ];
          modules-right = [
            "idle_inhibitor"
            # "cpu"
            # "memory"
            "battery"
            # "thermometer"
            "clock"
            "backlight"
            "pulseaudio"
            "tray"
          ];
          "sway/window" = {
            "format" = "{title}";
            "max-length" = 50;
          };
          # Modules configuration
          # "sway/workspaces" = {
          #     "disable-scroll" = true,
          #     "all-outputs" = true,
          #     "format" = "{name} = {icon}",
          #     "format-icons" = {
          #         "1" = "",
          #         "2" = "",
          #         "3" = "",
          #         "4" = "",
          #         "5" = "",
          #         "urgent" = "",
          #         "focused" = "",
          #         "default" = ""
          #     }
          # },
          keyboard-state = {
            "numlock" = true;
            "capslock" = true;
            "format" = "{name} {icon}";
            "format-icons" = {
              "locked" = "";
              "unlocked" = "";
            };
          };
          "pulseaudio" = {
            "format" = "{volume}% {icon}";
            "format-bluetooth" = "{volume}% {icon}";
            "format-muted" = "";
            "format-icons" = {
              "headphone" = "";
              "hands-free" = "󰋎";
              "headset" = "󰋎";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                ""
              ];
            };
            "scroll-step" = 1;
            "on-click" = "pwvucontrol";
            "ignored-sinks" = [ "Easy Effects Sink" ];
          };
          "sway/mode" = {
            "format" = "<span style=\"italic\">{}</span>";
          };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          "tray" = {
            # "icon-size" = 21;
            "spacing" = 10;
          };
          "clock" = {
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format" = "{:%Ec}";
            "interval" = 1;
          };
          "cpu" = {
            "format" = "{usage}% ";
            "tooltip" = false;
            "interval" = 5;
          };
          "memory" = {
            "format" = "{}% ";
          };
          "temperature" = {
            "thermal-zone" = 2;
            "hwmon-path" = "/sys/class/hwmon/hwmon6/temp1_input";
            "critical-threshold" = 80;
            "format-critical" = "{temperatureC}°C {icon}";
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
            "interval" = 1;
          };
          "backlight" = {
            # "device" = "acpi_video1";
            "format" = "{percent}% {icon}";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "battery" = {
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% ";
            "format-plugged" = "{capacity}% ";
            # "format-alt" = "{capacity}% {icon}";
            # "format-good" = "{capacity}% {icon}";
            # "format-full" = "{capacity}% {icon}";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
        };
      };
    };
  };
}
