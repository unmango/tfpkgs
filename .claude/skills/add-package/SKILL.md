---
name: add-package
description: Adds a new package to this repo under pkgs/, either a Terraform/OpenTofu provider via buildTerraformProvider or a Go tool via buildGoApplication. Use when packaging a terraform provider or Go CLI into this flake, or when a package build fails on a source hash or gomod2nix.toml.
---

# Adding a package

Packages live in `pkgs/`.
`packages.nix` builds the scope with `lib.packagesFromDirectoryRecursive`, so a new `pkgs/<attr>/package.nix` becomes a package, a check, and an overlay attribute with no registration step.
The attribute name is the directory name.

Substitute the directory name for `<attr>` throughout.

## 1. Pick the builder

A Terraform/OpenTofu provider uses `buildTerraformProvider` (`pkgs/buildTerraformProvider.nix`).
It derives the source coordinates, disables cgo, skips the test suite, and relocates the binary into `libexec/terraform-providers/<registry>/<namespace>/<name>/<version>/<goos>_<goarch>/`, the layout `terraform.withPlugins` and `opentofu.withPlugins` expect.

Any other Go program uses `buildGoApplication` directly.
See `pkgs/terraform-plugin-codegen-openapi/package.nix`.

## 2. Collect the upstream facts

For a provider: the registry namespace and provider name (`registry.terraform.io/<namespace>/<name>`), the release version without its leading `v`, and the SPDX license id.
`buildTerraformProvider` derives `owner = namespace`, `repo = "terraform-provider-${name}"`, and `rev = "v${version}"`.
Override any of those individually when upstream diverges, along with `registry` and `fetcher`.

For a Go tool: the GitHub owner and repo, the version, the license, and the `cmd/...` path holding `main`.

## 3. Create the directory with a stub module lock

```sh
mkdir -p pkgs/<attr>
printf 'schema = 3\n' > pkgs/<attr>/gomod2nix.toml
```

The stub is required.
Generating the real lock evaluates `.#<attr>.src`, which evaluates `package.nix`, which needs `modules` to point at a file that exists.

## 4. Write `package.nix`

Leave `hash` empty; step 5 fills it in.

Provider:

```nix
{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "carlpett";
  name = "sops";
  version = "1.4.1";
  hash = "";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";
}
```

Unrecognized arguments pass through to `buildGoApplication`.
`passthru` and `meta` merge with the defaults rather than replacing them, so `meta.description = "..."` overrides just that field.

Go tool:

```nix
{
  lib,
  buildGoApplication,
  fetchFromGitHub,
  mkUpdateScript,
}:

let
  version = "0.3.0";
in
buildGoApplication {
  pname = "terraform-plugin-codegen-openapi";
  inherit version;

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-plugin-codegen-openapi";
    tag = "v${version}";
    hash = "";
  };

  modules = ./gomod2nix.toml;
  subPackages = [ "cmd/tfplugingen-openapi" ];

  passthru.updateScript = mkUpdateScript { attr = "terraform-plugin-codegen-openapi"; };

  meta = {
    description = "OpenAPI to Terraform provider code generation specification";
    homepage = "https://github.com/hashicorp/terraform-plugin-codegen-openapi";
    license = lib.licenses.mpl20;
    mainProgram = "tfplugingen-openapi";
    platforms = lib.platforms.unix;
  };
}
```

## 5. Learn the source hash

```sh
nix build --no-link .#<attr>.src
```

The build fails with a hash mismatch.
Copy the `got:` value into `hash` and re-run until it succeeds.

## 6. Generate the module lock

```sh
nix develop --command make gomod2nix PKG=<attr>
```

The `gomod2nix` binary comes from the dev shell.
Drop the `nix develop --command` prefix only when already inside `nix develop`.

Go dependencies are pinned per-module in `gomod2nix.toml`, not with a `vendorHash`.
Never hand-edit the generated file.

Outside `nix develop`, invoke make as `command make`: the zsh/Prezto autoload stub shadows the binary in agent subshells.

## 7. Build and format

```sh
nix build .#<attr>
command make format
```

For a provider, confirm the install layout:

```sh
find "$(nix build --no-link --print-out-paths .#<attr>)/libexec" -type f
```

`command make check` builds every package in the repo and is slow.
Run it when the change touches a shared file such as `pkgs/buildTerraformProvider.nix`, not for a single new package.

## 8. When something fails

- Hash mismatch on `src`: step 5, paste the `got:` value.
- `No such file or directory` for `gomod2nix.toml`: the stub from step 3 is missing.
- Build cannot find a Go module: rerun step 6.
- Provider binary lands in `$out/bin`: `buildGoApplication` was used where `buildTerraformProvider` was meant.

## 9. Bumping the version later

```sh
command make update-package PKG=<attr>
```

That runs `passthru.updateScript` (`pkgs/mkUpdateScript.nix`): `nix-update` bumps the version and hash, then `gomod2nix` regenerates the lock.
`buildTerraformProvider` wires the update script automatically; a `buildGoApplication` package sets `passthru.updateScript = mkUpdateScript { attr = "<attr>"; }` itself.
