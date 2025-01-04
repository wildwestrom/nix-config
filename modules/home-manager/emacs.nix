{
  pkgs,
  ...
}:
let
in
{
  home = {
    packages = with pkgs; [
      cmake
      gnumake
      libvterm
    ];
  };
}
