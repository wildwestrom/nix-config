# Man pages and developer documentation.
{
  flake.modules.nixos.docs =
    { pkgs, ... }:
    {
      documentation.dev.enable = true;
      environment.systemPackages = with pkgs; [
        man-db
        man-pages
        man-pages-posix
        # linux-manual
      ];
    };

  flake.modules.homeManager.docs =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tldr ];
    };
}
