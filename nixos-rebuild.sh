#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -xe -o pipefail
shopt -s extglob

pushd ~/nix-config/
if [ -t 0 ] ; then
	$EDITOR .
fi
nixfmt . &>/dev/null
rm -rf ~/.config/mimeapps.list
GLOBIGNORE="*.lock"
git diff -U0 * **/*
echo "NixOS Rebuilding..."
sudo -A nix-channel --update
sudo -A bash -c 'ulimit -n 524288; nixos-rebuild switch --upgrade -vvv --flake .#default --show-trace' &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
sudo chown -R "$USER:$(id -gn)" .git/objects
current=$(nixos-rebuild list-generations --json | jq '.[0].generation')
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
