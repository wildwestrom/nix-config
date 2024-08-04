# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  lib,
  font,
  dark_mode,
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

  # nix.nixPath = [ "nixos-cofnig=/home/${username}/${config-dir}" ];

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ amdvlk ];
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  hardware.opengl.driSupport32Bit = true;
  hardware.keyboard.zsa.enable = true;

  programs.nix-ld.enable = true;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.polkit.enable = true;
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
    # nushell
    brightnessctl
    usbutils
    dmidecode
    libnotify
    podman-compose
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

  services.resolved.enable = true;
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
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    (nerdfonts.override { fonts = [ font.monospace ]; })
  ];

  services.udev.packages = [ pkgs.android-udev-rules ];

  programs.fish.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "main user";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
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
      font.monospace = "${font.monospace} Nerd Font Mono";
      font.default = font.default;
      dark_mode = dark_mode;
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
      "steam-original"
      "steam-run"
      "minecraft-launcher"
      "libsciter"
      "surrealdb"
      "discord"
      "vintagestory"
    ];

  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

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
      enable = true;
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
