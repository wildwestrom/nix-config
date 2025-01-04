{
  pkgs,
  ...
}:
let
in
{
  home =
    {
    };

  programs.emacs = {
    enable = false;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [ epkgs.vterm ];
  };
}
