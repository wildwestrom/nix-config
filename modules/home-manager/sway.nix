{ pkgs, ... }:
let
  dimDisplay = ''${pkgs.chayang}/bin/chayang -d 30'';
  swaylock = ''${pkgs.swaylock}/bin/swaylock -ef -c 404040'';
  dim_then_lock = ''${dimDisplay} && ${swaylock}'';
  displayOn = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
  displayOff = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
  # terminal = "${pkgs.kitty}/bin/kitty";
  terminal = "${pkgs.alacritty}/bin/alacritty";
in
{
  imports = [
    ./wayland.nix
    ./waybar.nix
  ];
  home.packages = with pkgs; [
    nwg-displays
    # nwg-panel
    sway-contrib.grimshot
    sway-contrib.inactive-windows-transparency
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    systemd.enable = true;
    systemd.xdgAutostart = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    extraSessionCommands = ''
      export XDG_SESSION_DESKTOP=sway
      export export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_SCALE_FACTOR=1.25
    '';
    extraConfig = ''
      include ~/.config/sway/outputs
      include ~/.config/sway/workspaces
    '';
    config =
      let
        super = "Mod4";
        left = "h";
        down = "j";
        up = "k";
        right = "l";
        menu = "${pkgs.fuzzel}/bin/fuzzel";
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
        ws10 = workspace "10";
      in
      {
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
          "${super}+space" = "floating toggle";
          "${super}+Shift+c" = "reload";
          "${super}+a" = "focus parent";
          "${super}+Return" = "exec ${terminal}";
          "${super}+Shift+Return" = "exec ${pkgs.brave}/bin/brave";
          "${super}+Shift+p" = "exec ${pkgs.brave}/bin/brave --incognito";
          "${super}+Shift+f" = "exec ${pkgs.nautilus}/bin/nautilus";
          "${super}+q" = "kill";
          "${super}+Shift+q" =
            "exec ${pkgs.sway}/bin/swaynag -t warning -y overlay -m 'What do you want to do?' -b 'Shutdown' 'systemctl poweroff' -b 'Hibernate' 'systemctl hibernate' -b 'Reboot' 'systemctl reboot' -b 'Logout' 'swaymsg exit' -z 'Lock' '${swaylock}'";
          "${super}+d" = "exec ${menu}";
          # Layout
          "${super}+b" = "splith";
          "${super}+v" = "splitv";
          "${super}+s" = "layout stacking";
          "${super}+w" = "layout tabbed";
          "${super}+e" = "layout toggle split";
          "${super}+f" = "fullscreen";
          # Moving around
          "${super}+${left}" = "focus left";
          "${super}+${down}" = "focus down";
          "${super}+${up}" = "focus up";
          "${super}+${right}" = "focus right";
          # Moving around
          "${super}+left" = "focus left";
          "${super}+down" = "focus down";
          "${super}+up" = "focus up";
          "${super}+right" = "focus right";
          # Move the window
          "${super}+Shift+left" = "move left";
          "${super}+Shift+down" = "move down";
          "${super}+Shift+up" = "move up";
          "${super}+Shift+right" = "move right";
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
          "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          "XF86AudioRaiseVolume" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1%+";
          "${super}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${super}+Shift+w" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy window";
        };
        # keycodebindings = {
        # };
        bars = [
          {
            command = "${pkgs.waybar}/bin/waybar";
            # command = "${pkgs.nwg-panel}/bin/nwg-panel";
          }
        ];
        defaultWorkspace = "${ws1}";
        startup = [
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
          { command = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive"; }
          # { command = "${pkgs.mpvpaper}/bin/mpvpaper -s -o 'no-audio loop' '*' ./wallpaper.mp4"; }
          # {
          #   command = "${pkgs.waybar}/bin/waybar";
          #   # command = "${pkgs.nwg-panel}/bin/nwg-panel";
          #   always = true;
          # }
        ];
        output = {
          "BOE 0x0BCA Unknown" = {
            color_profile = "icc ${./BOE_CQ_______NE135FBM_N41.icm}";
          };
          "Hansung Co., Ltd TFG32U16P 0000000000000" = {
            # adaptive_sync = "on"; # disabling to see if that fixes screen sharing
            # render_bit_depth = "10";
            # hdr = "on"; Enable once sway 1.12 drops.
          };
        };
        input = {
          "*" = {
            xkb_numlock = "enable";
            xkb_layout = "us";
            xkb_options = "compose:ralt";
          };
          "1:1:AT_Translated_Set_2_keyboard" = {
            xkb_options = "compose:ralt,caps:escape";
          };
          "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
            # disable touchpad while typing
            dwt = "enabled";
            natural_scroll = "disabled";
            accel_profile = "adaptive";
            # pointer_accel = "0.1";
            scroll_factor = "0.75";
            tap = "enabled";
            tap_button_map = "lrm";
          };
        };
        modes = {
          default = { };
        };
        # gaps = {
        #   outer = 2;
        #   inner = 4;
        #   smartGaps = true;
        #   smartBorders = "on";
        # };
        window = {
          border = 2;
          titlebar = false;
          commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria = {
                shell = ".*";
                app_id = ".*";
              };
            }
          ];
        };
      };
  };

  services = {
    swayidle = {
      enable = true;
      systemdTarget = "sway-session.target";
      timeouts = [
        {
          timeout = 300;
          command = dim_then_lock;
        }
        {
          timeout = 360;
          command = displayOff;
          resumeCommand = displayOn;
        }
      ];
      events = [
        {
          event = "after-resume";
          command = displayOn;
        }
        {
          event = "before-sleep";
          command = dim_then_lock;
        }
        {
          event = "lock";
          command = dim_then_lock;
        }
      ];
    };
    kanshi = {
      enable = true;
      profiles = {
        monitor-only = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              scale = 1.5;
              # scale-filter = "nearest"; # TODO: add this when supported by kanshi
            }
          ];
        };
        TV = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              scale = 1.5;
            }
            {
              criteria = "LG Electronics LG TV SSCR 0x01010101";
              mode = "1920x1080@60.0Hz";
              position = "1504,0";
              scale = 1.0;
            }
          ];
        };
        old-monitor = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "1920,0";
              scale = 1.5;
            }
            {
              criteria = "Samsung Electronics Company Ltd SEC-700A7KI Unknown";
              mode = "1920x1080@60.0Hz";
              position = "0,0";
              scale = 1.0;
            }
          ];
        };
        new-monitor = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "1920,0";
              scale = 1.5;
            }
            {
              criteria = "Hansung Co., Ltd TFG32U16P 0000000000000";
              mode = "3840x2160@143.998Hz";
              position = "0,0";
              scale = 2.0;
            }
          ];
        };
      };
    };
  };

  programs = {
    swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
      };
    };
  };
}
