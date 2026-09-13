# Keyboards and mice.
{
  flake.modules.nixos.input-devices =
    { pkgs, ... }:
    {
      hardware.keyboard.zsa.enable = true;
      hardware.keyboard.qmk.enable = true;

      # Swap Caps Lock and Escape at the evdev level (below XKB) so the remap is
      # also seen by apps that read physical scancodes, e.g. Bevy/raylib games.
      # 0001:0001 is the built-in AT_Translated_Set_2_keyboard, matching the scope
      # the old caps:swapescape xkb_option had in sway.nix.
      services.keyd = {
        enable = true;
        keyboards.internal = {
          ids = [ "0001:0001" ];
          settings.main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };

      # Logitech device manager
      environment.systemPackages = [ pkgs.solaar ];
    };
}
