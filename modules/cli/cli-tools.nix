# General-purpose command-line tools and their configuration.
{ inputs, ... }:
{
  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sd
        tokei
        bc
        fd
        jq
        tree
        rename
        trashy
        pandoc
        markdownlint-cli2
        psmisc
        watch
        watchexec
        entr
        # TODO: Find a replacement
        # rargs
        unzip
        zip
        file
        pv
        xxd
        ansifilter
        fastfetch
        qrencode
        qrcode
        wormhole-rs
        ueberzugpp
        babashka

        bottom

        # tsoding's file-based task tracker
        inputs.tatr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      programs = {
        bat = {
          enable = true;
          extraPackages = with pkgs.bat-extras; [
            batdiff
            batman
            batgrep
            batwatch
          ];
        };
        fzf = {
          enable = true;
          enableFishIntegration = true;
          changeDirWidgetCommand = "fd --type d";
          defaultCommand = "fd --type f";
          fileWidgetCommand = "fd --type f";
        };
        zoxide.enable = true;
        ripgrep = {
          enable = true;
          arguments = [
            "--hidden"
            "--glob=!.git/*"
            "--smart-case"
          ];
        };
        yazi = {
          enable = true;
          enableFishIntegration = true;
          # HM 26.05 renamed the default wrapper from `yy` to `y`; adopted explicitly.
          shellWrapperName = "y";
        };
        atuin = {
          enable = true;
          enableNushellIntegration = true;
          settings = {
            filter_mode = "directory";
            enter_accept = false;
            keymap_mode = "vim-insert";
            style = "compact";
            inline_height = 10;
          };
        };
        gpg.enable = true;
        # LLMs just do not know how to deal with this prompt
        # starship.enable = true;
      };
    };
}
