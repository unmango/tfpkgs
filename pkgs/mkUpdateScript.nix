{
  gomod2nix,
  nix-update,
  writeShellApplication,
}:

# Bumps the version and source hash of the package exposed as `attr`, then
# regenerates its gomod2nix.toml for the new source. Run from the repository
# root.
{ attr }:
writeShellApplication {
  name = "update-${attr}";
  runtimeInputs = [
    nix-update
    gomod2nix
  ];
  text = ''
    nix-update --flake ${attr}
    src=$(nix build --no-link --print-out-paths ".#${attr}.src")
    gomod2nix generate --dir "$src" --outdir "pkgs/${attr}"
  '';
}
