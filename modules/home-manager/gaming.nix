{
  pkgs,
  # unfree,
  unstable-unfree,
  ...
}:
{

  home = {
    packages = with pkgs; [
      unstable-unfree.retroarch-full
      retroarch-assets
      retroarch-joypad-autoconfig
    ];
  };
}
