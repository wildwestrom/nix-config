{
  pkgs,
  config,
  unstable,
  unstable-unfree,
  #username,
  terminal,
  ...
}:
let
  hx_bin = config.programs.helix.package;
  editor = "${hx_bin}/bin/hx";
in
{
  imports = [
    ./helix.nix
    ./fish.nix
    ./gaming.nix
  ];

  home = {
    packages = with pkgs; [
      # Nix utils
      niv
      nix-prefetch
      nix-prefetch-git
      nix-prefetch-github

      # Version control
      lazygit
      gitui
      gh
      jujutsu
      fossil
      act
      mercurialFull

      # CLI Tools
      sd
      tokei
      bc
      fd
      dua
      jq
      bottom
      tree
      rename
      trashy
      pandoc
      nodePackages_latest.markdownlint-cli
      psmisc
      watch
      watchexec
      entr
      # TODO: Find a replacement
      # rargs
      unzip
      zip
      qgis
      file
      pv
      xxd

      # network
      tcpdump
      nmap
      dig
      ueberzugpp
      curl
      wget
      unixtools.netstat
      unixtools.route
      unixtools.net-tools

      bottles
      # wineWow64Packages.waylandFull
      winePackages.waylandFull
      winetricks

      transmission_4-gtk
      bitwarden-desktop
      tldr
      picard
      qrencode
      qrcode
      prismlauncher
      anki
      libreoffice
      (brave.override {
        commandLineArgs = [
          "--enable-wayland-ime"
          "--store-password=basic"
        ];
      })
      sccache
      ansifilter
      wormhole-rs
      graphviz
      neofetch
      filezilla

      # android
      android-file-transfer
      android-tools
      scrcpy

      # programming
      luarocks
      ghostscript
      racket
      guile
      guile-json
      sbcl
      docker-compose
      hyperfine
      tree-sitter
      nodejs
      python3
      uv
      nasm
      lldb
      gdb
      elan

      # typst
      unstable.typst
      unstable.typstyle
      unstable.tinymist

      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ko-kr

      # database tools
      # surrealdb
      # surrealist
      sqlitebrowser
      # pgadmin

      # creation
      inkscape
      imagemagick
      unstable.musescore
      blender
      obs-studio
      freecad
      gimp3

      # media
      libwebp
      vlc
      mpv
      strawberry
      yt-dlp
      ffmpeg
      guitarix
      gxplugins-lv2
      ueberzugpp
      audacity

      # cargo plugins
      bacon
      cargo-shear
      cargo-info
      rusty-man

      # comms
      protonmail-bridge
      unstable.signal-desktop
      vesktop
      telegram-desktop
      thunderbird

      # editors
      obsidian
      unstable.zed-editor
      # jetbrains.rust-rover
      neovim
      vscodium
      unstable-unfree.code-cursor
      unstable-unfree.claude-code
    ];
    sessionPath = [
      "$HOME/.emacs.d/bin"
    ];
    sessionVariables = {
      CLICOLOR = "1";
      EDITOR = editor;
    };
    shellAliases = {
      switch-yubikey = "gpg-connect-agent 'scd serialno' 'learn --force' /bye";
      v = editor;
      cd = "z";
      cp = "cp -rv";
      mv = "mv -iv";
      ln = "ln -iv";
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
      lazyconf = "lazygit -p ~/nix-config";
      nixbuildlog = "tail -f ~/nix-config/nixos-switch.log";
      su = "su -s $SHELL";
      proc = "ps u | head -n1 && ps aux | rg -v '\\srg\\s-\\.' | rg";
      mpa = "mpv --no-video";
      gcd1 = "git clone --depth 1";
      watch = "watch -c";
      newterm = "${terminal.bin} . & disown";
      nwg-displays = "nwg-displays -n 10";
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
      package = pkgs.gitFull;
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
    # LLMs just do not know how to deal with this prompt
    # starship = {
    #   enable = true;
    #   enableFishIntegration = true;
    #   enableBashIntegration = false;
    #   enableNushellIntegration = false;
    # };
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
    # kitty = {
    #   enable = true;
    #   shellIntegration.enableFishIntegration = true;
    #   settings = {
    #     confirm_os_window_close = 0; # Disable
    #     macos_option_as_alt = true;
    #   };
    # };
    alacritty = {
      enable = true;
      settings = {
        keyboard.bindings = [
          {
            key = "N";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
        ];
      };
    };
    # foot = {
    #   enable = true;
    #   server.enable = true;
    #   settings = {
    #     main = {
    #       gamma-correct-blending = true;
    #       # term = "xterm-256color";
    #       # dpi-aware = "yes"; # TODO: Find out why this setting conflicts
    #       shell = "${pkgs.fish}/bin/fish";
    #     };
    #     scrollback = {
    #       lines = 65535;
    #     };
    #   };
    # };
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    # wezterm = {
    #   enable = true;
    #   extraConfig = ''
    #     local wezterm = require "wezterm"
    #     local config = {
    #       enable_tab_bar = false,
    #       window_close_confirmation = "NeverPrompt",
    #       default_cursor_style = "BlinkingBar",
    #       cursor_blink_ease_in = "Constant",
    #       cursor_blink_ease_out = "Constant",
    #       cursor_blink_rate = 500,
    #     }
    #     return config
    #   '';
    # };
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
    # zellij = {
    #   enable = true;
    #   # enableFishIntegration = true;
    #   settings = {
    #     simplified_ui = false;
    #     pane_frames = false;
    #   };
    # };
    # vscode = {
    #   enable = true;
    #   package = pkgs.vscodium;
    #   enableExtensionUpdateCheck = false;
    #   enableUpdateCheck = false;
    #   mutableExtensionsDir = true;
    #   extensions =
    #     with pkgs.vscode-extensions;
    #     [
    #       vadimcn.vscode-lldb
    #       rust-lang.rust-analyzer
    #       redhat.java
    #       vscjava.vscode-maven
    #       continue.continue
    #       mkhl.direnv
    #       esbenp.prettier-vscode
    #     ]
    #     ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #       {
    #         name = "hblang";
    #         publisher = "koniifer";
    #         version = "0.2.8";
    #         sha256 = "sha256-J9cHT0ryOXjeITIhCoeP+5ZT5EwdJNh10i/UT8zGSFU=";
    #       }
    #       {
    #         name = "slint";
    #         publisher = "slint";
    #         version = "1.11.0";
    #         sha256 = "sha256-8NPeBrmsFom73FxIVKG1swGszTiST394J4+qZvqpUPs=";
    #       }
    #     ];
    #   userSettings = {
    #     "files.autoSave" = "afterDelay";
    #     "window.zoomLevel" = 1;
    #     "editor.inlineSuggest.suppressSuggestions" = true;
    #     "semanticdiff.defaultDiffViewer" = true;
    #     "[json]" = {
    #       "editor.defaultFormatter" = "esbenp.prettier-vscode";
    #     };
    #   };
    # };
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
    # "fcitx5" = {
    #   target = "fcitx5/profile";
    #   source = ./fcitx5-config;
    # };
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
