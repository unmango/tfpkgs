{
  description = "Terraform packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:UnstoppableMango/nix-systems";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        systems.flakeModule
        treefmt-nix.flakeModule
      ];

      flake.overlays.default = inputs.nixpkgs.lib.composeManyExtensions [
        inputs.gomod2nix.overlays.default
        (final: _prev: {
          tfpkgs = final.callPackage ./packages.nix { };
        })
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          inherit (pkgs) lib;
          tfpkgs = pkgs.callPackage ./packages.nix { };
          derivations = lib.filterAttrs (_: lib.isDerivation) tfpkgs;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.gomod2nix.overlays.default ];
          };

          packages = derivations;
          checks = derivations;

          # The full scope, including helpers like buildTerraformProvider.
          legacyPackages = tfpkgs;

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              gnumake
              go
              gomod2nix
              nix-update
              nixfmt
              opentofu
              tfpkgs.terraform
            ];
          };

          treefmt.programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
            statix.enable = true;
          };
        };
    };
}
