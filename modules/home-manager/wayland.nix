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
      # Per-option settings folded into services.mako.settings; keys are the
      # kebab-case names from mako(5). Still milliseconds.
      settings.default-timeout = 1000 * 5;
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
