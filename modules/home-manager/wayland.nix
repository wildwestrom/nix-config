{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clip-persist
    wl-clipboard
    wev
    glfw-wayland
    slurp
  ];
  services = {
    clipman = {
      systemdTarget = "graphical-session.target";
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
      latitude = "37.5";
      longitude = "127.0";
    };
  };
}
