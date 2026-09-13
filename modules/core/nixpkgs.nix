# nixpkgs instance configuration: unfree policy and overlays. With
# home-manager.useGlobalPkgs this is the single source of `pkgs` for both the
# system and the user.
{ inputs, ... }:
{
  flake.modules.nixos.nixpkgs =
    { lib, ... }:
    {
      nixpkgs = {
        config = {
          # Deliberately an allowlist rather than allowUnfree = true, so an
          # unfree dependency can't slip in unnoticed.
          allowUnfreePredicate =
            pkg:
            let
              name = lib.getName pkg;
            in
            builtins.elem name [
              "obsidian"
              "libsciter"
              "surrealdb"
              "rust-rover"
              "steam"
              "steam-unwrapped"
              "discord"
              "claude-desktop"
              "canon-cups-ufr2"
            ]
            # retroarch-full bundles ~16 non-commercial cores (snes9x, mame*,
            # fbneo, genesis-plus-gx, ...); accept the family wholesale.
            || lib.hasPrefix "libretro-" name;

          permittedInsecurePackages = [ ];

          chromium.commandLineArgs = "--gtk-version=4";
        };

        overlays = [
          (final: prev: {
            # `pkgs.unstable.<name>`: the same nixpkgs config (unfree
            # allowlist, ...) applied to the nixos-unstable tree.
            unstable = import inputs.nixpkgs-unstable {
              inherit (final.stdenv.hostPlatform) system;
              inherit (final) config;
            };

            # Anthropic's official Linux build, repackaged from their .deb. See
            # the package file for why this no longer comes from
            # k3d3/claude-desktop-linux-flake.
            claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };

            # Patented hinting/subpixel code; makes a visible difference to
            # CJK + small text. Rebuilds a lot of the graphics stack.
            freetype = prev.freetype.override { useEncumberedCode = true; };
          })
        ];
      };
    };
}
