{
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/default.nix
  ];
  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-hangul
        fcitx5-mozc
        fcitx5-rime
      ];
    };
  };

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "23.05";
    packages = with pkgs; [
      gtk3
      cinnamon.nemo-with-extensions
      networkmanagerapplet
      protonmail-bridge
      gnome.adwaita-icon-theme
      gnome.gnome-font-viewer
      gnome.gucharmap
      pavucontrol # Even though I use pipewire, it works
    ];
  };
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      # defaultApplications = {
      # };
    };
    userDirs = {
      enable = true;
      createDirectories = false;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/text";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/audio";
      pictures = "${config.home.homeDirectory}/images";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };
  };
  programs = {
    librewolf = {
      enable = true;
      settings = {
        "identity.fxaccounts.enabled" = true;
        "general.autoScroll" = true;
        "middlemouse.paste" = false;
      };
    };
  };
}
