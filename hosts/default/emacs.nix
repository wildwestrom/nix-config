{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    emacs-pgtk
    git
    ripgrep
    fd
  ];
  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
}
