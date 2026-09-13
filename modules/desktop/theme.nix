# Stylix drives colours/fonts/cursor for everything it has a target for. Fonts
# themselves are installed in fonts.nix.
{ inputs, ... }:
{
  flake.modules.nixos.theme =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        # image = ./wallpaper.jpg;
        # polarity = "dark";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
        polarity = "light";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/one-light.yaml";

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
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
      };

      environment.systemPackages = [ pkgs.adwaita-icon-theme ];
    };

  flake.modules.homeManager.theme = {
    stylix.targets = {
      helix.enable = false; # helix.nix sets its own theme
      fcitx5.enable = false;
      # foot.enable = false;
      # gnome.enable = false;
      # qt.enable = false;
    };

    gtk.enable = true;
    qt.enable = true;

    # Pin the icon theme. Stylix doesn't manage this key, so it was left at the
    # schema default.
    dconf.settings."org/gnome/desktop/interface".icon-theme = "Adwaita";
  };
}
