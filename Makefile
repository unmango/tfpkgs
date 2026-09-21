build:
	nix build .#terraform

update:
	nix flake update

update-package:
	nix run .#$(PKG).updateScript

gomod2nix:
	gomod2nix generate \
		--dir "$$(nix build --no-link --print-out-paths .#$(PKG).src)" \
		--outdir pkgs/$(PKG)

check lint:
	nix flake check

format fmt:
	nix fmt
