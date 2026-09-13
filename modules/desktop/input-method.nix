# fcitx5 for Korean (hangul), Japanese (mozc) and Chinese (rime) input.
{
  flake.modules.homeManager.input-method =
    { pkgs, ... }:
    {
      i18n.inputMethod = {
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

      # Declarative profile, currently left to fcitx5's own state:
      # xdg.configFile."fcitx5/profile".source = ./_fcitx5-profile;
    };
}
