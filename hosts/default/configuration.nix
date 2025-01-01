# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
# config-dir = "nix-config";
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  boot.kernelParams = [ "amdgpu.sg_display=0" ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "524288";
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  hardware.opengl = {
    enable = true;
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    driSupport32Bit = true;
  };
  hardware.keyboard.zsa.enable = true;

  programs.nix-ld.enable = true;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.sudo-rs.enable = true; # let's evaluate this and see if it works
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # TODO: Enable once stable
    extraConfig = {
      pipewire = {
        "99-silent-bell" = {
          "context.properties.module.x11.bell" = false;
        };
      };
    };
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  ## Enable on 23.11
  # environment.etc = let
  #   json = pkgs.formats.json {};
  # in {
  #   "pipewire/pipewire.d/99-silent-bell.conf".source = json.generate "99-silent-bell.conf" {
  #     context.properties."module.x11.bell" = false;
  #   };
  # };

  programs.dconf.enable = true;

  # "Experimental Features"
  # But I'm enabling them because I want to test them.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-54f330ac-2d3b-4e33-9aa1-edd5a69f1a91".device = "/dev/disk/by-uuid/54f330ac-2d3b-4e33-9aa1-edd5a69f1a91";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    # Make sure services like fcitx5 start
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

  # Enable automatic login for the user.
  services.getty.autologinUser = "main";
  # environment.etc."greetd/environments".text = ''
  #   sway
  #   nushell
  # '';
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
    wget
    fish
    man-db
    ddcutil
    linux-manual
    man-pages
    man-pages-posix
    # nushell
    brightnessctl
    pciutils
    usbutils
    dmidecode
    libnotify
    podman-compose
    clinfo
    adwaita-icon-theme
    virt-manager
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

  # Open ports in the firewall.
  # 53317 = LocalSend
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    53317
  ];
  networking.firewall.allowedUDPPorts = [
    53
    53317
  ];

  services.resolved = {
    fallbackDns = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    enable = true;
  };
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  fonts.packages = with pkgs; [
    sarasa-gothic
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  services.udev.packages = [ pkgs.android-udev-rules ];

  programs.fish.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "Christian Westrom";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  # TODO: Reorganize the stuff needed for Wayland
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = false;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "";
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
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
      "libsciter"
      "surrealdb"
      "cursor"
    ];

  nixpkgs.config.permittedInsecurePackages = [ ];

  nixpkgs.config.chromium.commandLineArgs = "--gtk-version=4";

  programs.steam = {
    enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      # enable = true; # Don't enable unless you want docker as root
      daemon.settings = {
        dns = [
          "9.9.9.9"
          "8.8.8.8"
        ];
      };
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
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
      stylix.targets.helix.enable = false;
    }
  ];

  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    # polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/one-light.yaml";

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    fonts = {
      sizes = {
        terminal = 14; # default 12
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

  hardware.bluetooth.enable = true;

  nix.settings = {
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    substituters = [
      "https://cache.iog.io"
    ];
  };
}
