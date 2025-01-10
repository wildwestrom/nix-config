{
  pkgs,
  ...
}:
let
in
{

  home = {
    packages = with pkgs; [
      retroarch-free
      retroarch-assets
      retroarch-joypad-autoconfig
    ];
  };
}
