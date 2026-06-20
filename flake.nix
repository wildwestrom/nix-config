{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    pi-agent = {
      url = "github:tienedev/pi-mono-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      unfree-pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable-pkgs = import inputs.nixpkgs-unstable {
        inherit system;
      };
      unstable-unfree-pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            unfree = unfree-pkgs;
            unstable = unstable-pkgs;
            unstable-unfree = unstable-unfree-pkgs;
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
