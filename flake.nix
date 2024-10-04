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

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      font = {
        default = "Noto Sans CJK KR";
        monospace = "JetBrainsMono";
      };
      dark_mode = false;
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs font dark_mode;
          };
          modules = [
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            ./hosts/default/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
      };
    };
}
