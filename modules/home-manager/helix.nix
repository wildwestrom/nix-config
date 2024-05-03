{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      python3Packages.python-lsp-server
      alejandra
      nil
      vscode-langservers-extracted
      nodePackages_latest.typescript-language-server
      nodePackages_latest.svelte-language-server
      taplo
      jdt-language-server
      ccls
    ];
  };

  programs = {
    helix = {
      enable = true;
      settings = {
        theme = "onelight";
        # theme = "zed_onedark";
        editor = {
          terminal = {
            command = "kitty";
            # args = ""; # Maybe don't use this?
          };
          line-number = "relative";
          auto-format = true;
          true-color = true;
          color-modes = true;
          lsp.display-messages = true;
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
            "\"" = "\"";
            "'" = "'";
            "<" = ">";
            "`" = "`";
          };
          completion-trigger-len = 2;
          soft-wrap = {
            enable = true;
          };
        };
      };
      languages = {
        language = [
          {
            name = "rust";
            indent = {
              tab-width = 2;
              unit = "\t";
            };
            language-servers = [
              "rust-analyzer"
            ];
            # # See if the debug configuration is actually unnecessary
            # debugger = {
            #   command = "lldb-vscode";
            #   name = "lldb-vscode";
            #   port-arg = "--port {}";
            #   transport = "tcp";
            #   templates = [
            #     {
            #       name = "binary";
            #       request = "launch";
            #       completion = [
            #         {
            #           completion = "filename";
            #           name = "binary";
            #         }
            #       ];
            #       args = {
            #         program = "{0}";
            #         runInTerminal = true;
            #       };
            #     }
            #   ];
            # };
          }
          {
            name = "nix";
            file-types = ["nix"];
            roots = ["flake.lock"];
            indent = {
              tab-width = 2;
              unit = "\t";
            };
            formatter = {
              command = "alejandra";
              args = ["-"];
            };
            auto-format = true;
            language-servers = [
              "nil"
            ];
          }
          {
            name = "python";
            formatter = {
              command = "black";
              args = ["--quiet" "-"];
            };
          }
          {
            name = "typst";
            file-types = ["typ"];
            scope = "source.typst";
            injection-regex = "^typ(st)?$";
            roots = [];
            comment-token = "//";
            indent = {
              tab-width = 2;
              unit = "\t";
            };
            auto-pairs = {
              "(" = ")";
              "{" = "}";
              "[" = "]";
              "\"" = "\"";
              "`" = "`";
              "$" = "$";
            };
            text-width = 100;
            rulers = [100];
            soft-wrap.wrap-at-text-width = true;
            language-servers = [
              "typst-lsp"
            ];
            formatter = {
              command = "typst-fmt";
              args = ["--stdio"];
            };
            # # TODO: Fix grammar adding to helix config
            # # https://github.com/nix-community/home-manager/issues/2871
            # grammar = {
            #   name = "typst";
            #   source = {
            #     # git = "https://github.com/SeniorMars/tree-sitter-typst";
            #     # rev = "2e66ef4b798a26f0b82144143711f3f7a9e8ea35";
            #     git = "https://github.com/frozolotl/tree-sitter-typst";
            #     rev = "427ccd875e14b592f13c2fac866158afa04034cb";
            #   };
            # };
          }
        ];
        language-server = {
          nil = {
            command = "nil";
          };
          nixd = {
            command = "nixd";
          };
          rnix-lsp = {
            command = "rnix-lsp";
          };
          typst-lsp = {
            command = "typst-lsp";
          };
          jdtls = {
            command = "jdt-language-server";
          };
          rust-analyzer = {
            timeout = 60;
            check.command = "clippy";
            procMacro.ignored.leptos_macro = ["server"];
            rustfmt.overrideCommand = ["leptosfmt" "--stdin" "--rustfmt"];
            diagnostics.experimental.enable = true;
          };
          tailwindcss-ls = {
            config.userLanguages = {
              rust = "html";
              "*.rs" = "html";
            };
          };
        };
      };
    };
  };
}
