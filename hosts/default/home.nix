{
  pkgs,
  username,
  config,
  ...
}:
let
  terminal = "kitty";
in
{
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

  xdg.configFile.fcitx5.source = ./fcitx5-config-dir;

  dconf.settings = {
    "org/cinnamon/desktop/default-applications/terminal".exec = "${terminal}";
    "org/cinnamon/desktop/applications/terminal".exec = "${terminal}";
  };

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";
    # This is where I keep linux specific programs
    packages = with pkgs; [
      networkmanagerapplet
      gnome-font-viewer
      gucharmap
      gnome-calculator
      evince
      gtk4
      libadwaita
      pavucontrol # Even though I use pipewire, it works
      fractal
      element-desktop
      nautilus
      imv
      qpwgraph
      shared-mime-info
      dbus
      xdg-utils
      xdg-launch
      gparted
      polkit_gnome
      exfatprogs
      glib
      fontforge-gtk
      python3Packages.setuptools
      wl-color-picker
      android-udev-rules
      localsend
      nvtop-amd
      gsettings-desktop-schemas
      nextcloud-client
      gamescope
      protonup-qt
      winetricks
      protontricks
      wineWowPackages.waylandFull
      steamtinkerlaunch
      # for steamtinkerlaunch to work
      xxd
      xorg.xwininfo
      xorg.xprop
      xorg.xeyes
      xdotool
      # end steamtinkerlaunch
      lutris
      gnome-disk-utility
      baobab
      wl-color-picker
    ];
    # persistence = {
    #   "/persist/${config.home.homeDirectory}" = {
    #     allowOther = true;
    #     directories = [
    #       ".config/lutris"
    #       ".local/share/lutris"
    #     ];
    #   };
    # };
  };
  systemd.user.services = {
    polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Restart = "on-failure";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    # protonmail-bridge = {
    #   Unit = {
    #     Description = "Protonmail Bridge";
    #     After = [ "network-online.target" ];
    #   };

    #   Service = {
    #     Restart = "always";
    #     ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
    #     Environment = [ "Path=${pkgs.gnome3.gnome-keyring}/bin" ];
    #   };
    # };
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
      videos = "${config.home.homeDirectory}/vids";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/gif" = "imv-dir.desktop";
        "image/jpeg" = "imv-dir.desktop";
        "image/png" = "imv-dir.desktop";
        "image/webp" = "imv-dir.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "text/html" = "librewolf.desktop";
        "text/xml" = "librewolf.desktop";
        "application/rdf+xml" = "librewolf.desktop";
        "application/rss+xml" = "librewolf.desktop";
        "application/xhtml+xml" = "librewolf.desktop";
        "application/xhtml_xml" = "librewolf.desktop";
        "application/xml" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/ipfs" = "librewolf.desktop";
        "x-scheme-handler/ipns" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
        "x-scheme-handler/vscodium" = [
          "codium-url-handler.desktop"
          "codium.desktop"
        ];
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mid" = "thunderbird.desktop";
        "font/otf" = "org.gnome.font-viewer.desktop";
        "video/mkv" = "mpv.desktop";
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
  gtk = {
    enable = true;
  };
  qt = {
    enable = true;
  };
}
