{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clip-persist
    wl-clipboard
    wev
    glfw-wayland
    slurp
  ];
  services = {
    clipman = {
      enable = true;
    };
    mako = {
      enable = true;
      defaultTimeout = 1000 * 5;
    };
    wlsunset = {
      enable = true;
      temperature.night = 3000;
      latitude = "37.5";
      longitude = "127.0";
    };
  };
}
