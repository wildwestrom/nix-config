{
  pkgs,
  username,
  config,
  terminal,
  ...
}:
{
  imports = [
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/default.nix
  ];
  i18n = {
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-hangul
        fcitx5-mozc
        fcitx5-rime
      ];
      fcitx5.waylandFrontend = true;
    };
  };

  dconf.settings = {
    "org/cinnamon/desktop/default-applications/terminal".exec = terminal.bin;
    "org/cinnamon/desktop/applications/terminal".exec = terminal.bin;
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
    # This is where I keep linux specific programs
    packages = with pkgs; [
      networkmanagerapplet
      gnome-font-viewer
      gucharmap
      gnome-calculator
      evince
      kdePackages.okular
      gtk4
      libadwaita
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
      wl-color-picker
      android-udev-rules
      localsend
      nvtopPackages.amd
      gsettings-desktop-schemas
      gnome-disk-utility
      baobab
      wl-color-picker
      vulkan-validation-layers
      ddcui
      gnome-system-monitor
      xorg.xeyes
    ];
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
        "text/html" = "brave-browser.desktop";
        "text/xml" = "brave-browser.desktop";
        "application/rdf+xml" = "brave-browser.desktop";
        "application/rss+xml" = "brave-browser.desktop";
        "application/xhtml+xml" = "brave-browser.desktop";
        "application/xhtml_xml" = "brave-browser.desktop";
        "application/xml" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/ipfs" = "brave-browser.desktop";
        "x-scheme-handler/ipns" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
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
