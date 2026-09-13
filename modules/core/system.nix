# Small system-wide odds and ends that don't earn their own file.
{
  flake.modules.nixos.system =
    { pkgs, ... }:
    {
      environment.binsh = "${pkgs.dash}/bin/dash";

      services.dbus.enable = true;
      services.atd.enable = true;

      environment.systemPackages = with pkgs; [
        bash
        cachix
        git
        helix # root's editor; the user's configured one is in dev/helix.nix
        wget
        lsof
        pciutils
        usbutils
        dmidecode
        libnotify
        bubblewrap
      ];
    };
}
