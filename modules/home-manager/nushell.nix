{
  config,
  #dark_mode,
  ...
}:
let
  hx_bin = config.programs.helix.package;
  editor = "${hx_bin}/bin/hx";
in
{
  programs = {
    nushell = {
      enable = true;
      configFile.text = ''
        let-env config = {
          show_banner: false
            edit_mode: vi
        }
      '';
      environmentVariables = {
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
        mkdir = "mkdir -v";
        chmod = "chmod -v";
        chown = "chown -v";
        ll = "ls -la";
        la = "ls -a";
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
        su = "su -s $env.SHELL";
        proc = "ps";
        mpa = "mpv --no-video";
        ytdl = "yt-dlp -P ~/Downloads";
        gcd1 = "git clone --depth 1";
        lazyconf = "lazygit -p ~/nix-config";
      };
    };
  };
}
