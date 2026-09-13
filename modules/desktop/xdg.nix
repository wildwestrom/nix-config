# XDG base: enables mimeapps handling and the catch-all handlers. Per-app
# associations live with the app (browser.nix, media.nix, office.nix, ...).
#
# Note: nixos-rebuild.sh deletes ~/.config/mimeapps.list before switching so
# home-manager can re-link it over anything apps wrote at runtime.
{
  flake.modules.homeManager.xdg =
    { pkgs, ... }:
    {
      xdg.enable = true;
      xdg.mimeApps.enable = true;

      home.packages = with pkgs; [
        xdg-utils
        shared-mime-info
        gsettings-desktop-schemas
        glib
        dbus
        gtk4
        libadwaita
      ];
    };
}
