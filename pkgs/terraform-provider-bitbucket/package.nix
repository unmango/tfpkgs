{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "DrFaust92";
  name = "bitbucket";
  version = "2.52.0";
  hash = "sha256-m5Ya99ulMesUwl54sbHuvOYumbPcAhWMESVGbXIOJpE=";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";

  meta.description = "Terraform provider for Bitbucket Cloud";
}
