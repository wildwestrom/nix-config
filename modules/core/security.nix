# Privilege escalation and the user-facing auth agent that goes with it.
{
  flake.modules.nixos.security = {
    security = {
      # sudo-rs: sudo must be owned by uid 0 and have the setuid bit set
      # -> if you get this error, it's probably because you modified the PATH
      # variable for the shell.
      sudo-rs.enable = true;
      polkit.enable = true;
      # rtkit is optional but recommended (realtime priority for pipewire)
      rtkit.enable = true;
    };
  };

  flake.modules.homeManager.security =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.polkit_gnome ];

      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "polkit-gnome-authentication-agent-1";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Restart = "on-failure";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
        # Without this nothing pulls the unit in, and pkexec silently falls back
        # to a terminal prompt instead of the GUI dialog.
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
