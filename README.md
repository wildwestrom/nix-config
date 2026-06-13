# System config

This is my system config.

It has both my system and home manager.

It's somewhat poorly organized at the moment.

The command I use to rebuild is `nixos-rebuild.sh` aliased to nixconf.

To see any build errors, check nixos-switch.log.

## Tips and tricks

Mostly for myself.

I keep a bunch of flake templates for myself to use in various projects. The problem I came across is that each one would use a different nixpkgs, downloading it from the internet, thereby duplicating many dependencies.

The solution is to pin each flake to my system nixpkgs.
I haven't found a way to do this automatically, but I can run this command to pin each project.

`nix flake update nixpkgs --override-input nixpkgs flake:nixpkgs`

## Known issues

TODO: Wire up something equivalent to what swaynag did for me before for niri. 
