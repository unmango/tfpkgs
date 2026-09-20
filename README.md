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

Providers install into the layout `terraform.withPlugins` and `opentofu.withPlugins` expect, so they can be used anywhere a nixpkgs provider can:

```nix
pkgs.opentofu.withPlugins (_: [ pkgs.tfpkgs.terraform-provider-sops ])
```

## Adding a provider

Create `pkgs/terraform-provider-<name>.nix`, named for the attribute you want:

```nix
{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "hashicorp";
  name = "null";
  version = "3.2.4";
  hash = "";
  vendorHash = "";
  license = "MPL-2.0";
}
```

Leave `hash` and `vendorHash` empty, run `make build` twice, and fill in the hashes Nix reports.
Every file under [pkgs/](pkgs/) is picked up automatically and exposed as a package, an entry in `checks`, and an attribute of the overlay.

`owner`, `repo`, and `rev` are derived from `namespace`, `name`, and `version`.
Override them when upstream does not follow the `<namespace>/terraform-provider-<name>` and `v<version>` convention.

## Updating

```sh
make update           # flake inputs
make update-package PKG=terraform-provider-null
```
