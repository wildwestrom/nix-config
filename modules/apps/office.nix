# Documents: office suite, PDF readers, spelling, flashcards.
{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        libreoffice
        evince
        kdePackages.okular
        sioyek
        anki
        hunspell
        hunspellDicts.en-us-large
        hunspellDicts.ko-kr
      ];

      xdg.mimeApps.defaultApplications."application/pdf" = "sioyek.desktop";

      # zathura was the previous PDF reader: options.selection-clipboard = "clipboard";
    };
}
