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
      swayimg
      crosspipe
      shared-mime-info
      dbus
      xdg-utils
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
        "image/gif" = "swayimg.desktop";
        "image/jpeg" = "swayimg.desktop";
        "image/png" = "swayimg.desktop";
        "image/webp" = "swayimg.desktop";
        "image/svg+xml" = "swayimg.desktop";
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
    # swayimg replaces imv because, unlike imv, it honours the EXIF Orientation
    # tag (built with libexif). So 'r' / 'Shift+r' rotate purely by rewriting
    # that tag - no pixel data is ever touched, making it completely lossless.
    # swayimg's exec waits for the command to finish, then `reload` re-reads the
    # file and re-applies the new orientation, so the view follows immediately.
    configFile."swayimg/config".text =
      let
        rotate = pkgs.writeShellApplication {
          name = "swayimg-rotate";
          runtimeInputs = [ pkgs.exiftool ];
          text = ''
            # usage: swayimg-rotate FILE cw|ccw
            # Rotate by cycling the EXIF Orientation tag (1-8). Lossless: only
            # metadata changes, the encoded pixels are left untouched.
            img=$1
            dir=''${2:-cw}
            cur=$(exiftool -n -s3 -Orientation "$img" 2>/dev/null || true)
            case "$cur" in 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8) ;; *) cur=1 ;; esac
            case "$dir" in
              cw)
                case "$cur" in
                  1) new=6 ;; 2) new=7 ;; 3) new=8 ;; 4) new=5 ;;
                  5) new=2 ;; 6) new=3 ;; 7) new=4 ;; 8) new=1 ;;
                esac
                ;;
              ccw)
                case "$cur" in
                  1) new=8 ;; 2) new=5 ;; 3) new=6 ;; 4) new=7 ;;
                  5) new=4 ;; 6) new=1 ;; 7) new=2 ;; 8) new=3 ;;
                esac
                ;;
              *)
                echo "usage: swayimg-rotate FILE cw|ccw" >&2
                exit 1
                ;;
            esac
            exiftool -overwrite_original -n -Orientation="$new" "$img" >/dev/null
          '';
        };
      in
      ''
        # Opening one image also loads its folder siblings, mirroring the old
        # imv-dir behaviour so you can still page through the directory.
        [list]
        all = yes

        # imv's vim-like bindings ported onto swayimg. Keys not listed keep
        # swayimg's own defaults (m/Shift+m flip, [ ] view-rotate, Return
        # gallery, Insert mark, +/- and Equal zoom, all mouse bindings).
        # swayimg has no multi-key sequences, so imv's `gg` collapses to `g`.
        [keys.viewer]
        # Lossless rotate via the EXIF Orientation tag (our feature). Ctrl+r is
        # imv's native rotate-clockwise key, bound here to the same command.
        r = exec ${rotate}/bin/swayimg-rotate '%' cw; reload
        Shift+r = exec ${rotate}/bin/swayimg-rotate '%' ccw; reload
        Ctrl+r = exec ${rotate}/bin/swayimg-rotate '%' cw; reload

        # Navigation (imv: Left/Right prev/next, gg/G first/last, x close, q quit)
        Left = prev_file
        Right = next_file
        g = first_file
        Shift+g = last_file
        x = skip_file
        q = exit

        # Pan with hjkl (imv)
        h = step_left 10
        j = step_down 10
        k = step_up 10
        l = step_right 10

        # Zoom & scale (imv: Up/Down and i/o zoom, a actual size, s next scale
        # mode, c center; Backspace resets scale + position like imv's reset)
        Up = zoom +10
        Down = zoom -10
        i = zoom +10
        o = zoom -10
        a = zoom real
        s = zoom
        c = position center
        BackSpace = zoom optimal; position center

        # Animation (imv: `.` next frame, Space pause/play)
        period = next_frame
        Space = animation

        # Overlay, fullscreen, slideshow, print-to-stdout (imv: d/f/t/p)
        d = info
        f = fullscreen
        t = mode slideshow
        p = exec cat '%'

        # Carry the vim navigation keys into gallery mode too.
        [keys.gallery]
        h = step_left
        j = step_down
        k = step_up
        l = step_right
        g = first_file
        Shift+g = last_file
        q = exit
      '';
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
