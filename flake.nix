{
  description = "Terraform packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:UnstoppableMango/nix-systems";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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

      flake.overlays.default = final: _prev: {
        tfpkgs = final.callPackage ./packages.nix { };
      };

      perSystem =
        { pkgs, ... }:
        let
          inherit (pkgs) lib;
          tfpkgs = pkgs.callPackage ./packages.nix { };
          derivations = lib.filterAttrs (_: lib.isDerivation) tfpkgs;
        in
        {
          packages = derivations;
          checks = derivations;

          # The full scope, including helpers like buildTerraformProvider.
          legacyPackages = tfpkgs;

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              gnumake
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
