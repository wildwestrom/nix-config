# restic runs as its own user with just enough capability to read everything.
{
  flake.modules.nixos.restic =
    { pkgs, ... }:
    {
      users.users.restic.isNormalUser = true;
      security.wrappers.restic = {
        source = "${pkgs.restic.out}/bin/restic";
        owner = "restic";
        group = "users";
        permissions = "u=rwx,g=,o=";
        capabilities = "cap_dac_read_search=+ep";
      };
      environment.systemPackages = [ pkgs.restic ];
    };
}
