{
  pkgs,
  username,
  config,
  ...
}: let
  system-theme = "Adwaita";
  cursor-theme = system-theme;
  icon-theme = system-theme;
  terminal = "kitty";
in {
  imports = [
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/default.nix
  ];
  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-hangul
        fcitx5-mozc
        fcitx5-rime
      ];
    };
  };

  dconf.settings = {
    "org/cinnamon/desktop/default-applications/terminal".exec = "${terminal}";
    "org/cinnamon/desktop/applications/terminal".exec = "${terminal}";
  };

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";
    packages = with pkgs; [
      cinnamon.nemo-with-extensions
      cinnamon.nemo-fileroller
      networkmanagerapplet
      gnome.adwaita-icon-theme
      gnome.gnome-font-viewer
      gnome.gucharmap
      pavucontrol # Even though I use pipewire, it works
      element-desktop
      udisks
      imv
      qpwgraph
      shared-mime-info
      xdg-utils
    ];
    sessionVariables = {
      XCURSOR_THEME = cursor-theme;
    };
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
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = "imv-dir.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
        "x-scheme-handler/vscodium" = ["codium-url-handler.desktop" "codium.desktop"];
      };
    };
  };
  programs = {
    librewolf = {
      enable = true;
      settings = {
        "identity.fxaccounts.enabled" = true;
        "general.autoScroll" = true;
        "middlemouse.paste" = false;
        # "browser.fullscreen.autohide" = false;
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
  gtk = {
    enable = true;
    theme.name = system-theme;
    theme.package = pkgs.gnome.gnome-themes-extra;
    cursorTheme.name = cursor-theme;
    # cursorTheme.size = 24; # TODO: Test different values
    cursorTheme.package = pkgs.gnome.adwaita-icon-theme;
    iconTheme.name = icon-theme;
    iconTheme.package = pkgs.gnome.gnome-themes-extra;
  };
}
