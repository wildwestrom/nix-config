{
  pkgs,
  terminal,
  ...
}:
let
  # Idle timeout configuration (all values in seconds) -- mirrors sway.nix
  dimDelaySec = 60; # How long chayang takes to dim the screen
  lockTimeoutSec = 300; # Idle time before starting dim+lock sequence
  displayOffDelaySec = 60; # Time after lock completes before display turns off

  # Calculated timeout: ensures display off happens after lock is complete
  displayOffTimeoutSec = lockTimeoutSec + dimDelaySec + displayOffDelaySec;

  dimDisplay = "${pkgs.chayang}/bin/chayang -d ${toString dimDelaySec}";
  swaylockCmd = "${pkgs.swaylock}/bin/swaylock -ef -c 404040";
  dim_then_lock = "${dimDisplay} && ${swaylockCmd}";

  # niri controls DPMS through its own IPC instead of `swaymsg output dpms`.
  displayOn = "${pkgs.niri}/bin/niri msg action power-on-monitors";
  displayOff = "${pkgs.niri}/bin/niri msg action power-off-monitors";

  menu = "${pkgs.fuzzel}/bin/fuzzel";
  browser = "${pkgs.librewolf}/bin/librewolf";
in
{
  imports = [
    ./wayland.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    nwg-displays # niri supports wlr-output-management, so this still works
    fuzzel
    swaybg
    wlogout # power/logout menu (sway used swaynag for this)
    xwayland-satellite # X11 app support; niri starts/manages it (see config)
  ];

  # Home Manager (25.11) has no `programs.niri` module, so the compositor is
  # configured by writing its KDL config file directly. The compositor itself
  # is enabled system-wide via `programs.niri.enable` in configuration.nix.
  xdg.configFile."niri/config.kdl".text = ''
    // Sway-equivalent niri config. niri is a scrolling tiler, so some sway
    // concepts (splith/splitv, stacking, focus parent) have no direct analog
    // and are noted below rather than bound.

    input {
        keyboard {
            xkb {
                layout "us"
                options "compose:ralt"
            }
            numlock
        }
        touchpad {
            tap
            dwt
            accel-profile "adaptive"
            scroll-factor 0.75
            tap-button-map "left-right-middle"
        }
        mouse {
            accel-profile "adaptive"
        }
        // sway: focus.followMouse = "always" / mouseWarping = "output"
        focus-follows-mouse
        warp-mouse-to-focus
    }

    // Output layout (ports the kanshi "new-monitor" profile from sway.nix).
    // niri applies each block whenever that output is connected, so this also
    // covers the laptop-only case. Add more `output` blocks for other monitors
    // (the old TV / old-monitor kanshi profiles) as needed.
    output "Hansung Co., Ltd TFG32U16P 0000000000000" {
        mode "3840x2160@143.998"
        scale 2.0
        position x=0 y=0
    }
    output "BOE 0x0BCA Unknown" {
        scale 1.5
        position x=1920 y=0
    }

    layout {
        gaps 4
        // sway: window.border = 2
        border {
            width 2
        }
        focus-ring {
            width 2
        }
        // Widths cycled by Mod+R (switch-preset-column-width). Full width is
        // included so a single window can fill the screen.
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
        default-column-width { proportion 0.5; }
    }

    // sway: window.titlebar = false
    prefer-no-csd

    // Predeclare a named workspace for chat apps.
    workspace "chat"

    // Chat apps open full-width on the "chat" workspace; Super+H/L scrolls
    // between them, each filling the screen. To instead stack them as real
    // tabs: focus the workspace, consume the windows into one column
    // (Mod+Comma), then Mod+W to toggle tabbed display. If an app doesn't
    // match, find its real id in the "App ID" field of `niri msg windows`.
    window-rule {
        match app-id="discord"
        match app-id="org.telegram.desktop"
        match app-id="signal"
        match app-id="element"
        match app-id="org.gnome.Fractal"
        open-on-workspace "chat"
        open-maximized true
    }

    // XWayland support: niri is not wlroots-based, so X11 apps go through
    // xwayland-satellite, which niri starts and manages (it sets DISPLAY for
    // spawned clients). The package bundles Xwayland as a runtime dep.
    xwayland-satellite {
        path "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
    }

    // Don't show the hotkey help on every launch.
    hotkey-overlay {
        skip-at-startup
    }

    // sway startup programs
    spawn-at-startup "${pkgs.waybar}/bin/waybar"
    spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet" "--indicator"
    spawn-at-startup "${pkgs.protonmail-bridge}/bin/protonmail-bridge" "--noninteractive"

    binds {
        // --- Launchers (sway: Mod+Return / Mod+d / etc.) ---
        Mod+Return { spawn "${terminal.package}/bin/foot"; }
        Mod+Shift+Return { spawn "${browser}"; }
        Mod+Shift+P { spawn "${browser}" "--private-window"; }
        Mod+Shift+F { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Mod+D { spawn "${menu}"; }

        // --- Window management ---
        Mod+Q { close-window; }
        Mod+F { fullscreen-window; }
        Mod+Space { toggle-window-floating; }

        // Tabs: niri only tabs windows that share a column. Pull the
        // neighbouring window into the current column (consume), push it back
        // out (expel), then toggle the column to tabbed display. sway Mod+w:
        Mod+W { toggle-column-tabbed-display; }
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // Column / window sizing. switch-preset-column-width cycles the
        // presets in the layout block (incl. full width); maximize-column
        // toggles full width directly.
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+M { maximize-column; }
        Mod+C { center-column; }

        // sway Mod+Shift+q opened a power menu (swaynag); wlogout is the niri
        // equivalent.
        Mod+Shift+Q { spawn "${pkgs.wlogout}/bin/wlogout"; }
        // No direct niri analog: Mod+a (focus parent), Mod+b/Mod+v (splith/
        // splitv), Mod+s (stacking), Mod+e (toggle split). niri auto-reloads
        // its config on save, so sway's Mod+Shift+c (reload) is unnecessary.

        // --- Focus (sway h/j/k/l + arrows) ---
        // Columns are left/right, windows within a column are up/down. The
        // *-or-monitor-* variants cross to the adjacent monitor when there is
        // nothing more to focus in that direction.
        Mod+H     { focus-column-or-monitor-left; }
        Mod+L     { focus-column-or-monitor-right; }
        Mod+J     { focus-window-or-monitor-down; }
        Mod+K     { focus-window-or-monitor-up; }
        Mod+Left  { focus-column-or-monitor-left; }
        Mod+Right { focus-column-or-monitor-right; }
        Mod+Down  { focus-window-or-monitor-down; }
        Mod+Up    { focus-window-or-monitor-up; }

        // --- Move window (sway Mod+Shift+h/j/k/l + arrows) ---
        // Left/right push the column to the adjacent monitor past the edge.
        Mod+Shift+H     { move-column-left-or-to-monitor-left; }
        Mod+Shift+L     { move-column-right-or-to-monitor-right; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
        Mod+Shift+Right { move-column-right-or-to-monitor-right; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }

        // --- Workspaces (sway Mod+1..0 / Mod+Shift+1..0) ---
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+0 { focus-workspace 10; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }
        Mod+Shift+0 { move-column-to-workspace 10; }

        // --- Screenshots (sway: grimshot copy area / window) ---
        Mod+Shift+S { screenshot; }
        Mod+Shift+W { screenshot-window; }
        Print { screenshot; }

        // --- Media / brightness keys ---
        XF86AudioMute        allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "2%-"; }
        XF86AudioRaiseVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "2%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "1%-"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "1%+"; }
    }
  '';

  services = {
    swayidle = {
      enable = true;
      # niri provides the standard graphical-session.target (see niri.service).
      systemdTarget = "graphical-session.target";
      timeouts = [
        {
          timeout = displayOffDelaySec;
          command = "if ${pkgs.procps}/bin/pgrep swaylock; then ${displayOff}; fi";
          resumeCommand = displayOn;
        }
        {
          timeout = lockTimeoutSec;
          command = "if ! ${pkgs.procps}/bin/pgrep swaylock; then ${dim_then_lock}; fi";
          resumeCommand = displayOn;
        }
        {
          timeout = displayOffTimeoutSec;
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
          command = swaylockCmd;
        }
      ];
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
