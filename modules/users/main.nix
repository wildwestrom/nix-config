# The primary user account and the home-manager glue for it. Group membership
# for a given subsystem lives with that subsystem (audio.nix adds "audio",
# libvirt.nix adds "libvirtd", ...), so this file only knows who the user is.
{ user, ... }:
{
  flake.modules.nixos.user-main =
    { pkgs, ... }:
    {
      users.users.${user.name} = {
        isNormalUser = true;
        description = user.fullName;
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
      };
      users.defaultUserShell = pkgs.fish;

      # ~/.local/bin on PATH
      environment.localBinInPath = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };

  flake.modules.homeManager.user-main =
    { config, ... }:
    {
      home = {
        username = user.name;
        homeDirectory = "/home/${user.name}";
        stateVersion = "25.05";
        enableNixpkgsReleaseCheck = true;
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = false;
        # HM 26.05 flipped this default to false; adopted explicitly. XDG_*_DIR
        # env vars are no longer exported -- read ~/.config/user-dirs.dirs or run
        # `xdg-user-dir` instead.
        setSessionVariables = false;
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
    };
}
