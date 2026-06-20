{
  pkgs,
  username,
  config,
  terminal,
  ...
}:
{
  imports = [
    # Trying out niri instead of sway. Swap these back to return to sway.
    # ../../modules/home-manager/sway.nix
    ../../modules/home-manager/niri.nix
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
      crosspipe
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
      tridactyl-native
    ];
  };
  systemd.user.services = {
    # Sweep away .direnv caches for projects untouched for 90+ days. Removing
    # the dir drops nix-direnv's GC roots, so the weekly system `nix.gc` can
    # then reclaim the pinned closures. Re-entering a project rebuilds its cache.
    prune-stale-direnv = {
      Unit.Description = "Prune stale .direnv caches (90+ days untouched)";
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "prune-stale-direnv" ''
          ${pkgs.findutils}/bin/find ${config.home.homeDirectory} \
            -maxdepth 6 -type d -name .direnv -mtime +90 -prune \
            -exec ${pkgs.coreutils}/bin/rm -rf {} +
        '';
      };
    };
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
  systemd.user.timers.prune-stale-direnv = {
    Unit.Description = "Weekly prune of stale .direnv caches";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
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
      # projects = "${config.home.homeDirectory}/code"; # In preparation for when this drops.
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/gif" = "imv-dir.desktop";
        "image/jpeg" = "imv-dir.desktop";
        "image/png" = "imv-dir.desktop";
        "image/webp" = "imv-dir.desktop";
        "application/pdf" = "sioyek.desktop";
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
