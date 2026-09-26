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

    # terraform-provider-pfsense generates its go.mod, then applies a checked-in
    # patch to it. The patch's first hunk covers the `go` directive, so it only
    # applies under the Go version its own lock pins. Without this input, flake
    # lock deduplication would point it at the nixpkgs above and the patch would
    # fail. Bump it in step with upstream's flake.lock.
    nixpkgs-pfsense.url = "github:nixos/nixpkgs/b5aa0fbd538984f6e3d201be0005b4463d8b09f8";

    terraform-provider-pfsense = {
      url = "github:UnstoppableMango/terraform-provider-pfsense";
      inputs.nixpkgs.follows = "nixpkgs-pfsense";
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
          tfpkgs = final.callPackage ./packages.nix { inherit inputs; };
        })
      ];

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        let
          tfpkgs = pkgs.callPackage ./packages.nix { inherit inputs; };
          derivations = lib.filterAttrs (_: lib.isDerivation) tfpkgs;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = with inputs; [
              gomod2nix.overlays.default
            ];
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
