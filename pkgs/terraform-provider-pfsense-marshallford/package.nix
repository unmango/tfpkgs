{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "marshallford";
  name = "pfsense";
  attr = "terraform-provider-pfsense-marshallford";
  version = "0.22.0";
  hash = "sha256-hGPq3m41DmfvpZgHSYVVH/vqhyU5WrgK3P4d6NBlU6k=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider to configure pfSense firewall/router devices";
}
