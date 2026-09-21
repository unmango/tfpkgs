# tfpkgs

[![CI](https://github.com/unmango/tfpkgs/actions/workflows/ci.yml/badge.svg)](https://github.com/unmango/tfpkgs/actions/workflows/ci.yml)
[![Cachix](https://img.shields.io/badge/cachix-unstoppablemango-blue.svg)](https://unstoppablemango.cachix.org)
[![License](https://img.shields.io/github/license/unmango/tfpkgs)](LICENSE)

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

## Packages

Providers:

| Attribute | Upstream |
| --- | --- |
| `terraform-provider-pfsense` | [marshallford/terraform-provider-pfsense](https://github.com/marshallford/terraform-provider-pfsense) |
| `terraform-provider-sops` | [carlpett/terraform-provider-sops](https://github.com/carlpett/terraform-provider-sops) |

Code generation tools from the [Terraform plugin codegen](https://developer.hashicorp.com/terraform/plugin/code-generation) toolchain:

| Attribute | Binary | Upstream |
| --- | --- | --- |
| `terraform-plugin-codegen-framework` | `tfplugingen-framework` | [hashicorp/terraform-plugin-codegen-framework](https://github.com/hashicorp/terraform-plugin-codegen-framework) |
| `terraform-plugin-codegen-openapi` | `tfplugingen-openapi` | [hashicorp/terraform-plugin-codegen-openapi](https://github.com/hashicorp/terraform-plugin-codegen-openapi) |

`terraform` is a shim exposing `opentofu` under the `terraform` name.

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
