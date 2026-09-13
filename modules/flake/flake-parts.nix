# flake-parts plumbing shared by every module in this tree.
{ inputs, ... }:
{
  # Provides `flake.modules.<class>.<name>`, the option every aspect writes to.
  # It also exports them as the conventional `nixosModules` / `homeModules`
  # flake outputs for free.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];

  perSystem =
    { pkgs, ... }:
    {
      # `nix fmt` formats the whole tree (nixfmt-tree wraps nixfmt in treefmt).
      formatter = pkgs.nixfmt-tree;

      # Local packages, so `nix build .#claude-desktop` works standalone. The
      # overlay in modules/core/nixpkgs.nix exposes the same package as
      # pkgs.claude-desktop for use inside the system.
      packages.claude-desktop = pkgs.callPackage ../../pkgs/claude-desktop.nix { };
    };
}
