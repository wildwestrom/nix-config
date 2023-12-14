{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clip-persist
    wl-clipboard
    wev
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
