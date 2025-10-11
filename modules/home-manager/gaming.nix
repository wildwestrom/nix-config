{
  pkgs,
  unstable,
  # unstable-unfree,
  ...
}:
{

  home = {
    packages = with pkgs; [
      (unstable.retroarch.withCores (
        cores: with cores; [
          dosbox-pure
          bsnes
          nestopia
          mgba
          meteor
          fceumm
          # pcsx-rearmed
          # pcsx2
          mame
          # dolphin
          parallel-n64
          stella2014
        ]
      ))
      retroarch-assets
      retroarch-joypad-autoconfig
    ];
  };
}
