{
  inputs,
  pkgs,
  config,
  ...
}: {
  services = {
    clipman = {
      enable = true;
    };
    # kanshi = {
    #   profiles = {
    #     undocked = {
    #       outputs = [
    #         {
    #           criteria = "eDP-1";
    #         }
    #       ];
    #     };
    #   };
    # };
  };
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    config =
      let
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
        "${super}+a" = "focus parent";
        "${super}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${super}+Shift+Return" = "exec gtk-launch ${pkgs.librewolf}/bin/librewolf";
        "${super}+Shift+f" = "exec gtk-launch ${pkgs.cinnamon.nemo-with-extensions}/bin/nemo";
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
      defaultWorkspace = "workspace ${ws1}";
      output = {
        eDP-1 = {
          scale = "1.5";
        };
      };
      input = {
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
        names = [ "Sarasa Mono K" "Sarasa Mono J" ];
        size = 12.0;
      };
      modes = {
        default = 
        {
        };
      };
    };
  };
  programs = {
    swaylock = {
      enable = true;
      settings = {
        # nothing yet
      };
    };
  };
}
