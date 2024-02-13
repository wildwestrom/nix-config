{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sway-git-overlay.url = "github:jalil-salame/sway-git-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    sway-git-overlay,
    ...
  } @ inputs: let
    overlays = [
      # sway-git-overlay.overlays.default # provides sway-git
      sway-git-overlay.overlays.replace-sway # replaces sway with sway-git (anywhere you use pkgs.sway you'll get pkgs.sway-git instead)
    ];
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    font = {
      monospace = "JetBrainsMono";
    };
  in {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs overlays font;};
        modules = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
