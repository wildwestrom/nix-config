# KVM/QEMU via libvirt, managed with virt-manager.
{ user, ... }:
{
  flake.modules.nixos.libvirt =
    { pkgs, ... }:
    {
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;
      users.users.${user.name}.extraGroups = [ "libvirtd" ];
      environment.systemPackages = [ pkgs.virt-manager ];
    };

  flake.modules.homeManager.libvirt = {
    dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
