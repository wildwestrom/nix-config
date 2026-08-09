{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wev
    slurp
    wl-clipboard-rs
    grim
    wtype
    ydotool
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
    gammastep = {
      enable = true;
      provider = "geoclue2";
      temperature = {
        day = 6500;
        night = 4000;
      };
    };
  };
}
