{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./helix.nix
  ];

  home = {
    packages = with pkgs; [
      sd
      lazygit
      tokei
      rustup
      lldb
      gh
      fd
      jq
      neovim
      yt-dlp
      cargo-watch
      cargo-make
      cargo-outdated
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
      cargo-generate
      nasm
      psmisc
      tcpdump
      dig
      entr
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
        name = "JetBrainsMono Nerd Font Mono";
        size = 11;
      };
      theme = "Atom One Light";
      settings = {
        confirm_os_window_close = 0; # Disable
        macos_option_as_alt = true;
      };
    };
    zathura.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zellij = {
      enable = true;
      settings = {
        simplified_ui = false;
        pane_frames = false;
        theme = "solarized-light";
        themes.solarized-light = {
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
