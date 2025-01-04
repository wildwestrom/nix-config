{
  pkgs,
  ...
}:
let
in
{
  home = {
    packages = with pkgs; [ emacsPackages.vterm ];
  };
}
