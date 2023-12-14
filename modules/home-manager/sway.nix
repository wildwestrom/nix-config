{pkgs, ...}: let
  jetbrainsnf = "JetBrainsMono Nerd Font Mono";
in {
  imports = [
    ./wayland.nix
  ];

  services = {
    kanshi = {
      enable = true;
    };
    swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
        {
          event = "lock";
          command = "lock";
        }
      ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    config = let
      super = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      menu = "${pkgs.fuzzel}/bin/fuzzel -i Adwaita -B 0 -r 0 -b 302f2ef8 -t d0d0d0ff -S ffffffff -s 1793d1ff -f 'Noto Sans:size=14' -w 50";
      workspace = a: "workspace " + a;
      ws1 = workspace "1";
      ws2 = workspace "2";
      ws3 = workspace "3";
      ws4 = workspace "4";
      ws5 = workspace "5";
      ws6 = workspace "6";
      ws7 = workspace "7";
      ws8 = workspace "8";
      ws9 = workspace "9";
      ws10 = workspace "bg";
    in {
      modifier = super;
      floating = {
        modifier = "${super}";
      };
      focus = {
        followMouse = "always";
        mouseWarping = "output";
        newWindow = "urgent";
        wrapping = "yes";
      };
      left = "${left}";
      down = "${down}";
      up = "${up}";
      right = "${right}";
      keybindings = {
        "${super}+space" = "focus mode_toggle";
        "${super}+Shift+c" = "reload";
        "${super}+a" = "focus parent";
        "${super}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${super}+Shift+Return" = "exec ${pkgs.librewolf}/bin/librewolf --new-window";
        "${super}+Shift+f" = "exec ${pkgs.cinnamon.nemo-with-extensions}/bin/nemo";
        "${super}+q" = "kill";
        "${super}+d" = "exec ${menu}";
        # Layout
        "${super}+b" = "splith";
        "${super}+v" = "splitv";
        "${super}+s" = "stacking";
        "${super}+w" = "tabbed";
        "${super}+e" = "toggle split";
        "${super}+f" = "fullscreen";
        # Moving around
        "${super}+${left}" = "focus left";
        "${super}+${down}" = "focus down";
        "${super}+${up}" = "focus up";
        "${super}+${right}" = "focus right";
        # Move the window
        "${super}+Shift+${left}" = "move left";
        "${super}+Shift+${down}" = "move down";
        "${super}+Shift+${up}" = "move up";
        "${super}+Shift+${right}" = "move right";
        # Switch workspace
        "${super}+1" = ws1;
        "${super}+2" = ws2;
        "${super}+3" = ws3;
        "${super}+4" = ws4;
        "${super}+5" = ws5;
        "${super}+6" = ws6;
        "${super}+7" = ws7;
        "${super}+8" = ws8;
        "${super}+9" = ws9;
        "${super}+0" = ws10;
        # Move focused window to workspace
        "${super}+Shift+1" = "move container to ${ws1}";
        "${super}+Shift+2" = "move container to ${ws2}";
        "${super}+Shift+3" = "move container to ${ws3}";
        "${super}+Shift+4" = "move container to ${ws4}";
        "${super}+Shift+5" = "move container to ${ws5}";
        "${super}+Shift+6" = "move container to ${ws6}";
        "${super}+Shift+7" = "move container to ${ws7}";
        "${super}+Shift+8" = "move container to ${ws8}";
        "${super}+Shift+9" = "move container to ${ws9}";
        "${super}+Shift+0" = "move container to ${ws10}";
      };
      keycodebindings = {
        "113" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "114" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "115" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";

        "224" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
        "225" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
      };
      bars = [
        {
          fonts = {
            names = ["${jetbrainsnf}"];
          };
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
      defaultWorkspace = "${ws1}";
      startup = [
        {command = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";}
        {command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";}
        {command = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --indicator";}
      ];
      output = {
        eDP-1 = {
          scale = "1.25";
        };
      };
      input = {
        "*" = {
          xkb_numlock = "enable";
        };
        "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
          # disable touchpad while typing
          dwt = "enabled";
          natural_scroll = "disabled";
          accel_profile = "adaptive";
          # pointer_accel = "0.1";
          scroll_factor = "0.75";
          tap = "enabled";
          tap_button_map = "lmr";
        };
      };
      fonts = {
        names = ["Sarasa Mono K" "Sarasa Mono J" "${jetbrainsnf}"];
        size = 12.0;
      };
      modes = {
        default = {
        };
      };
    };
  };
  programs = {
    waybar = {
      enable = true;
      style = ''
        * {
            font-family: FontAwesome, Noto Sans CJK JP, ${jetbrainsnf}, monospace;
            font-size: 13px;
        }

        window#waybar {
            background-color: rgba(43, 48, 59, 0.5);
            border-bottom: 3px solid rgba(100, 114, 125, 0.5);
            color: #ffffff;
            transition-property: background-color;
            transition-duration: .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        /*
        window#waybar.empty {
            background-color: transparent;
        }
        window#waybar.solo {
            background-color: #FFFFFF;
        }
        */

        window#waybar.termite {
            background-color: #3F3F3F;
        }

        window#waybar.chromium {
            background-color: #000000;
            border: none;
        }

        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #ffffff;
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each workspace name */
            border: none;
            border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
            box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.focused {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
            background-color: #eb4d4b;
        }

        #mode {
            background-color: #64727D;
            border-bottom: 3px solid #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #mpd {
            padding: 0 10px;
            color: #ffffff;
        }

        #window,
        #workspaces {
            margin: 0 4px;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        #clock {
            background-color: #64727D;
        }

        #battery {
            background-color: #64727D;
        }

        #battery.charging, #battery.plugged {
            background-color: #64727D;
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: #000000;
            }
        }

        #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: #ffffff;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        label:focus {
            background-color: #000000;
        }

        #cpu {
            background-color: #64727D;
        }

        #memory {
            background-color: #64727D;
        }

        #disk {
            background-color: #964B00;
        }

        #backlight {
            background-color: #64727D;
        }

        #network {
            background-color: #2980b9;
        }

        #network.disconnected {
            background-color: #f53c3c;
        }

        #pulseaudio {
            background-color: #f1c40f;
        }

        #pulseaudio.muted {
            background-color: #90b1b1;
        }

        #custom-media {
            background-color: #66cc99;
            min-width: 100px;
        }

        #custom-media.custom-spotify {
            background-color: #66cc99;
        }

        #custom-media.custom-vlc {
            background-color: #ffa000;
        }

        #temperature {
            background-color: #64727D;
        }

        #temperature.critical {
            background-color: #eb4d4b;
        }

        #tray {
            background-color: #64727D;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            background-color: #eb4d4b;
        }

        #idle_inhibitor {
            background-color: #2d3436;
        }

        #idle_inhibitor.activated {
            background-color: #ecf0f1;
            color: #2d3436;
        }

        #mpd {
            background-color: #66cc99;
            color: #2a5c45;
        }

        #mpd.disconnected {
            background-color: #f53c3c;
        }

        #mpd.stopped {
            background-color: #90b1b1;
        }

        #mpd.paused {
            background-color: #51a37a;
        }

        #language {
            background: #00b093;
            color: #740864;
            padding: 0 5px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state {
            background: #97e1ad;
            color: #000000;
            padding: 0 0px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state > label {
            padding: 0 5px;
        }

        #keyboard-state > label.locked {
            background: rgba(0, 0, 0, 0.2);
        }
      '';
      settings = {
        mainBar = {
          # "layer" = "top"; # Waybar at top layer
          position = "top"; # Waybar position (top|bottom|left|right)
          height = 30; # Waybar height (to be removed for auto height)
          spacing = 4; # Gaps between modules (4px)
          # Choose the order of the modules
          modules-left = ["sway/workspaces" "sway/mode" "custom/media"];
          modules-center = ["sway/window"];
          modules-right = [
            "idle_inhibitor"
            "cpu"
            "memory"
            "backlight"
            "battery"
            "clock"
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
            # "timezone" = "America/New_York";
            "tooltip-format" = "<big>{ =%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format" = "{ =%Y-%m-%d %H =%M =%S}";
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
            # "thermal-zone" = 2;
            "hwmon-path" = "/sys/class/hwmon/hwmon6/temp1_input";
            "critical-threshold" = 80;
            # "format-critical" = "{temperatureC}°C {icon}";
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = ["" "" ""];
            "interval" = 1;
          };
          "backlight" = {
            # "device" = "acpi_video1";
            "format" = "{percent}% {icon}";
            "format-icons" = ["" "" "" "" "" "" "" "" ""];
          };
          "battery" = {
            "states" = {
              # "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% ";
            "format-plugged" = "{capacity}% ";
            "format-alt" = "{time} {icon}";
            # "format-good" = ""; // An empty format will hide the module
            # "format-full" = "";
            "format-icons" = ["" "" "" "" ""];
          };
        };
      };
    };
    swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
      };
    };
  };
}
