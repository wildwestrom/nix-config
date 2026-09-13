# Emacs as a system daemon (Doom lives in ~/.emacs.d, hence the sessionPath).
{
  flake.modules.nixos.emacs =
    { pkgs, ... }:
    {
      services.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
      };
      environment.systemPackages = with pkgs; [
        emacs-pgtk
        git
        ripgrep
        fd
      ];
    };

  flake.modules.homeManager.emacs = {
    home.sessionPath = [ "$HOME/.emacs.d/bin" ];
  };
}
