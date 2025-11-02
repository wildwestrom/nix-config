{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    cursor_2.url = "github:jetpham/nixpkgs/update-cursor-2.0.38";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      unstable-pkgs = import inputs.nixpkgs-unstable {
        inherit system;
      };
      unstable-unfree-pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      cursor_2 = import inputs.cursor_2 {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            unstable = unstable-pkgs;
            unstable-unfree = unstable-unfree-pkgs;
            cursor_2 = cursor_2;
          };
          modules = [
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            ./hosts/default/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.stylix.nixosModules.stylix
          ];
        };
      };
    };
}
