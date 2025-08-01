#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -xe -o pipefail
shopt -s extglob

pushd ~/nix-config/
$EDITOR .
nixfmt . &>/dev/null
rm -rf ~/.config/mimeapps.list
GLOBIGNORE="*.lock"
git diff -U0 * **/*
echo "NixOS Rebuilding..."
nix flake update
sudo nix-channel --update
sudo nixos-rebuild switch --upgrade -vvv --flake '.#default' --show-trace &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
current=$(nixos-rebuild list-generations --json | jq '.[0].generation')
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
