{
  pkgs,
  config,
  ...
}:
let
  hx_bin = config.programs.helix.package;
  editor = "${hx_bin}/bin/hx";
  terminal = "${pkgs.kitty}/bin/kitty";
in
{
  imports = [
    ./helix.nix
    # ./nushell.nix
    ./fish.nix
  ];

  home = {
    packages = with pkgs; [
      nmap
      sd
      lazygit
      gitui
      fossil
      tokei
      lldb
      gdb
      gh
      fd
      du-dust
      jq
      neovim
      yt-dlp
      nodejs
      bottom
      wget
      tree-sitter
      luarocks
      tree
      ghostscript
      rename
      trashy
      pandoc
      python311
      watch
      act
      ffmpeg
      nodePackages_latest.markdownlint-cli
      typst
      typst-fmt
      typst-lsp
      nasm
      psmisc
      tcpdump
      dig
      watchexec
      entr
      rargs
      sqlitebrowser
      pgadmin
      python311Packages.python-dotenv
      libreoffice
      unzip
      zip
      anki
      strawberry
      stdenv.cc
      libwebp
      signal-desktop
      thunderbird
      obsidian
      qgis
      prismlauncher
      rustdesk
      osmctools
      racket
      surrealdb
      surrealist
      hyperfine
      brave
      jujutsu
      inkscape
      docker-compose
      bc
      android-file-transfer
      mpv
      imagemagick
      sccache
      qrcode
      ansifilter
      vesktop
      protonmail-bridge
      musescore
      wormhole-rs
      graphviz
      bacon
      rustup
      transmission_4-gtk
      vlc
      freecad
      bitwarden-desktop
      obs-studio
      tldr
    ];
    sessionPath = [
      "$HOME/.local/bin"
      "/usr/local/bin"
      "/run/current-system/sw/bin"
      "$HOME/.cargo/bin"
    ];
    sessionVariables = {
      CLICOLOR = "1";
      EDITOR = editor;
    };
    shellAliases = {
      switch-yubikey = "gpg-connect-agent 'scd serialno' 'learn --force' /bye";
      v = editor;
      cp = "cp -rv";
      mv = "mv -iv";
      ln = "ln -iv";
      rm = "rm -riv";
      mkdir = "mkdir -pv";
      chmod = "chmod -v";
      chown = "chown -v";
      ll = "ls -la";
      la = "ls -a";
      lt = "ls -a --tree";
      "l." = "ls -d .*";
      df = "df -h";
      fd = "fd --hidden";
      rg = "rg -.";
      ag = "ag -a";
      cat = "bat";
      less = "bat --style=plain --paging=always";
      top = "btm --color=default";
      htop = "btm --color=default";
      grep = "rg";
      cloc = "tokei";
      nixconf = "~/nix-config/nixos-rebuild.sh";
      nixrebuildlog = "cat ~/nix-config/nixos-switch.log";
      su = "su -s $SHELL";
      proc = "ps u | head -n1 && ps aux | rg -v '\\srg\\s-\\.' | rg";
      mpa = "mpv --no-video";
      ytdl = "yt-dlp -P ~/Downloads";
      gcd1 = "git clone --depth 1";
      watch = "watch -c";
      lazyconf = "lazygit -p ~/nix-config";
      newterm = "${terminal} . & disown";
    };
    enableNixpkgsReleaseCheck = true;
  };
  programs = {
    gpg = {
      enable = true;
    };
    lazygit = {
      enable = true;
    };
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
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      delta = {
        enable = true;
        options = {
          light = true;
        };
      };
      extraConfig = {
        user = {
          name = "Christian Westrom";
          email = "c.westrom@westrom.xyz";
          # signingKey = config.gpgKey;
        };
        github = {
          user = "wildwestrom";
        };
        gitlab = {
          user = "wildwestrom";
        };
        commit = {
          # gpgSign = true;
        };
        pull = {
          ff = "only";
        };
        init.defaultBranch = "main";
      };
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = false;
    };
    zoxide = {
      enable = true;
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      settings = {
        confirm_os_window_close = 0; # Disable
        macos_option_as_alt = true;
      };
    };
    alacritty = {
      enable = true;
    };
    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require "wezterm"
        local config = {
          enable_tab_bar = false,
          window_close_confirmation = "NeverPrompt",
          default_cursor_style = "BlinkingBar",
          cursor_blink_ease_in = "Constant",
          cursor_blink_ease_out = "Constant",
          cursor_blink_rate = 500,
        }
        return config
      '';
    };
    zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
    };
    direnv = {
      enable = true;
      # enableFishIntegration = true; # already enabled by default
      nix-direnv.enable = true;
    };
    zellij = {
      enable = true;
      # enableFishIntegration = true;
      settings = {
        simplified_ui = false;
        pane_frames = false;
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        vadimcn.vscode-lldb
        rust-lang.rust-analyzer
        redhat.java
        vscjava.vscode-maven
      ];
      userSettings = {
        "files.autoSave" = "afterDelay";
        "window.zoomLevel" = 1;
      };
    };
    atuin = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        filter_mode = "directory";
      };
    };
  };
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        end_of_line = "lf";
        charset = "utf-8";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "tab";
        tab_width = 2;
      };
      "*.{fish,py}" = {
        indent_style = "space";
        indent_size = 4;
      };
      "*.yml" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.{el,clj,cljs,cljc,lisp,cl,scm,fnl,hy,rkt}" = {
        indent_style = "space";
      };
      "*.md" = {
        trim_trailing_whitespace = false;
      };
      "README*.md, *.tex" = {
        max_line_length = 80;
      };
    };
  };
  xdg.configFile = {
    "bacon" = {
      target = "prefs.toml";
      source = ./bacon-config.toml;
    };
    "rustfmt" = {
      target = "rustfmt/rustfmt.toml";
      text = ''
        hard_tabs = true
        tab_spaces = 4
      '';
    };
  };
  home.file = {
    ".cargo" = {
      target = ".cargo/config.toml";
      text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      '';
    };
  };
}
