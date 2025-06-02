{
  pkgs,
  ...
}:
let
in
{

  home = {
    packages = with pkgs; [
      retroarch
      retroarch-assets
      retroarch-joypad-autoconfig
      gamescope
    ];
  };
}
