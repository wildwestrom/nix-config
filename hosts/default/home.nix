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
    stateVersion = "23.11";
    packages = with pkgs; [
      gtk3
      cinnamon.nemo-with-extensions
      networkmanagerapplet
      gnome.adwaita-icon-theme
      gnome.gnome-font-viewer
      gnome.gucharmap
      pavucontrol # Even though I use pipewire, it works
      element-desktop
      udisks
    ];
  };
  xdg = {
    enable = true;
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
        "browser.fullscreen.autohide" = false;
        "ui.key.menuAccessKeyFocuses" = false;
      };
    };
  };
  services.syncthing.enable = true;
  systemd.user.services.protonmail-bridge = {
    Unit = {
      Description = "Protonmail Bridge";
      After = ["network-online.target"];
    };

    Service = {
      Restart = "always";
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
      Environment = [
        "Path=${pkgs.gnome3.gnome-keyring}/bin:${pkgs.pass}/bin"
        "PASSWORD_STORE_DIR=/home/jon/.password-store"
      ];
    };
  };
}
