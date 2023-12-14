{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/default.nix
  ];

  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      gtk3
      cinnamon.nemo-with-extensions
      networkmanagerapplet
      protonmail-bridge
      fcitx5
      gnome.adwaita-icon-theme
      gnome.gnome-font-viewer
      gnome.gucharmap
      pavucontrol # Even though I use pipewire, it works
    ];
  };
  programs = {
    librewolf = {
      enable = true;
      settings = {
        "identity.fxaccounts.enabled" = true;
        "general.autoScroll" = true;
        "middlemouse.paste" = false;
        "browser.download.dir" = "/home/${username}/downloads";
      };
    };
  };
}
