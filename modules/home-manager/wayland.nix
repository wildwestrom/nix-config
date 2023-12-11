{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    wl-clip-persist
    wl-clipboard
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
