{
  buildTerraformProvider,
  fetchFromGitLab,
  go_1_27,
}:

buildTerraformProvider {
  namespace = "gitlabhq";
  name = "gitlab";
  version = "19.4.0";
  hash = "sha256-sbO2xIWni2h6i3/qSZySPk6CVFlcb/lG/q7hMyYtfjs=";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";

  # The GitHub repository under the registry namespace holds only docs.
  owner = "gitlab-org";
  fetcher = fetchFromGitLab;

  go = go_1_27;

  meta.description = "Terraform provider for GitLab";
}
