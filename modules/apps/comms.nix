# Chat and mail. niri.nix launches these at login onto the "Socials" workspace
# by bare name, so they must stay on PATH via home.packages.
{
  flake.modules.homeManager.comms =
    { pkgs, ... }:
    let
      # Pin Electron's safeStorage backend. Signal records which backend encrypted
      # its DB key and refuses to start if the backend it detects at launch differs
      # -- which is what happens after a round trip through another desktop
      # session, since Electron infers the backend from XDG_CURRENT_DESKTOP.
      # Forcing gnome-libsecret keeps it stable across sessions.
      signal-desktop = pkgs.symlinkJoin {
        name = "signal-desktop-gnome-libsecret";
        paths = [ pkgs.unstable.signal-desktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/signal-desktop \
            --add-flags '--password-store=gnome-libsecret'
        '';
        inherit (pkgs.unstable.signal-desktop) meta;
      };
    in
    {
      home.packages = with pkgs; [
        signal-desktop # wrapped above
        discord
        telegram-desktop
        fractal
        element-desktop
        thunderbird
        protonmail-bridge
      ];

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mid" = "thunderbird.desktop";
      };

      # protonmail-bridge is started by the compositor at login (niri.nix). A
      # user service was tried before but gnome-keyring wasn't reachable early
      # enough.
    };
}
