# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Commands

```sh
make build                              # nix build .#terraform
make check                              # nix flake check (builds every package)
make format                             # nix fmt (treefmt: nixfmt, deadnix, statix)
make update                             # nix flake update
make update-package PKG=terraform-provider-sops   # bump version + hash, regen gomod2nix.toml
make gomod2nix PKG=terraform-provider-sops        # regen gomod2nix.toml only
```

There is no test suite.
`checks` is the package set, so `nix flake check` is the test: it builds everything.
To build one package, `nix build .#<attr>`.

Use `command make` rather than `make` (zsh/Prezto autoload stub shadows the binary in agent subshells).

## Architecture

`flake.nix` (flake-parts) exposes two things built from the same scope:

- `flake.overlays.default` composes gomod2nix's overlay with one adding `pkgs.tfpkgs`, so consumers get `buildGoApplication` and `gomod2nix` too.
- `perSystem` sets `packages`, `checks`, and `legacyPackages` from `packages.nix`.
  `packages`/`checks` are filtered to derivations; `legacyPackages` keeps the full scope, including `buildTerraformProvider`.

`packages.nix` is a `lib.makeScope` over `lib.packagesFromDirectoryRecursive ./pkgs`.
Anything added under [pkgs/](pkgs/) is exposed automatically as a package, a check, and an overlay attribute.
The attribute name is the directory (or file) name, so `pkgs/terraform-provider-sops/package.nix` becomes `terraform-provider-sops`.

[pkgs/buildTerraformProvider.nix](pkgs/buildTerraformProvider.nix) wraps `buildGoApplication`.
Key behaviors a provider definition depends on:

- Source coordinates are derived: `owner = namespace`, `repo = "terraform-provider-${name}"`, `rev = "v${version}"`. Override individually when upstream diverges.
- `attr` defaults to `repo` and names the directory under [pkgs/](pkgs/). Set it when the two differ, as they do when two namespaces ship a provider of the same name; `passthru.updateScript` reads it.
- `postInstall` relocates the binary to `$out/libexec/terraform-providers/<registry>/<namespace>/<name>/<version>/<goos>_<goarch>/`, the layout `terraform.withPlugins` and `opentofu.withPlugins` expect.
- `CGO_ENABLED = 0` (matches goreleaser) and `doCheck = false` (provider tests need live credentials).
- `passthru.updateScript` runs `nix-update` then regenerates `gomod2nix.toml`; `make update-package` invokes it.
- Unrecognized args pass through to `buildGoApplication`; `passthru` and `meta` merge rather than replace.

Go dependencies are pinned per-module in each provider's `gomod2nix.toml`, not with a `vendorHash`.

`pkgs/terraform.nix` is a symlink shim: `terraform` pointing at `opentofu`.

## Adding a provider

Create `pkgs/terraform-provider-<name>/package.nix` calling `buildTerraformProvider` with `namespace`, `name`, `version`, `hash`, `modules = ./gomod2nix.toml`, and `license`.
Start with `hash = ""` and a `gomod2nix.toml` holding only `schema = 3`, build to learn the real hash, then run `make gomod2nix PKG=...`.
