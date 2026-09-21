{
  lib,
  buildGoApplication,
  fetchFromGitHub,
  mkUpdateScript,
}:

let
  version = "0.4.1";
in
buildGoApplication {
  pname = "terraform-plugin-codegen-framework";
  inherit version;

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-plugin-codegen-framework";
    tag = "v${version}";
    hash = "sha256-a5eWS2pcr7tbAd9xrGJKRZ3DzHoBwM0FMLV5RGQhGa4=";
  };

  modules = ./gomod2nix.toml;
  subPackages = [ "cmd/tfplugingen-framework" ];

  passthru.updateScript = mkUpdateScript { attr = "terraform-plugin-codegen-framework"; };

  meta = {
    description = "Terraform Plugin Framework code generation";
    homepage = "https://github.com/hashicorp/terraform-plugin-codegen-framework";
    license = lib.licenses.mpl20;
    mainProgram = "tfplugingen-framework";
    platforms = lib.platforms.unix;
  };
}
