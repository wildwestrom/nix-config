# Compositor-agnostic Wayland desktop plumbing: portals, session env, clipboard,
# notifications, night light, auto-brightness, and the wl-* CLI tools.
{
  flake.modules.nixos.wayland =
    { pkgs, ... }:
    {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_RENDERER = "vulkan"; # The crash I was experiencing was fixed in sway 1.11, let's try vulkan again
        #WLR_RENDERER = "gles2";
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = false;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
      };

      services.xserver.desktopManager.runXdgAutostartIfNone = true;

      # Location for gammastep's day/night switching.
      services.geoclue2 = {
        enable = true;
        appConfig.gammastep = {
          isAllowed = true;
          isSystem = true;
        };
      };
    };

  flake.modules.homeManager.wayland =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wev
        slurp
        wl-clipboard-rs
        grim
        wtype
        ydotool
        wl-color-picker
      ];

      services = {
        wl-clip-persist = {
          enable = true;
          systemdTargets = [ "graphical-session.target" ];
        };
        wluma.enable = true;
        mako = {
          enable = true;
          # Per-option settings folded into services.mako.settings; keys are the
          # kebab-case names from mako(5). Still milliseconds.
          settings.default-timeout = 1000 * 5;
        };
        gammastep = {
          enable = true;
          provider = "geoclue2";
          temperature = {
            day = 6500;
            night = 4000;
          };
        };
      };
    };
}
