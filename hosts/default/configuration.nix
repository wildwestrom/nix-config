{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  username = "main";
in
{
  imports = [
    ./hardware-configuration.nix
    ./emacs.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  boot.initrd.systemd.enable = true;

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amd_iommu=on"
  ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "524288";
  };

  hardware.graphics = {
    enable = true;
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    enable32Bit = true;
  };
  hardware.keyboard.zsa.enable = true;

  programs.nix-ld.enable = true;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.polkit.enable = true;
  # security.sudo.enable = true;
  security.sudo-rs.enable = true;

  # If you get this error, it's probably because you modified the PATH variable for the shell
  # sudo-rs: sudo must be owned by uid 0 and have the setuid bit set

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "60-hdmi-no-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "api.alsa.path" = "hdmi:.*";
              }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 60;
              };
            };
          }
        ];
      };
    };
    extraConfig = {
      pipewire = {
        "10-clock" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [
              44100
              48000
              88200
              96000
              192000
            ];
            "default.clock.quantum" = 128;
          };
        };
        "20-2i2" = {
          context.objects = [
            {
              factory = "alsa-monitor";
              args = {
                node.name = "scarlett_2i2_input";
                node.description = "Focusrite Scarlett 2i2 Pro Input";
                alsa.card_name = "Scarlett 2i2 USB";
                alsa.device = "hw:2,0";
                alsa.format = "s32le";
                alsa.rate = 48000;
                alsa.channels = 2;
                node.latency = 1024;
                audio.position = [
                  "FL"
                  "FR"
                ]; # Define the physical channels
                monitor.channel-properties = {
                  "FL" = {
                    node.description = "2i2 Left Input";
                  };
                  "FR" = {
                    node.description = "2i2 Right Input";
                  };
                };
              };
            }
            {
              factory = "alsa-sink";
              args = {
                node.name = "scarlett_2i2_output";
                node.description = "Focusrite Scarlett 2i2 Pro Output";
                alsa.card_name = "Scarlett 2i2 USB";
                alsa.device = "hw:2,0";
                alsa.format = "s32le";
                alsa.rate = 48000;
                alsa.channels = 2;
                node.latency = 1024;
                audio.position = [
                  "FL"
                  "FR"
                ];
                node.autoconnect = true;
              };
            }
          ];
        };
      };
      pipewire-pulse = {
        # This is supposed to fix audio randomly cutting out while gaming, we'll see
        "20-pulse-properties" = {
          "pulse.min.req" = "256/48000";
          "pulse.min.frag" = "256/48000";
          "pulse.min.quantum" = "256/48000";
        };
      };
    };
  };
  security.wrappers.restic = {
    source = "${pkgs.restic.out}/bin/restic";
    owner = "restic";
    group = "users";
    permissions = "u=rwx,g=,o=";
    capabilities = "cap_dac_read_search=+ep";
  };

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ko_KR.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ko_KR.UTF-8";
    LC_IDENTIFICATION = "ko_KR.UTF-8";
    LC_MEASUREMENT = "ko_KR.UTF-8";
    LC_MONETARY = "ko_KR.UTF-8";
    LC_NAME = "ko_KR.UTF-8";
    LC_NUMERIC = "ko_KR.UTF-8";
    LC_PAPER = "ko_KR.UTF-8";
    LC_TELEPHONE = "ko_KR.UTF-8";
    LC_TIME = "ko_KR.UTF-8";
  };

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    desktopManager = {
      runXdgAutostartIfNone = true;
    };
  };

  services.printing.enable = true;

  security.pam.services.swaylock = {
    enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;
  # this should allow gnome calculator to convert currencies
  services.gnome.glib-networking.enable = true;

  services.dbus.enable = true;

  # Enable automatic login for the user
  # TODO: figure out how to make it work with greetd
  services.getty.autologinUser = username;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd "sway"'';
        user = "greeter";
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bash
    helix
    git
    wget
    fish
    man-db
    ddcutil
    # linux-manual
    man-pages
    man-pages-posix
    lsof
    brightnessctl
    pciutils
    usbutils
    dmidecode
    libnotify
    podman-compose
    clinfo
    adwaita-icon-theme
    virt-manager
    restic
    babashka
  ];

  # Firmware updater
  services.fwupd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # programs.ssh.startAgent = true; # Disabled: conflicts with GNOME keyring's SSH agent

  # # Open ports in the firewall.
  # # 53317 = LocalSend
  # networking.firewall.allowedTCPPorts = [
  #   22
  #   80
  #   443
  #   53317
  # ];
  # networking.firewall.allowedUDPPorts = [
  #   53
  #   53317
  # ];

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      server_names = [
        "quad9"
        "cloudflare"
        "nextdns"
        "mullvad-doh"
      ];
      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];
      odoh_servers = true;
      timeout = 10000;
      lb_strategy = "p2";
      cache = true;
      cache_size = 4092;
      log_file = "/tmp/dnscrypt-proxy.log";
      use_syslog = false; # will make syslog messy otherwise
    };
  };
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn; # add the GUI
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  fonts.packages = with pkgs; [
    sarasa-gothic
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    newcomputermodern
    font-awesome
  ];

  services.udev.packages = [ pkgs.android-udev-rules ];

  programs.fish.enable = true;
  users = {
    defaultUserShell = pkgs.fish;
    users = {
      restic = {
        isNormalUser = true;
      };
      ${username} = {
        isNormalUser = true;
        description = "Christian Westrom";
        extraGroups = [
          "wheel"
          "video"
          "audio"
          "networkmanager"
          "network"
          "libvirtd"
        ];
      };
    };
  };

  # TODO: Reorganize the stuff needed for Wayland
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = false;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
        };
      };
      config = {
        common = {
          default = [ "wlr;gtk" ];
        };
      };
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs username;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${username} = import ./home.nix;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.strings.getName pkg) [
      "obsidian"
      "libsciter"
      "surrealdb"
      "cursor"
      "rust-rover"
      "steam"
      "steam-unwrapped"
      "discord"
    ];

  programs.steam = {
    protontricks.enable = true;
    enable = true;
    extraCompatPackages = with pkgs; [
      steamtinkerlaunch
      proton-ge-bin
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [ ];

  nixpkgs.config.chromium.commandLineArgs = "--gtk-version=4";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  environment.binsh = "${pkgs.dash}/bin/dash";

  virtualisation = {
    # podman = {
    #   enable = true;
    #   defaultNetwork.settings.dns_enabled = true;
    # };
    # docker = {
    #   # enable = true; # Don't enable unless you want docker as root
    #   # daemon.settings = {
    #   #   dns = [
    #   #     "9.9.9.9"
    #   #     "8.8.8.8"
    #   #   ];
    #   # };
    #   autoPrune.enable = true;
    #   rootless = {
    #     enable = true;
    #     setSocketVariable = true;
    #   };
    # };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ username ];

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  home-manager.sharedModules = [
    {
      stylix.targets = {
        helix.enable = false;
        fcitx5.enable = false;
        # gnome.enable = false;
        # qt.enable = false;
      };
    }
  ];

  stylix = {
    enable = true;
    # image = ./wallpaper.jpg;
    # polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/one-light.yaml";

    # targets = {
    #   gnome.enable = false;
    #   qt.enable = false;
    # };

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    fonts = {
      sizes = {
        terminal = 12; # default 12
        applications = 12; # default 12
        desktop = 12; # default 10
        popups = 12; # default 10
      };
      serif = {
        package = pkgs.noto-fonts-cjk-serif;
        name = "Noto Serif CJK KR";
      };

      sansSerif = {
        package = pkgs.noto-fonts-cjk-sans;
        name = "Noto Sans CJK KR";
      };

      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrainsMono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  services.flatpak.enable = true;

  services.joycond.enable = true;
  programs.joycond-cemuhook.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.input = {
    General = {
      UserspaceHID = true;
      ClassicBondedOnly = false;
      FastConnectable = true;
    };
  };

  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
      username
    ];
    substituters = [
      "https://cache.iog.io"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  documentation.dev.enable = true;

  services.fprintd.enable = false;
}
