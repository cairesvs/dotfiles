_default:
    just --list

check:
    nix flake check

darwin-build profile="aarch64":
    just build "darwinConfigurations.{{ profile }}.config.system.build.toplevel"

darwin-switch profile="aarch64":
    darwin-rebuild switch --flake ".#{{ profile }}"
