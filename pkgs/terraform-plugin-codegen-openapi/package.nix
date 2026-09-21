{
  lib,
  buildGoApplication,
  fetchFromGitHub,
  mkUpdateScript,
}:

let
  version = "0.3.0";
in
buildGoApplication {
  pname = "terraform-plugin-codegen-openapi";
  inherit version;

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-plugin-codegen-openapi";
    tag = "v${version}";
    hash = "sha256-6xI6PVlvYHwOnWjE0pKYDF/FvdomE5KydS7gBokJ2EM=";
  };

  modules = ./gomod2nix.toml;
  subPackages = [ "cmd/tfplugingen-openapi" ];

  passthru.updateScript = mkUpdateScript { attr = "terraform-plugin-codegen-openapi"; };

  meta = {
    description = "OpenAPI to Terraform provider code generation specification";
    homepage = "https://github.com/hashicorp/terraform-plugin-codegen-openapi";
    license = lib.licenses.mpl20;
    mainProgram = "tfplugingen-openapi";
    platforms = lib.platforms.unix;
  };
}
