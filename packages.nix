{
  lib,
  newScope,
  # Flake inputs, for the packages that wrap an upstream flake output rather
  # than building from source.
  inputs,
}:

lib.makeScope newScope (
  self:
  {
    inherit inputs;
  }
  // lib.packagesFromDirectoryRecursive {
    inherit (self) callPackage;
    directory = ./pkgs;
  }
)
