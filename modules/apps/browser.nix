# LibreWolf as the default browser, chromium as the fallback (its flags are in
# core/nixpkgs.nix).
{
  flake.modules.homeManager.browser =
    { pkgs, ... }:
    {
      programs.librewolf = {
        enable = true;
        # Stylix declares profiles by name (stylix.targets.librewolf.profileNames
        # below). HM defaults a profile's directory to its name, which would
        # strand the existing ~/.librewolf/h72n89bw.default profile behind a
        # fresh empty one -- pin the path to the real directory.
        profiles.default.path = "h72n89bw.default";
        settings = {
          "identity.fxaccounts.enabled" = true;
          "general.autoScroll" = true;
          "middlemouse.paste" = false;
          # "browser.fullscreen.autohide" = false;
          "ui.key.menuAccessKeyFocuses" = false;
        };
      };
      # Stylix themes only the profiles named here; must match the profile above.
      stylix.targets.librewolf.profileNames = [ "default" ];

      home.packages = with pkgs; [
        tridactyl-native
        ungoogled-chromium
      ];

      xdg.mimeApps.defaultApplications = {
        "text/html" = "librewolf.desktop";
        "text/xml" = "librewolf.desktop";
        "application/rdf+xml" = "librewolf.desktop";
        "application/rss+xml" = "librewolf.desktop";
        "application/xhtml+xml" = "librewolf.desktop";
        "application/xhtml_xml" = "librewolf.desktop";
        "application/xml" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/ipfs" = "librewolf.desktop";
        "x-scheme-handler/ipns" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };
}
