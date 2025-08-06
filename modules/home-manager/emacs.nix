{
  pkgs,
  ...
}:
let
in
{
  home = {
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.vterm ];
  };
}
