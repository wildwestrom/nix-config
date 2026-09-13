# Programming toolchains and the per-language config files that go with them.
# Language servers are in helix.nix.
{
  flake.modules.nixos.languages = {
    # Run unpatched dynamic binaries (downloaded toolchains, rustup targets...).
    programs.nix-ld.enable = true;
  };

  flake.modules.homeManager.languages =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        # Nix
        niv
        nix-prefetch
        nix-prefetch-git
        nix-prefetch-github

        # Rust
        rustup
        bacon
        cargo-shear
        cargo-info
        rusty-man

        # everything else
        luarocks
        ghostscript
        racket
        guile
        guile-json
        sbcl
        hyperfine
        tree-sitter
        nodejs
        python3
        uv
        nasm
        lldb
        gdb
        elan
        octaveFull

        # database tools
        sqlitebrowser
        # surrealdb
        # surrealist
        # pgadmin

        # typst
        unstable.typst
        unstable.typstyle
        unstable.tinymist
      ];

      programs.direnv = {
        enable = true;
        # enableFishIntegration = true; # already enabled by default
        nix-direnv.enable = true;
      };

      # Sweep away .direnv caches for projects untouched for 90+ days. Removing
      # the dir drops nix-direnv's GC roots, so the weekly system `nix.gc` can
      # then reclaim the pinned closures. Re-entering a project rebuilds its cache.
      systemd.user.services.prune-stale-direnv = {
        Unit.Description = "Prune stale .direnv caches (90+ days untouched)";
        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "prune-stale-direnv" ''
            ${pkgs.findutils}/bin/find ${config.home.homeDirectory} \
              -maxdepth 6 -type d -name .direnv -mtime +90 -prune \
              -exec ${pkgs.coreutils}/bin/rm -rf {} +
          '';
        };
      };
      systemd.user.timers.prune-stale-direnv = {
        Unit.Description = "Weekly prune of stale .direnv caches";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
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
          "*.tex" = {
            max_line_length = 80;
          };
          "*.lean" = {
            indent_style = "space";
            indent_size = 2;
          };
        };
      };

      xdg.configFile = {
        "bacon/prefs.toml".source = ./_bacon-prefs.toml;
        "rustfmt/rustfmt.toml".text = ''
          hard_tabs = true
          tab_spaces = 4
        '';
      };
    };
}
