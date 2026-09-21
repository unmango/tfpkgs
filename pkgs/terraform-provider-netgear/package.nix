{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "unmango";
  name = "netgear";
  # Upstream has no tagged release; pinned to a commit on main.
  version = "0.0.0-unstable-2026-09-17";
  rev = "d85eae0b98685aae285edc701663bb3cb8c00dae";
  hash = "sha256-UtOm6c3H1EiQDeRh99eRllj47Nhd4Lk1RUp31zZ8y38=";
  modules = ./gomod2nix.toml;
  license = "MIT";

  meta.description = "Terraform provider for (some) NetGear devices";
}
