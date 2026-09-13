# Framework 13 (AMD 7040). The only host right now.
#
# A host is just a list of aspect names. Each name pulls in the NixOS half
# *and* the home-manager half of that aspect, whichever exist, so swapping the
# desktop is a one-word change (e.g. "niri" -> "sway").
{
  inputs,
  config,
  lib,
  user,
  ...
}:
let
  aspects = [
    # core
    "nix"
    "nixpkgs"
    "boot"
    "locale"
    "security"
    "system"
    "storage"
    "docs"

    # who
    "user-main"

    # hardware
    "graphics"
    "audio"
    "bluetooth"
    "printing"
    "monitors"
    "input-devices"

    # network
    "networking"
    "dns"
    "vpn"
    "syncthing"

    # desktop -- swap "niri" for "sway" to go back
    "niri"
    "wayland"
    "waybar"
    "session"
    "theme"
    "fonts"
    "input-method"
    "xdg"

    # shell & tools
    "shell"
    "terminal"
    "cli-tools"
    "helix"
    "emacs"
    "editors"
    "git"
    "languages"
    "llm"
    "matlab"

    # apps
    "browser"
    "comms"
    "media"
    "creative"
    "office"
    "utilities"
    "windows"
    "gaming"

    # virtualisation
    "libvirt"
    "containers"
    "flatpak"

    # backup
    "restic"
  ];

  # `config.flake.modules` is where every aspect file registered itself.
  pick = class: map (name: config.flake.modules.${class}.${name} or { }) aspects;

  known =
    name: (config.flake.modules.nixos ? ${name}) || (config.flake.modules.homeManager ? ${name});
  unknown = lib.filter (name: !known name) aspects;
in
{
  flake.nixosConfigurations.framework =
    assert lib.assertMsg (unknown == [ ]) "hosts/framework: unknown aspects ${toString unknown}";
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        inputs.home-manager.nixosModules.home-manager
        ./_hardware-configuration.nix
        {
          networking.hostName = "nixos";

          # Framework 13 AMD: without this the display flickers / hangs on the
          # iGPU's scatter-gather path.
          boot.kernelParams = [ "amdgpu.sg_display=0" ];

          services.fprintd.enable = false;

          # Firmware updater (fwupd knows the Framework BIOS + retimers).
          services.fwupd.enable = true;

          home-manager.users.${user.name}.imports = pick "homeManager";

          # See https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
          # Never change after install.
          system.stateVersion = "25.05";
        }
      ]
      ++ pick "nixos";
    };
}
