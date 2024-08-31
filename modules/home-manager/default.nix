{
  pkgs,
  config,
  font,
  dark_mode,
  ...
}:
let
  hx_bin = config.programs.helix.package;
  editor = "${hx_bin}/bin/hx";
  font_size = 14;
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
      minecraft
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
      squeak
      android-file-transfer
      mpv
      imagemagick
      bacon
      cargo
      sccache
      qrcode
      ansifilter
      vesktop
      protonmail-bridge
      musescore
    ];
    sessionPath = [
      "$HOME/.local/bin"
      "/usr/local/bin"
      "/run/current-system/sw/bin"
    ];
    sessionVariables = {
      CLICOLOR = "1";
      EDITOR = editor;
    };
    shellAliases = {
      switch-yubikey = "gpg-connect-agent 'scd serialno' 'learn --force' /bye";
      v = editor;
      cp = "cp -riv";
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
      config = {
        theme = if dark_mode then "OneHalfDark" else "Monokai Extended Light";
      };
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
      font = {
        name = font.monospace;
        size = font_size;
      };
      theme = if dark_mode then "One Dark" else "Atom One Light";
      settings = {
        confirm_os_window_close = 0; # Disable
        macos_option_as_alt = true;
      };
    };
    alacritty = {
      enable = true;
      settings = {
        font = {
          size = font_size;
          normal = {
            family = font.monospace;
          };
        };
        colors =
          if dark_mode then
            {
              primary = {
                background = "#282c34";
                foreground = "#abb2bf";
              };
              normal = {
                black = "#1e2127";
                red = "#e06c75";
                green = "#98c379";
                yellow = "#d19a66";
                blue = "#61afef";
                magenta = "#c678dd";
                cyan = "#56b6c2";
                white = "#abb2bf";
              };
              bright = {
                black = "#5c6370";
                red = "#e06c75";
                green = "#98c379";
                yellow = "#d19a66";
                blue = "#61afef";
                magenta = "#c678dd";
                cyan = "#56b6c2";
                white = "#ffffff";
              };
            }
          else
            {
              primary = {
                background = "#f8f8f8";
                foreground = "#2a2b33";
              };
              normal = {
                black = "#000000";
                red = "#de3d35";
                green = "#3e953a";
                yellow = "#d2b67b";
                blue = "#2f5af3";
                magenta = "#a00095";
                cyan = "#3e953a";
                white = "#bbbbbb";
              };
              bright = {
                black = "#000000";
                red = "#de3d35";
                green = "#3e953a";
                yellow = "#d2b67b";
                blue = "#2f5af3";
                magenta = "#a00095";
                cyan = "#3e953a";
                white = "#ffffff";
              };
            };
        window = {
          decorations_theme_variant = if dark_mode then "Dark" else "Light";
        };
      };
    };
    wezterm =
      let
        theme = if dark_mode then "OneDark (base16)" else "One Light (Gogh)";
      in
      {
        enable = true;
        extraConfig = ''
          local wezterm = require "wezterm"
          local config = {
            font = wezterm.font "${font.monospace}",
            enable_tab_bar = false,
            color_scheme = "${theme}",
            window_close_confirmation = "NeverPrompt",
            default_cursor_style = "BlinkingBar",
            cursor_blink_ease_in = "Constant",
            cursor_blink_ease_out = "Constant",
            cursor_blink_rate = 500,
          }
          return config
        '';
        # colorSchemes = ""; # TOML code
      };
    zathura.enable = true;
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
        theme = "default";
        themes = {
          default = {
            fg = 7;
            bg = 0;
            black = 0;
            red = 1;
            green = 2;
            yellow = 3;
            blue = 4;
            magenta = 5;
            cyan = 6;
            white = 7;
            orange = 16;
            gray = 18;
          };
          solarized-light = {
            fg = [
              101
              123
              131
            ];
            bg = [
              253
              246
              227
            ];
            black = [
              7
              54
              66
            ];
            red = [
              220
              50
              47
            ];
            green = [
              133
              153
              0
            ];
            yellow = [
              181
              137
              0
            ];
            blue = [
              38
              139
              210
            ];
            magenta = [
              211
              54
              130
            ];
            cyan = [
              42
              161
              152
            ];
            white = [
              238
              232
              213
            ];
            orange = [
              203
              75
              22
            ];
          };
        };
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
      userSettings =
        let
          theme = if dark_mode then "Visual Studio Dark" else "Visual Studio Light";
        in
        {
          "workbench.colorTheme" = theme;
          "files.autoSave" = "afterDelay";
          "editor.fontFamily" = "${font.monospace}, 'monospace', monospace";
          "terminal.integrated.fontFamily" = "${font.monospace}, 'monospace', monospace";
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
  };
  home.file.".cargo" = {
    target = ".cargo/config.toml";
    text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}"'';
  };
}
