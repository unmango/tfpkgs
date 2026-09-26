{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "go-gitea";
  name = "gitea";
  version = "0.8.1";
  hash = "sha256-tQ9jUdP4QtYSFo3gRw4TDwVx17kPPcfFym82xXp6IWs=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider for Gitea";
}
