{ ... }:
{
  programs = {
    waybar = {
      enable = true;
      style = ''
          * {
              font-family: FontAwesome, JetBrains Mono, monospace;
              font-size: 13px;
          }

        #   window#waybar {
        #       background-color: rgba(43, 48, 59, 0.5);
        #       border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        #       color: #ffffff;
        #       transition-property: background-color;
        #       transition-duration: .5s;
        #   }

        #   window#waybar.hidden {
        #       opacity: 0.2;
        #   }

        #   /*
        #   window#waybar.empty {
        #       background-color: transparent;
        #   }
        #   window#waybar.solo {
        #       background-color: #FFFFFF;
        #   }
        #   */

        #   window#waybar.termite {
        #       background-color: #3F3F3F;
        #   }

        #   window#waybar.chromium {
        #       background-color: #000000;
        #       border: none;
        #   }

        #   #workspaces button {
        #       padding: 0 5px;
        #       background-color: transparent;
        #       color: #ffffff;
        #       /* Use box-shadow instead of border so the text isn't offset */
        #       box-shadow: inset 0 -3px transparent;
        #       /* Avoid rounded borders under each workspace name */
        #       border: none;
        #       border-radius: 0;
        #   }

        #   /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        #   #workspaces button:hover {
        #       background: rgba(0, 0, 0, 0.2);
        #       box-shadow: inset 0 -3px #ffffff;
        #   }

        #   #workspaces button.focused {
        #       background-color: #64727D;
        #       box-shadow: inset 0 -3px #ffffff;
        #   }

        #   #workspaces button.urgent {
        #       background-color: #eb4d4b;
        #   }

        #   #mode {
        #       background-color: #64727D;
        #       border-bottom: 3px solid #ffffff;
        #   }

        #   #clock,
        #   #battery,
        #   #cpu,
        #   #memory,
        #   #disk,
        #   #temperature,
        #   #backlight,
        #   #network,
        #   #pulseaudio,
        #   #custom-media,
        #   #tray,
        #   #mode,
        #   #idle_inhibitor,
        #   #mpd {
        #       padding: 0 10px;
        #       color: #ffffff;
        #   }

        #   #window,
        #   #workspaces {
        #       margin: 0 4px;
        #   }

        #   /* If workspaces is the leftmost module, omit left margin */
        #   .modules-left > widget:first-child > #workspaces {
        #       margin-left: 0;
        #   }

        #   /* If workspaces is the rightmost module, omit right margin */
        #   .modules-right > widget:last-child > #workspaces {
        #       margin-right: 0;
        #   }

        #   #clock {
        #       background-color: #64727D;
        #   }

        #   #battery {
        #       background-color: #64727D;
        #   }

        #   #battery.charging, #battery.plugged {
        #       background-color: #64727D;
        #   }

        #   @keyframes blink {
        #       to {
        #           background-color: #ffffff;
        #           color: #000000;
        #       }
        #   }

        #   #battery.critical:not(.charging) {
        #       background-color: #f53c3c;
        #       color: #ffffff;
        #       animation-name: blink;
        #       animation-duration: 0.5s;
        #       animation-timing-function: linear;
        #       animation-iteration-count: infinite;
        #       animation-direction: alternate;
        #   }

        #   label:focus {
        #       background-color: #000000;
        #   }

        #   #cpu {
        #       background-color: #64727D;
        #   }

        #   #memory {
        #       background-color: #64727D;
        #   }

        #   #disk {
        #       background-color: #964B00;
        #   }

        #   #backlight {
        #       background-color: #64727D;
        #   }

        #   #network {
        #       background-color: #2980b9;
        #   }

        #   #network.disconnected {
        #       background-color: #f53c3c;
        #   }

        #   #pulseaudio {
        #       background-color: #f1c40f;
        #   }

        #   #pulseaudio.muted {
        #       background-color: #90b1b1;
        #   }

        #   #custom-media {
        #       background-color: #66cc99;
        #       min-width: 100px;
        #   }

        #   #custom-media.custom-spotify {
        #       background-color: #66cc99;
        #   }

        #   #custom-media.custom-vlc {
        #       background-color: #ffa000;
        #   }

        #   #temperature {
        #       background-color: #64727D;
        #   }

        #   #temperature.critical {
        #       background-color: #eb4d4b;
        #   }

        #   #tray {
        #       background-color: #64727D;
        #   }

        #   #tray > .passive {
        #       -gtk-icon-effect: dim;
        #   }

        #   #tray > .needs-attention {
        #       -gtk-icon-effect: highlight;
        #       background-color: #eb4d4b;
        #   }

        #   #idle_inhibitor {
        #       background-color: #2d3436;
        #   }

        #   #idle_inhibitor.activated {
        #       background-color: #ecf0f1;
        #       color: #2d3436;
        #   }

        #   #mpd {
        #       background-color: #66cc99;
        #       color: #2a5c45;
        #   }

        #   #mpd.disconnected {
        #       background-color: #f53c3c;
        #   }

        #   #mpd.stopped {
        #       background-color: #90b1b1;
        #   }

        #   #mpd.paused {
        #       background-color: #51a37a;
        #   }

        #   #language {
        #       background: #00b093;
        #       color: #740864;
        #       padding: 0 5px;
        #       margin: 0 5px;
        #       min-width: 16px;
        #   }

        #   #keyboard-state {
        #       background: #97e1ad;
        #       color: #000000;
        #       padding: 0 0px;
        #       margin: 0 5px;
        #       min-width: 16px;
        #   }

        #   #keyboard-state > label {
        #       padding: 0 5px;
        #   }

        #   #keyboard-state > label.locked {
        #       background: rgba(0, 0, 0, 0.2);
        #   }
        # '';
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
            "cpu"
            "memory"
            "battery"
            "thermometer"
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
            "on-click" = "pavucontrol";
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
              ""
              ""
            ];
            "interval" = 1;
          };
          "backlight" = {
            # "device" = "acpi_video1";
            "format" = "{percent}% {icon}";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
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
