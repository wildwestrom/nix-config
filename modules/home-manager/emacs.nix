{
  pkgs,
  ...
}:
let
in
{
  home = {
    packages = with pkgs; [ libvterm ];
  };
}
