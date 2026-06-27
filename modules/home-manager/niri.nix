{
  pkgs,
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

  # Lock to the current wallpaper. waypaper picks the image at runtime, so
  # there's no static path to hand swaylock -- read the path straight from
  # waypaper's own config (its source of truth, independent of which backend
  # actually renders it), expand a leading ~, and pass it. Falls back to the
  # solid colour if the file can't be resolved.
  swaylockCmd = "${pkgs.writeShellScript "swaylock-wallpaper" ''
    cfg="$HOME/.config/waypaper/config.ini"
    # sed prints the first wallpaper line's value and quits -- avoid piping to
    # `head`, since swayidle's systemd unit has a minimal PATH (bash only) and a
    # bare command would not resolve, leaving $img empty -> grey fallback.
    img=$(${pkgs.gnused}/bin/sed -n '/^wallpaper = /{s///p;q}' "$cfg" 2>/dev/null)
    img="''${img/#\~/$HOME}"
    if [ -n "$img" ] && [ -f "$img" ]; then
      exec ${pkgs.swaylock}/bin/swaylock -ef -i "$img" -s fill
    else
      exec ${pkgs.swaylock}/bin/swaylock -ef -c 404040
    fi
  ''}";
  dim_then_lock = "${dimDisplay} && ${swaylockCmd}";

  # niri controls DPMS through its own IPC instead of `swaymsg output dpms`.
  displayOn = "${pkgs.niri}/bin/niri msg action power-on-monitors";
  displayOff = "${pkgs.niri}/bin/niri msg action power-off-monitors";

  # niri refuses an ext-session-lock request unless it can blank every monitor
  # first (niri-wm/niri#205). On suspend the monitors are already powered off by
  # the time swaylock asks for the lock, so the lock is rejected and we wake to
  # an unlocked session. Power the monitors back on before locking so niri can
  # blank them and grant the lock. Paired with swayidle's `-w` (see extraArgs),
  # this also makes the system wait for the lock to be held before sleeping.
  lock_on_sleep = "${displayOn} && ${swaylockCmd}";

  menu = "${pkgs.fuzzel}/bin/fuzzel";
  browser = "${pkgs.librewolf}/bin/librewolf";
in
{
  imports = [
    ./wayland.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    fuzzel
    wlogout # power/logout menu (sway used swaynag for this)
    xwayland-satellite # X11 app support; niri starts/manages it (see config)
    nwg-displays
    waypaper
    swww
  ];

  # Home Manager (25.11) has no `programs.niri` module, so the compositor is
  # configured by writing its KDL config file directly. The compositor itself
  # is enabled system-wide via `programs.niri.enable` in configuration.nix.
  # TODO: Check if 26.05 has niri. Might not be necessary to change this though, it's fine.
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
            gaps 16
            center-focused-column "on-overflow"
            always-center-single-column
            border {
                width 2
                active-color "#505050"
                inactive-color "#505050"
            }
            focus-ring {
                width 2
            }
            // Widths cycled by Mod+R (switch-preset-column-width). Full width is
            // included so a single window can fill the screen.
            preset-column-widths {
                proportion 0.95
                proportion 0.5
                proportion 1.0
            }
            default-column-width { proportion 0.5; }
        }

        // sway: window.titlebar = false
        prefer-no-csd

        // Don't open the overview from the top-left hot corner; Mod+O does it.
        gestures {
            hot-corners {
                off
            }
        }

        // Dynamic per-monitor workspaces (niri-native). Workspaces are created on
        // demand and disappear when empty, so the bar only shows what's in use plus
        // one empty trailing workspace per monitor. The Mod+1..0 binds below use
        // bare indices, which address the Nth workspace on the *currently focused*
        // monitor -- so numbers are positional, not pinned to a monitor.
        //
        // The one exception is "Socials": it's a named, persistent workspace pinned
        // to the laptop so the chat apps always have a fixed home (and survive the
        // big monitor being unplugged -- niri relocates it onto whatever output
        // remains, then moves it back on reconnect).
        workspace "Socials" { open-on-output "BOE 0x0BCA Unknown"; }

        // Chat apps open full-width on the "chat" workspace; Super+H/L scrolls
        // between them, each filling the screen. To instead stack them as real
        // tabs: focus the workspace, consume the windows into one column
        // (Mod+Comma), then Mod+W to toggle tabbed display. If an app doesn't
        // match, find its real id in the "App ID" field of `niri msg windows`.
        window-rule {
            match app-id="thunderbird"
            match app-id="discord"
            match app-id="org.telegram.desktop"
            match app-id="signal"
            match app-id="element"
            match app-id="org.gnome.Fractal"
            open-on-workspace "Socials"
            default-column-width { proportion 0.95; }
        }


        window-rule {
            match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
            default-floating-position x=10 y=10 relative-to="bottom-right"
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

        // startup programs
        spawn-at-startup "${pkgs.waybar}/bin/waybar"
        spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet" "--indicator"
        spawn-at-startup "${pkgs.protonmail-bridge}/bin/protonmail-bridge" "--noninteractive"

        // Wallpaper: swww-daemon renders, waypaper is the GUI picker. The chosen
        // image lives in waypaper's own state (~/.config/waypaper/), not this
        // config -- run `waypaper` anytime to change it; --restore reapplies the
        // last pick on login.
        spawn-at-startup "${pkgs.swww}/bin/swww-daemon"
        spawn-at-startup "${pkgs.waypaper}/bin/waypaper" "--restore"

        // Chat apps launched at login; the window-rule above lands them on the
        // "Socials" workspace. Spawned by bare name (they're on PATH via
        // home.packages) so the installed builds are used, incl. unstable signal.
        spawn-at-startup "thunderbird"
        spawn-at-startup "signal-desktop"
        spawn-at-startup "discord"
        spawn-at-startup "fractal"

    		screenshot-path "~/images/screenshots"

        binds {
            // --- Launchers (sway: Mod+Return / Mod+d / etc.) ---
            // terminal-here opens the terminal in the focused window's CWD (it
            // queries niri's IPC for the focused PID); see modules/home-manager/
            // default.nix. On PATH via home.packages.
            Mod+Return { spawn "terminal-here"; }
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

            // Overview (the zoomed-out workspace view). The top-left hot corner
            // that also triggers it is disabled below.
            Mod+O { toggle-overview; }

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

            // Flip to the other monitor and back (toggles last-focused output).
            Mod+Tab   { focus-monitor-previous; }

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
            // Bare indices: the Nth workspace on the currently focused monitor.
            // Empty ones aren't pre-created, so e.g. Mod+3 with nothing past ws 1
            // just lands on the trailing empty workspace. Hop monitors with
            // Mod+H/L first to act on the other screen.
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

            // --- Screenshots ---
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
      # `-w` makes swayidle wait for each command to finish before continuing.
      # Essential for `before-sleep`: the machine must not suspend until swaylock
      # has actually grabbed the lock (swaylock -f returns once locked), otherwise
      # niri powers the monitors off mid-suspend and the lock never takes.
      extraArgs = [ "-w" ];
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
          command = lock_on_sleep;
        }
        {
          # Handle logind's Lock signal so `loginctl lock-session` actually
          # locks. wlogout's "Lock" button (Mod+Shift+Q menu) calls
          # `loginctl lock-session`, which only emits this signal -- without a
          # handler nothing happens. Reuse lock_on_sleep so the monitors are on
          # when swaylock grabs the lock (see niri-wm/niri#205).
          event = "lock";
          command = lock_on_sleep;
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
