build:
	nix build .#terraform

update:
	nix flake update

update-package:
	nix-update --flake $(PKG)

check lint:
	nix flake check

format fmt:
	nix fmt
