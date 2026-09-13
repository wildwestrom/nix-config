# Running Windows software.
{
  flake.modules.homeManager.windows =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # bottles
        wineWow64Packages.waylandFull
        winetricks
        zenity
      ];
    };
}
