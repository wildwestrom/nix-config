# Bootloader and kernel. Machine-specific kernel params belong in the host.
{
  flake.modules.nixos.boot =
    { pkgs, ... }:
    {
      boot = {
        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
        };
        initrd.systemd.enable = true;
        kernelPackages = pkgs.linuxPackages_latest;
        kernel.sysctl = {
          "fs.inotify.max_user_watches" = "524288";
        };
      };
    };
}
