{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    "dm-snapshot"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-uuid/f72a5598-7b80-4f04-b213-842afb98e2ae";

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  boot.initrd.systemd.enable = true;
  security.tpm2.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7ea32639-ffba-4283-af2f-880b95f8e856";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/7ea32639-ffba-4283-af2f-880b95f8e856";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/7ea32639-ffba-4283-af2f-880b95f8e856";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/1969-AA1E";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/8be03313-351b-44e7-90a4-b842214343bb";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp193s0f3u2u3.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
}
