#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -xe -o pipefail
shopt -s extglob

pushd ~/nix-config/
$EDITOR .
nixfmt . &>/dev/null
GLOBIGNORE="*.lock"
git diff -U0 * **/*
echo "NixOS Rebuilding..."
sudo nix-channel --update
sudo nixos-rebuild switch -vvv --flake '.#default' --option eval-cache false --show-trace &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
current=$(nixos-rebuild list-generations | grep current)
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
