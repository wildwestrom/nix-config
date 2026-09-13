# Desktop utilities: file manager, calculator, system monitor, file transfer.
{
  flake.modules.nixos.utilities = {
    # LocalSend discovery + transfer
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];
  };

  flake.modules.homeManager.utilities =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nautilus
        gnome-calculator
        gucharmap
        gnome-system-monitor
        localsend
        transmission_4-gtk
        xeyes

        # android
        android-file-transfer
        android-tools
        scrcpy
      ];
    };
}
