{
  description = "NixOS config";

  # Everything else lives under ./modules. Every .nix file there is a
  # flake-parts module (auto-imported by import-tree), and each file is one
  # *aspect* of the system -- audio, printing, niri, git, ... -- that can carry
  # both a NixOS half (flake.modules.nixos.<aspect>) and a home-manager half
  # (flake.modules.homeManager.<aspect>). Hosts pick aspects by name in
  # modules/hosts/<host>/default.nix. Files and directories whose path contains
  # a `_` prefix component are skipped, which is how non-module assets
  # (hardware-configuration.nix, toml/icc files) live alongside the code.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    flake-utils.url = "github:numtide/flake-utils";

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
    };

    pi-agent = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grok-build = {
      url = "github:AodhanHayter/grok-build-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tsoding's file-based task tracker
    tatr = {
      url = "github:wildwestrom/tatr-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal fork of niri
    # Carries PRs #1791 and #1463
    niri-fork.url = "github:wildwestrom/niri";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
