{
  lib,
  pkgs,
  ...
}:
let
  # Out-of-store so the window can be retuned without a rebuild. Parsed rather
  # than sourced: it's meant to be hand-edited, not executed.
  readRemoteAwakeConf = ''
    conf="''${XDG_CONFIG_HOME:-$HOME/.config}/waybar/remote-awake.conf"

    tz=America/New_York
    start=08:00
    end=22:00
    label=""

    if [ -r "$conf" ]; then
      while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
          '#'* | "") ;;
          TZ=*) tz=''${line#TZ=} ;;
          START=*) start=''${line#START=} ;;
          END=*) end=''${line#END=} ;;
          LABEL=*) label=''${line#LABEL=} ;;
        esac
      done < "$conf"
    fi
  '';

  remoteAwake = pkgs.writeShellApplication {
    name = "waybar-clock-remote-awake";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
      gnused
      jq
      tzdata
    ];
    text = ''
      # Text is local time; the remote zone only picks the CSS class.

      # %a, %b and cal(1)'s headings are all translated
      export LC_TIME=C

      ${readRemoteAwakeConf}

      pango_escape() {
        sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
      }

      emit() {
        jq -nc --arg text "$1" --arg tooltip "$2" --arg class "$3" \
          '{text: $text, tooltip: $tooltip, class: $class}'
      }

      now_local=$(date '+%a %b %e %Y %H:%M:%S')

      # date(1) falls back to UTC on an unknown zone, so check rather than lie.
      zonedir="''${TZDIR:-${pkgs.tzdata}/share/zoneinfo}"
      if [ ! -e "$zonedir/$tz" ]; then
        emit "$now_local" "Unknown timezone: $(printf '%s' "$tz" | pango_escape)" error
        exit 0
      fi

      for pair in "START=$start" "END=$end"; do
        case "''${pair#*=}" in
          [0-9][0-9]:[0-9][0-9]) ;;
          *)
            emit "$now_local" "Expected HH:MM, got $(printf '%s' "$pair" | pango_escape)" error
            exit 0
            ;;
        esac
      done

      # 10# forces base 10 - without it, 08 and 09 are invalid octal.
      to_min() {
        h=''${1%%:*}
        m=''${1##*:}
        echo "$((10#$h * 60 + 10#$m))"
      }

      now_there=$(TZ="$tz" date +%H:%M)
      n=$(to_min "$now_there")
      s=$(to_min "$start")
      e=$(to_min "$end")

      # End before start means the window wraps past midnight.
      if [ "$s" -le "$e" ]; then
        if [ "$n" -ge "$s" ] && [ "$n" -lt "$e" ]; then class=awake; else class=asleep; fi
      else
        if [ "$n" -ge "$s" ] || [ "$n" -lt "$e" ]; then class=awake; else class=asleep; fi
      fi

      if [ -z "$label" ]; then
        label=''${tz##*/}
        label=''${label//_/ }
      fi

      # tail drops cal's own heading; the sed turns its reverse-video "today"
      # into <b>, which beats guessing which number is today.
      calendar=$(
        cal --color=always \
          | tail -n +2 \
          | pango_escape \
          | sed -e 's/\x1b\[7m/<b>/g' -e 's/\x1b\[0m/<\/b>/g' -e 's/\x1b\[[0-9;]*m//g'
      )

      month=$(date +'%Y %B' | pango_escape)
      there=$(printf '%s: %s - %s' "$label" "$now_there" "$class" | pango_escape)

      tooltip=$(printf '<big>%s</big>\n<tt><small>%s</small></tt>\n%s' \
        "$month" "$calendar" "$there")

      emit "$now_local" "$tooltip" "$class"
    '';
  };

  remoteAwakeEdit = pkgs.writeShellApplication {
    name = "waybar-clock-remote-awake-edit";
    runtimeInputs = with pkgs; [
      zenity
      coreutils
      gawk
      gnugrep
      tzdata
    ];
    text = ''
      # Right-click handler: retune the awake window without touching Nix.

      ${readRemoteAwakeConf}

      zonedir="''${TZDIR:-${pkgs.tzdata}/share/zoneinfo}"

      # Field 3 of zone1970.tab is the zone name; the file lists canonical zones
      # only, so no alias duplicates. Keep it to one --column: zenity fills cells
      # across columns round-robin, so a second would pack three zones per row.
      tz_choice=$(
        grep -v '^#' "$zonedir/zone1970.tab" \
          | awk -F'\t' '{ print $3 }' \
          | sort \
          | zenity --list \
              --title="Timezone" \
              --text="Which timezone should the clock track?
      Currently $tz - press OK without selecting anything to keep it." \
              --column="Timezone" \
              --width=640 --height=520
      ) || exit 0

      # zenity sometimes echoes the value twice, separator-joined.
      tz_choice=''${tz_choice%%|*}
      if [ -n "$tz_choice" ]; then
        tz=$tz_choice
      fi

      # --forms can't prefill entries, so blank means "leave it alone".
      out=$(
        zenity --forms \
          --title="Remote awake window" \
          --text="Currently set to $tz from $start to $end. Blank fields keep their value." \
          --add-entry="Awake from (HH:MM)" \
          --add-entry="Awake until (HH:MM)" \
          --separator="|"
      ) || exit 0

      IFS='|' read -r new_start new_end <<< "$out"

      if [ -n "$new_start" ]; then start=$new_start; fi
      if [ -n "$new_end" ]; then end=$new_end; fi

      # The picker can't produce a bad zone, but declining to pick keeps
      # whatever was hand-written.
      if [ ! -e "$zonedir/$tz" ]; then
        zenity --error --text="Not a known timezone: $tz"
        exit 1
      fi

      for pair in "start=$start" "end=$end"; do
        case "''${pair#*=}" in
          [0-9][0-9]:[0-9][0-9]) ;;
          *)
            zenity --error --text="Expected HH:MM for ''${pair%%=*}, got ''${pair#*=}"
            exit 1
            ;;
        esac
      done

      mkdir -p "$(dirname "$conf")"
      tmp=$(mktemp "$conf.XXXXXX")
      {
        echo "# Turn the Waybar clock green while it's a sane hour in this timezone."
        echo "# Written by waybar-clock-remote-awake-edit; safe to edit by hand."
        echo "TZ=$tz"
        echo "START=$start"
        echo "END=$end"
        if [ -n "$label" ]; then
          echo "LABEL=$label"
        fi
      } > "$tmp"
      mv "$tmp" "$conf"
    '';
  };
