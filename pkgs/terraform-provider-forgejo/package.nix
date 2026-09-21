{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "svalabs";
  name = "forgejo";
  version = "1.6.1";
  hash = "sha256-L32O7iCyqa1fO7ZCXJTYQiRSFSEkZ93PZz9wmBlSh3g=";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";

  meta.description = "Terraform provider for Forgejo";
}
