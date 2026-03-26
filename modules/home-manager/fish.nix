{ ... }:
{
  home = {
    shellAliases = {
      ls = "eza";
    };
  };
  programs = {
    eza = {
      enable = true;
      extraOptions = [
        "--grid"
        "--group-directories-first"
      ];
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings
        bind -M insert \cf accept-autosuggestion
        bind -M insert \t '
          if commandline --search-mode
            commandline -f cancel
          else if commandline --paging-mode
            commandline -f complete
          else
            set -l sug (commandline --showing-suggestion)
            if test -n "$sug"
              commandline -f accept-autosuggestion
            else
              commandline -f complete
            end
          end'
      '';
      # binds = {
      # };
      functions = {
        mkcd = {
          body = ''
            mkdir $argv[1]
            cd $argv[1]
          '';
        };
      };
    };
  };
}
