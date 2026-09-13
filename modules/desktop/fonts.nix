{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.fontDir.enable = true;
      fonts.packages = with pkgs; [
        sarasa-gothic
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
        jetbrains-mono
        newcomputermodern
        font-awesome
        atkinson-hyperlegible-mono
        atkinson-hyperlegible-next
        source-sans-pro
        source-serif-pro
        source-han-sans
        source-han-serif
        monocraft
      ];

      fonts.fontconfig = {
        antialias = true;
        hinting.enable = true;
        hinting.autohint = true;
        subpixel.lcdfilter = "default";
        subpixel.rgba = "rgb";
      };
    };

  flake.modules.homeManager.fonts =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnome-font-viewer
        fontforge-gtk
      ];
      xdg.mimeApps.defaultApplications."font/otf" = "org.gnome.font-viewer.desktop";
    };
}
