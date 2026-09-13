# GPU: AMD iGPU via mesa, with 32-bit for Steam/Wine.
{ user, ... }:
{
  flake.modules.nixos.graphics =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages32 = with pkgs; [ driversi686Linux.mesa ]; # looks like amdvlk is gone, I'll try mesa for now
      };
      users.users.${user.name}.extraGroups = [ "video" ];
      environment.systemPackages = [ pkgs.clinfo ];
    };

  flake.modules.homeManager.graphics =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nvtopPackages.amd
        vulkan-validation-layers
      ];
    };
}
