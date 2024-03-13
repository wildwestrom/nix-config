#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

pushd ~/nix-config/
$EDITOR .
alejandra . &>/dev/null
git diff -U0 **/*.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake '.#default' &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
# sudo nixos-rebuild switch --flake '.#default'
current=$(nixos-rebuild list-generations | grep current)
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
