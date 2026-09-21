{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "microsoft";
  name = "azuredevops";
  version = "1.16.0";
  hash = "sha256-FHsYwlV6FywqZYGsXd7S6wlIB30qXC9/oYBRG3o2tIU=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider for Azure DevOps";
}
