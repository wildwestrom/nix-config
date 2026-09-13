# NetworkManager and the baseline firewall. Ports for specific services live
# with the service (syncthing.nix, utilities.nix for LocalSend).
{ user, ... }:
{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${user.name}.extraGroups = [
        "networkmanager"
        "network"
      ];

      networking.firewall = {
        allowedTCPPorts = [
          22
          80
          443
        ];
        allowedUDPPorts = [ 53 ];
      };

      # programs.ssh.startAgent = true; # Disabled: conflicts with GNOME keyring's SSH agent
      # services.openssh.enable = true;

      environment.systemPackages = with pkgs; [
        wget
        curl
      ];
    };

  flake.modules.homeManager.networking =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        networkmanagerapplet
        tcpdump
        nmap
        dig
        unixtools.netstat
        unixtools.route
        unixtools.net-tools
        filezilla
      ];
    };
}
