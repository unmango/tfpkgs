{
  lib,
  buildGoApplication,
  fetchFromGitHub,
  mkUpdateScript,
}:

let
  version = "0.1.12";
in
buildGoApplication {
  pname = "terraform-backend-git";
  inherit version;

  src = fetchFromGitHub {
    owner = "plumber-cd";
    repo = "terraform-backend-git";
    tag = "v${version}";
    hash = "sha256-Heg2Rj8s+mQwlRiSj9BQVaO0IFTU/MSnrQrOaNWMo9c=";
  };

  modules = ./gomod2nix.toml;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/plumber-cd/terraform-backend-git/cmd.Version=${version}"
  ];

  passthru.updateScript = mkUpdateScript { attr = "terraform-backend-git"; };

  meta = {
    description = "Terraform HTTP backend that stores state in a Git repository";
    homepage = "https://github.com/plumber-cd/terraform-backend-git";
    license = lib.licenses.asl20;
    mainProgram = "terraform-backend-git";
    platforms = lib.platforms.unix;
  };
}
