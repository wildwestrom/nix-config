# Removable media, disk tooling.
{
  flake.modules.nixos.storage = {
    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
  };

  flake.modules.homeManager.storage =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gparted
        exfatprogs
        gnome-disk-utility
        baobab
        dua
      ];
    };
}
