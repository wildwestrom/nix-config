# The Nix daemon itself: features, caches, GC.
{ inputs, user, ... }:
{
  flake.modules.nixos.nix = {
    nix = {
      # Make `<nixpkgs>` and `nix run nixpkgs#foo` resolve to the same pinned
      # tree the system was built from, so nothing downloads a second nixpkgs.
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      registry.nixpkgs.flake = inputs.nixpkgs;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
          user.name
        ];
        substituters = [
          "https://cache.iog.io"
          "https://nix-community.cachix.org"
          "https://zed.cachix.org"
          "https://devenv.cachix.org"
          "https://codex-cli.cachix.org"
          "https://pi.cachix.org"
        ];
        trusted-public-keys = [
          "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
          "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
        ];
      };

      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };
  };
}
