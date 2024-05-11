{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-23.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sway-git-overlay.url = "github:jalil-salame/sway-git-overlay";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-wayland,
    nixos-hardware,
    sway-git-overlay,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs-wayland {
      inherit system;
      overlays = [
        # sway-git-overlay.overlays.default # provides sway-git
        # sway-git-overlay.overlays.replace-sway # replaces sway with sway-git (anywhere you use pkgs.sway you'll get pkgs.sway-git instead)
        # (final: prev: let
        #   zedpkgs = nixpkgs-zed.legacyPackages.x86_64-linux;
        # in {
        #   inherit (zedpkgs) zed-editor;
        # })
      ];
    };
    font = {
      monospace = "JetBrainsMono";
    };
    dark_mode = true;
  in {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs font dark_mode;};
        modules = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
