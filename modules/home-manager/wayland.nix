{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wev
    slurp
    wl-clipboard-rs
  ];
  services = {
    wl-clip-persist = {
      systemdTargets = [ "graphical-session.target" ];
      enable = true;
    };
    wluma = {
      enable = true;
    };
    mako = {
      enable = true;
      defaultTimeout = 1000 * 5;
    };
    wlsunset = {
      enable = true;
      systemdTarget = "graphical-session.target";
      temperature.night = 4000;
      # latitude = "51.1";
      # longitude = "-114.0";
      latitude = "40.7";
      longitude = "-73.9";
      # latitude = "37.5";
      # longitude = "127.0";
    };
  };
}
