# Steam, controllers, emulation.
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          steamtinkerlaunch
          proton-ge-bin
        ];
      };
      programs.gamescope = {
        enable = true;
        # capSysNice = true; # causes games to straight up not launch on steam
      };

      # Nintendo Switch controllers
      services.joycond.enable = true;
      programs.joycond-cemuhook.enable = true;
    };

  flake.modules.homeManager.gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unstable.retroarch-full # unfree cores allowed via the libretro-* rule in core/nixpkgs.nix
        retroarch-assets
        retroarch-joypad-autoconfig
        prismlauncher
      ];
    };
}
