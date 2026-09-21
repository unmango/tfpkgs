{ buildTerraformProvider }:

buildTerraformProvider {
  namespace = "carlpett";
  name = "sops";
  version = "1.4.1";
  hash = "sha256-VQ3Wpf/xyZqo32zQ4SbYcF08jR5iBTqPZ9C3p+Ry06I=";
  modules = ./gomod2nix.toml;
  license = "MPL-2.0";
}
