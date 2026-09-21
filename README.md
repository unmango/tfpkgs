# tfpkgs

Nix packages for the Terraform and OpenTofu ecosystem.

## Usage

```nix
{
  inputs.tfpkgs.url = "github:unmango/tfpkgs";

  # As an overlay, providing pkgs.tfpkgs
  nixpkgs.overlays = [ inputs.tfpkgs.overlays.default ];
}
```

The overlay composes [gomod2nix](https://github.com/nix-community/gomod2nix)'s overlay, so it also adds `pkgs.buildGoApplication` and `pkgs.gomod2nix`.

Providers install into the layout `terraform.withPlugins` and `opentofu.withPlugins` expect, so they can be used anywhere a nixpkgs provider can:

```nix
pkgs.opentofu.withPlugins (_: [ pkgs.tfpkgs.terraform-provider-sops ])
```

## Adding a provider

Create `pkgs/terraform-provider-<name>/package.nix`, in a directory named for the attribute you want:

```nix
{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "hashicorp";
  name = "null";
  version = "3.2.4";
  hash = "";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";
}
```

Start with an empty `hash` and a `gomod2nix.toml` containing only `schema = 3`, then:

```sh
nix build .#terraform-provider-null          # fill in the hash Nix reports
make gomod2nix PKG=terraform-provider-null   # pin the Go dependencies
```

Dependencies are pinned per module in `gomod2nix.toml` instead of a single `vendorHash`.
Everything under [pkgs/](pkgs/) is picked up automatically and exposed as a package, an entry in `checks`, and an attribute of the overlay.

`owner`, `repo`, and `rev` are derived from `namespace`, `name`, and `version`.
Override them when upstream does not follow the `<namespace>/terraform-provider-<name>` and `v<version>` convention.

## Updating

```sh
make update           # flake inputs
make update-package PKG=terraform-provider-null
```

`update-package` bumps the version and source hash with `nix-update`, then regenerates `gomod2nix.toml` for the new source.
