{
  pkgs,
  unstable,
  patched-gamescope,
  ...
}:
{

  home = {
    packages = with pkgs; [
      retroarch
      retroarch-assets
      retroarch-joypad-autoconfig
      patched-gamescope
    ];
  };
}
