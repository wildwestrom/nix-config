# Login: greetd + tuigreet, and the keyring that gets unlocked by it. The
# compositor aspect (niri.nix / sway.nix) supplies default_session.command.
{
  flake.modules.nixos.session = {
    services.greetd = {
      enable = true;
      # No `WLR_RENDERER=vulkan` prefix on the command: greetd runs it via
      # `sh -c exec`, and `exec VAR=val cmd` fails (tries to exec a binary named
      # "VAR=val"). WLR_RENDERER is already set globally in
      # environment.sessionVariables (wayland.nix).
      settings.default_session.user = "greeter";
      # Auto-login disabled: with `initial_session` no password is entered, so
      # pam_gnome_keyring never captures it and the login keyring stays locked
      # (causes the recurring keyring password prompt + Fractal "Secret Portal
      # Error"). Logging in through tuigreet lets PAM unlock the keyring.
    };

    services.gnome.gnome-keyring.enable = true;
    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      swaylock.enableGnomeKeyring = true;
    };
    # this should allow gnome calculator to convert currencies
    services.gnome.glib-networking.enable = true;
  };
}
