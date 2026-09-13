{
  flake.modules.nixos.vpn =
    { pkgs, ... }:
    {
      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn; # add the GUI
      };
    };
}
