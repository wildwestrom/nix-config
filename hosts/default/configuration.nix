# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  font,
  ...
}: let
  username = "main";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  hardware.opengl.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Required for anything gtk related
  programs.dconf.enable = true;

  # "Experimental Features"
  # But I'm enabling them because I want to test them.
  nix.settings.experimental-features = ["nix-command" "flakes"];

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
    layout = "us";
    xkbVariant = "";
  };

  services.printing.enable = true;

  security.pam.services.swaylock = {};

  # Required for pinentry-gnome
  services.dbus = {
    enable = true;
    # packages = [ pkgs.gcr ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "main";
  # environment.etc."greetd/environments".text = ''
  #   sway
  #   fish
  # '';
  # services.greetd = let
  #   swayConfig = pkgs.writeText "greetd-sway-config" ''
  #     # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
  #     exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
  #     bindsym Mod4+shift+e exec swaynag \
  #       -t warning \
  #       -m 'What do you want to do?' \
  #       -b 'Poweroff' 'systemctl poweroff' \
  #       -b 'Reboot' 'systemctl reboot'
  #   '';
  # in {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
  #     };
  #   };
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    wget
    fish
    brightnessctl
    usbutils
    dmidecode
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
    (nerdfonts.override {fonts = [font.monospace];})
  ];

  programs.fish.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "main user";
    extraGroups = ["wheel" "video" "audio" "networkmanager"];
    shell = pkgs.fish;
  };

  # TODO: Reorganize the stuff needed for Wayland
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 30;
            chooser_type = "";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
        };
      };
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs username;
      font.monospace = "${font.monospace} Nerd Font Mono";
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${username} = import ./home.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
  };
}
