# External monitor control over DDC/CI, and backlight control.
{
  flake.modules.nixos.monitors =
    { pkgs, config, ... }:
    {
      boot.kernelModules = [ "i2c-dev" ];
      boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
      environment.systemPackages = with pkgs; [
        ddcutil
        brightnessctl
      ];
    };

  flake.modules.homeManager.monitors =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ddcui ];
    };
}
