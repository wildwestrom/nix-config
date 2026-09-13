# fish as the login shell, plus the aliases that apply to every shell.
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      # Needed system-side so fish is a valid login shell (/etc/shells) and
      # gets its vendor completions/conf.d.
      programs.fish.enable = true;
      environment.systemPackages = [ pkgs.fish ];
    };

  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.sessionVariables.CLICOLOR = "1";

      home.shellAliases = {
        switch-yubikey = "gpg-connect-agent 'scd serialno' 'learn --force' /bye";
        cd = "z";
        cp = "cp -rv";
        mv = "mv -iv";
        ln = "ln -iv";
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
        nixconf = "~/nix-config/nixos-rebuild.sh";
        lazyconf = "lazygit -p ~/nix-config";
        nixbuildlog = "tail -f ~/nix-config/nixos-switch.log";
        su = "su -s $SHELL";
        proc = "ps u | head -n1 && ps aux | rg -v '\\srg\\s-\\.' | rg";
        mpa = "mpv --no-video";
        gcd1 = "git clone --depth 1";
        watch = "watch -c";
        nwg-displays = "nwg-displays -n 10";
      };

      programs.eza = {
        enable = true;
        extraOptions = [
          "--grid"
          "--group-directories-first"
        ];
      };

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          fish_vi_key_bindings
          bind -M insert \cf accept-autosuggestion
          # API keys and other secrets live outside the repo; see README.
          test -f ~/.config/fish/secrets.fish; and source ~/.config/fish/secrets.fish
        '';
        shellAliases = {
          # fish-only: safeunzip is a fish function, so this can't live in
          # home.shellAliases (which applies to every shell).
          unzip = "safeunzip";
        };
        functions = {
          mkcd = {
            body = ''
              mkdir $argv[1]
              cd $argv[1]
            '';
          };
          safeunzip = {
            description = "unzip with zip-bomb and messy-archive checks";
            wraps = "unzip";
            # Every call to the real unzip goes through `command`, because
            # `unzip` is aliased to this function above and would otherwise
            # recurse into itself.
            body = ''
              set -l zipfile $argv[1]
              if test -z "$zipfile"; or not test -f "$zipfile"
                  echo "Usage: safeunzip <file.zip> [unzip options]" >&2
                  return 1
              end
              set -e argv[1]

              # --- bomb heuristics, from the `unzip -v` totals line ---
              set -l line (command unzip -v $zipfile 2>/dev/null | tail -n 1 | awk '{gsub("%","",$3); print $1"|"$3"|"$4}')
              set -l parts (string split '|' -- $line)
              set -l total_size $parts[1]
              set -l ratio $parts[2]
              set -l total_files $parts[3]

              set -l bomb_warn 0
              test "$total_size" -gt 1073741824 2>/dev/null; and set bomb_warn 1
              test "$ratio" -gt 98 2>/dev/null; and set bomb_warn 1
              test "$total_files" -gt 5000 2>/dev/null; and set bomb_warn 1

              if test $bomb_warn -eq 1
                  echo "⚠ $zipfile: $total_size bytes, $total_files files, $ratio% ratio — possible zip bomb."
                  read -P "Extract anyway? [y/N] " -l ans
                  if not string match -qi y -- $ans
                      return 1
                  end
              end

              # --- top-level layout check: does it spill loose items into cwd? ---
              set -l entries (command unzip -Z1 $zipfile 2>/dev/null)
              set -l tops
              for e in $entries
                  set -l top (string split -m1 / -- $e)[1]
                  contains -- $top $tops; or set -a tops $top
              end

              if test (count $tops) -gt 1
                  set -l destdir (basename $zipfile .zip)
                  echo "⚠ $zipfile has "(count $tops)" top-level items — it will spill into the current directory."
                  read -P "Extract into ./$destdir/ instead? [Y/n] " -l ans
                  if not string match -qi n -- $ans
                      mkdir -p $destdir
                      command unzip $zipfile -d $destdir $argv
                      return $status
                  end
              end

              command unzip $zipfile $argv
            '';
          };
        };
      };
    };
}
