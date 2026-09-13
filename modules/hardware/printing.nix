# Printing and scanning. The Brother MFC-L3765CDW is driverless (IPP Everywhere
# / eSCL) and found over mDNS; the driver list covers everything else I run
# into.
{ user, ... }:
{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
          cups-bjnp
          brlaser
          carps-cups
          canon-cups-ufr2 # unfree; see the allowlist in core/nixpkgs.nix
          gutenprint
        ];
      };

      # mDNS discovery for network printers.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # Driverless network scanning (eSCL).
      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };

      users.users.${user.name}.extraGroups = [
        "scanner"
        "lp"
      ];

      environment.systemPackages = [ pkgs.naps2 ];
    };
}
