# Language, locale and time. US English UI with Korean regional formats.
{
  flake.modules.nixos.locale = {
    services.automatic-timezoned.enable = true;

    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "ko_KR.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
      ];
      extraLocaleSettings = {
        LC_ADDRESS = "ko_KR.UTF-8";
        LC_IDENTIFICATION = "ko_KR.UTF-8";
        LC_MEASUREMENT = "ko_KR.UTF-8";
        LC_MONETARY = "ko_KR.UTF-8";
        LC_NAME = "ko_KR.UTF-8";
        LC_NUMERIC = "ko_KR.UTF-8";
        LC_PAPER = "ko_KR.UTF-8";
        LC_TELEPHONE = "ko_KR.UTF-8";
        LC_TIME = "ko_KR.UTF-8";
        LC_COLLATE = "ko_KR.UTF-8";
      };
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
