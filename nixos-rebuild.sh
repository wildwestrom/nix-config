#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e
shopt -s extglob

pushd ~/nix-config/
$EDITOR .
alejandra . &>/dev/null
GLOBIGNORE="*.lock"
git diff -U0 * **/*
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake '.#default' --option eval-cache false --show-trace &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
current=$(nixos-rebuild list-generations | grep current)
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