in
{
  programs = {
    waybar = {
      enable = true;
      # mkAfter: stylix defines the @baseXX colours in this same option, and GTK
      # drops rules referencing a colour defined later in the file.
      style = lib.mkAfter ''
        * {
            font-family: JetBrainsMono NF, monospace;
            font-size: 13px;
        }

        /* The empty "ready to go" workspace Niri keeps queued up */
        #workspaces button.empty {
            color: #b5c0e6;
        }

        /* Stylix pads via a literal #clock selector, which no longer matches. */
        #custom-clock {
            padding: 0 5px;
        }

        /* base0B/base08 are stylix's green and red, so these track the scheme. */
        #custom-clock.awake {
            background-color: @base0B;
            color: @base00;
        }

        #custom-clock.error {
            background-color: @base08;
            color: @base00;
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
            "niri/workspaces"
            "custom/media"
          ];
          modules-center = [ "niri/window" ];
          modules-right = [
            "idle_inhibitor"
            # "cpu"
            # "memory"
            "battery"
            # "thermometer"
            "custom/clock"
            "backlight"
            "pulseaudio"
            "tray"
          ];
          "niri/workspaces" = {
            "format" = "{index}";
          };
          "niri/window" = {
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
          # Custom, not built-in: the clock module can't vary its CSS class, so
          # it can't be coloured by time.
          "custom/clock" = {
            "exec" = "${remoteAwake}/bin/waybar-clock-remote-awake";
            "return-type" = "json";
            "interval" = 1;
            "on-click-right" = "${remoteAwakeEdit}/bin/waybar-clock-remote-awake-edit";
            "exec-on-event" = true;
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
