#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -xe -o pipefail
shopt -s extglob

pushd ~/nix-config/
if [ -t 0 ] ; then
	interactive=1
	$EDITOR .
fi
# sudo can prompt on the terminal; pkexec pops the polkit GUI dialog, which is
# the only option when there's no tty (e.g. run from an editor or agent).
# sudo keeps cwd by default; pkexec runs in root's home unless --keep-cwd, and
# both the flake ref and the chown path below are relative to this directory.
elevate() {
	if [ -n "$interactive" ] ; then
		sudo "$@"
	else
		pkexec --keep-cwd "$@"
	fi
}
nix fmt &>/dev/null
rm -rf ~/.config/mimeapps.list
GLOBIGNORE="*.lock"
git diff -U0 * **/*
echo "NixOS Rebuilding..."
elevate nix-channel --update
elevate bash -c 'ulimit -n 524288; nixos-rebuild switch --upgrade -vvv --flake .#framework --show-trace' &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
elevate chown -R "$USER:$(id -gn)" .git/objects
current=$(nixos-rebuild list-generations --json | jq '.[0].generation')
git commit -am "$current"
popd
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
