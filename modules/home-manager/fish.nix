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
