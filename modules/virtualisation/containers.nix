# Rootless podman (user service) and distrobox on top of it.
{
  flake.modules.nixos.containers =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.podman-compose ];
      # Rootful podman/docker were tried and dropped:
      # virtualisation.podman = { enable = true; defaultNetwork.settings.dns_enabled = true; };
      # virtualisation.docker.rootless = { enable = true; setSocketVariable = true; };
    };

  flake.modules.homeManager.containers =
    { pkgs, ... }:
    {
      services.podman.enable = true;
      programs.distrobox.enable = true;
      home.packages = [ pkgs.docker-compose ];
    };
}
