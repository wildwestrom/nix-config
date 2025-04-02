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
    package = pkgs.emacs30-pgtk;
    extraPackages = epkgs: [ epkgs.vterm ];
  };
}
