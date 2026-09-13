# MATLAB runs inside a Debian distrobox; the URL handlers point at the desktop
# entries it exports.
{
  flake.modules.homeManager.matlab = {
    programs.distrobox.containers.matlab = {
      entry = true;
      image = "debian:13";
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/mw-matlab" = "mw-matlab.desktop";
      "x-scheme-handler/mw-simulink" = "mw-simulink.desktop";
      "x-scheme-handler/mw-matlabconnector" = "mw-matlabconnector.desktop";
    };
  };
}
