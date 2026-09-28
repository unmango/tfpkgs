{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "integrations";
  name = "github";
  version = "6.13.0";
  hash = "sha256-2y25AE4iLckdvvFv+vPRdl2wLCPlUnK2Xc73m0qVyxc=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider for GitHub";
}
