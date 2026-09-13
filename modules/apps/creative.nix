# Making things: vector/raster, 3D, CAD, music notation.
{
  flake.modules.homeManager.creative =
    { pkgs, ... }:
    let
      freecad-fhs = pkgs.buildFHSEnv {
        name = "freecad";
        targetPkgs =
          pkgs: with pkgs; [
            freecad
            python3
            python3Packages.pip
            python3Packages.pyproj
            git
          ];
        runScript = ''
          # Make nixpkgs Python packages visible to FreeCAD
          for _d in /usr/lib/python3.*/site-packages; do
            PYTHONPATH="''$PYTHONPATH:''$_d"
          done
          export PYTHONPATH
          exec freecad "$@"
        '';
      };
    in
    {
      home.packages = with pkgs; [
        inkscape
        gimp3
        blender
        freecad-fhs
        unstable.musescore
        graphviz
        qgis
      ];
    };
}
