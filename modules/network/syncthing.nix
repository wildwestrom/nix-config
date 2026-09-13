{
  flake.modules.nixos.syncthing = {
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 ];
  };

  flake.modules.homeManager.syncthing = {
    services.syncthing.enable = true;
  };
}
