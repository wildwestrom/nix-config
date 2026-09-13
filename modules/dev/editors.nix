# Every editor that isn't helix or emacs.
{
  flake.modules.homeManager.editors =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gedit # because sometimes you need something that doesn't automatically correct whitespace
        obsidian
        unstable.zed-editor
        # jetbrains.rust-rover
        jetbrains.idea-oss
        neovim
        vscodium
      ];

      xdg.mimeApps.defaultApplications."x-scheme-handler/vscodium" = [
        "codium-url-handler.desktop"
        "codium.desktop"
      ];

      # Declarative VSCodium, last used with: vadimcn.vscode-lldb,
      # rust-lang.rust-analyzer, redhat.java, vscjava.vscode-maven,
      # continue.continue, mkhl.direnv, esbenp.prettier-vscode, plus koniifer.hblang
      # and slint.slint from the marketplace. Re-enable with programs.vscode if
      # the mutable extensions dir stops being enough.
    };
}
