{
  pkgs,
  config,
  font,
  ...
}: {
  imports = [
    ./helix.nix
  ];

  home = {
    packages = with pkgs; [
      nmap
      sd
      lazygit
      tokei
      rustup
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
      pandoc
      python311
      watch
      act
      ffmpeg
      nodePackages_latest.markdownlint-cli
      typst
      typst-fmt
      typst-lsp
      pkg-config
      cargo-watch
      cargo-make
      cargo-outdated
      cargo-generate
      cargo-udeps
      cargo-modules
      cargo-leptos
      cargo-tauri
      leptosfmt
      sea-orm-cli
      nasm
      psmisc
      tcpdump
      dig
      entr
      sqlitebrowser
      pgadmin
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
      vesktop
      qgis
      minecraft
      prismlauncher
      rustdesk
      osmctools
      jetbrains.idea-community
      racket
      surrealdb
      surrealist
    ];
    sessionPath = ["$HOME/.local/bin" "/usr/local/bin" "/run/current-system/sw/bin"];
    sessionVariables = let
      hx_bin = config.programs.helix.package;
    in {
      CLICOLOR = 1;
      EDITOR = "${hx_bin}/bin/hx";
    };
    shellAliases = {
      switch-yubikey = "gpg-connect-agent 'scd serialno' 'learn --force' /bye";
      v = "$EDITOR";
      cp = "cp -riv";
      mv = "mv -iv";
      ln = "ln -iv";
      rm = "rm -riv";
      trash = "trash -v";
      mkdir = "mkdir -pv";
      chmod = "chmod -v";
      chown = "chown -v";
      ls = "eza";
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
      nixconf = "$EDITOR ~/nix-config";
      su = "su -s ${pkgs.fish}/bin/fish";
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
    lazygit = {enable = true;};
    bat = {
      enable = true;
      config = {
        theme = "Monokai Extended Light";
      };
      extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
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
        pull = {ff = "only";};
        init.defaultBranch = "main";
      };
    };
    eza = {
      enable = true;
      extraOptions = ["--grid" "--group-directories-first"];
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        fish_vi_key_bindings # use vi bindings
      '';
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
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
      # shellIntegration.enableFishIntegration = true;
      font = {
        name = font.monospace;
        size = 11;
      };
      theme = "Atom One Light";
      # theme = "One Dark";
      settings = {
        confirm_os_window_close = 0; # Disable
        macos_option_as_alt = true;
      };
    };
    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require "wezterm"
        local config = {
          font = wezterm.font "${font.monospace}",
          enable_tab_bar = false,
          color_scheme = "One Light (Gogh)",
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
            fg = [101 123 131];
            bg = [253 246 227];
            black = [7 54 66];
            red = [220 50 47];
            green = [133 153 0];
            yellow = [181 137 0];
            blue = [38 139 210];
            magenta = [211 54 130];
            cyan = [42 161 152];
            white = [238 232 213];
            orange = [203 75 22];
          };
        };
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        vadimcn.vscode-lldb
        rust-lang.rust-analyzer
      ];
      userSettings = {
        "workbench.colorTheme" = "Default Light Modern";
        "files.autoSave" = "afterDelay";
        "editor.fontFamily" = "${font.monospace}, 'monospace', monospace";
        "terminal.integrated.fontFamily" = "${font.monospace}, 'monospace', monospace";
      };
    };
    atuin = {
      enable = true;
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
      "*.md" = {trim_trailing_whitespace = false;};
      "README*.md, *.tex" = {max_line_length = 80;};
    };
  };
}
