# The terminal emulator, exposed to other aspects through `my.terminal` so the
# choice is made exactly once. helix.nix (desktop entry) and the dconf keys
# below read from it.
{
  flake.modules.homeManager.terminal =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.terminal;
    in
    {
      options.my.terminal = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.foot;
          description = "Terminal emulator package.";
        };
        command = lib.mkOption {
          type = lib.types.str;
          default = "footclient";
          description = "Executable name inside the package's bin/.";
        };
        bin = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = "${cfg.package}/bin/${cfg.command}";
          description = "Absolute path to the terminal executable.";
        };
      };

      config = {
        programs.foot = {
          enable = true;
          server.enable = true;
          settings = {
            main = {
              # gamma-correct-blending = true;
              # term = "xterm-256color";
              # dpi-aware = "yes"; # TODO: Find out why this setting conflicts
              # font = "Monocraft:size=12";
              shell = "${pkgs.fish}/bin/fish";
            };
            scrollback.lines = 65535;
          };
        };

        # Previous candidates, for reference:
        # kitty  { shellIntegration.enableFishIntegration = true; settings.confirm_os_window_close = 0; }
        # alacritty { keyboard.bindings = [ Ctrl+Shift+N SpawnNewInstance, Shift+Return "\n" ]; }
        # wezterm { enable_tab_bar = false; window_close_confirmation = "NeverPrompt"; }

        dconf.settings = {
          "org/cinnamon/desktop/default-applications/terminal".exec = cfg.bin;
          "org/cinnamon/desktop/applications/terminal".exec = cfg.bin;
        };

        home.shellAliases.newterm = "${cfg.bin} . & disown";

        home.packages = [
          (pkgs.writeShellScriptBin "terminal-here" ''
            # Find the PID of the focused window. The IPC differs per compositor, so
            # branch on whichever socket env var is set (niri sets NIRI_SOCKET, sway
            # sets SWAYSOCK).
            if [ -n "$NIRI_SOCKET" ]; then
              TERM_PID=$(${pkgs.niri}/bin/niri msg --json focused-window \
                | ${pkgs.jq}/bin/jq '.pid // empty')
            elif [ -n "$SWAYSOCK" ]; then
              TERM_PID=$(${pkgs.sway}/bin/swaymsg -t get_tree \
                | ${pkgs.jq}/bin/jq '.. | objects | select(.focused? == true) | .pid // empty' \
                | head -1)
            fi

            if [ -z "$TERM_PID" ]; then
              exec ${cfg.bin}
            fi

            # Walk to the deepest child process (the shell, or whatever's running)
            leaf_pid() {
              local pid="$1"
              local child
              child=$(${pkgs.procps}/bin/pgrep -P "$pid" 2>/dev/null | tail -1)
              [ -n "$child" ] && leaf_pid "$child" || echo "$pid"
            }

            CWD=$(readlink -e "/proc/$(leaf_pid "$TERM_PID")/cwd" 2>/dev/null)

            if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
              exec ${cfg.bin}
            fi

            exec ${cfg.bin} --working-directory "$CWD"
          '')
        ];
      };
    };
}
