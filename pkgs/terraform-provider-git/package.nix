{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "unstoppablemango";
  name = "git";
  version = "0.0.4";
  hash = "sha256-+P5DYbbsv8U9w5HYu6jvKd81nGxicm2Djxp5n4fkUes=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider for managing the desired state of git repositories";
}
