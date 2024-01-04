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
  };
}
