# System config

NixOS + home-manager for my Framework 13, as one flake.

Rebuild with `./nixos-rebuild.sh` (aliased to `nixconf`); build errors land in
`nixos-switch.log`. It commits on success.

## Layout

The config follows the [dendritic pattern](https://github.com/mightyiam/dendritic):
`flake.nix` holds inputs only, and every `.nix` file under `modules/` is
auto-imported as a [flake-parts](https://flake.parts) module by
[import-tree](https://github.com/vic/import-tree). Files and directories with a
leading `_` are skipped, which is how non-module assets (the generated
`_hardware-configuration.nix`, toml/icc files) live next to the code that uses
them.

Each file is one *aspect* of the machine and may define a NixOS half, a
home-manager half, or both:

```nix
{
  flake.modules.nixos.audio = { ... };        # services.pipewire, groups, ...
  flake.modules.homeManager.audio = { ... };  # user packages, dconf, ...
}
```

A host is just a list of aspect names (`modules/hosts/framework/default.nix`);
each name pulls in whichever halves exist. So the audio stack, or the whole
desktop session (compositor + greeter command + portals + idle/lock), lives in
one file, and swapping niri for sway is a one-word change in the host.

```
modules/
  flake/          flake-parts plumbing, formatter, the `user` argument
  hosts/          one directory per machine: aspect list + hardware config
  users/          the account and home-manager glue
  core/           nix daemon, nixpkgs policy + overlays, boot, locale, security
  hardware/       audio, graphics, bluetooth, printing, monitors, input devices
  network/        networkmanager + firewall, dnscrypt, vpn, syncthing
  desktop/        niri, sway, waybar, wayland plumbing, greetd, stylix, fonts, fcitx5, xdg
  cli/            fish + aliases, terminal (the `my.terminal` option), CLI tools
  dev/            helix, emacs, other editors, git, toolchains, LLM agents, matlab
  apps/           browser, comms, media, creative, office, utilities, wine, gaming
  virtualisation/ libvirt, podman/distrobox, flatpak
  backup/         restic
pkgs/             local packages (also exposed as `nix build .#claude-desktop`)
```

Conventions:

- Cross-cutting values are options or arguments, not `specialArgs`:
  `pkgs.unstable.<name>` (overlay in `core/nixpkgs.nix`), `config.my.terminal`
  (`cli/terminal.nix`), and `user` (`flake/user.nix`).
- A subsystem owns everything about itself, including the user's group
  membership (`audio.nix` adds `"audio"`), its firewall ports, and its
  `xdg.mimeApps` associations.
- Unfree packages must be named in the allowlist in `core/nixpkgs.nix`.

## Tips and tricks

Mostly for myself.

I keep a bunch of flake templates for myself to use in various projects. The problem I came across is that each one would use a different nixpkgs, downloading it from the internet, thereby duplicating many dependencies.

The solution is to pin each flake to my system nixpkgs.
I haven't found a way to do this automatically, but I can run this command to pin each project.

`nix flake update nixpkgs --override-input nixpkgs flake:nixpkgs`

## Secrets

API keys and other secrets are not tracked here. Fish sources `~/.config/fish/secrets.fish` if it exists, so put them there on each machine:

```fish
# ~/.config/fish/secrets.fish  (chmod 600)
set -gx ANTHROPIC_API_KEY sk-ant-...
```

## Known issues

TODO: Wire up something equivalent to what swaynag did for me before for niri.

## ATTN: LLMs

After making a change here, run `./nixos-rebuild.sh` yourself. It pops a graphical sudo prompt on my end, so it's not blocked, and I can cancel it if I don't like the diff it prints. Don't ask first.

New files must be `git add`ed before the flake can see them.
