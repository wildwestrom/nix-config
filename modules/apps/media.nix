# Images, audio, video: viewers, players, and the tools that make them.
{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    let
      rotate = pkgs.writeShellApplication {
        name = "swayimg-rotate";
        runtimeInputs = [ pkgs.exiftool ];
        text = ''
          # usage: swayimg-rotate FILE cw|ccw
          # Rotate by cycling the EXIF Orientation tag (1-8). Lossless: only
          # metadata changes, the encoded pixels are left untouched.
          img=$1
          dir=''${2:-cw}
          cur=$(exiftool -n -s3 -Orientation "$img" 2>/dev/null || true)
          case "$cur" in 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8) ;; *) cur=1 ;; esac
          case "$dir" in
            cw)
              case "$cur" in
                1) new=6 ;; 2) new=7 ;; 3) new=8 ;; 4) new=5 ;;
                5) new=2 ;; 6) new=3 ;; 7) new=4 ;; 8) new=1 ;;
              esac
              ;;
            ccw)
              case "$cur" in
                1) new=8 ;; 2) new=5 ;; 3) new=6 ;; 4) new=7 ;;
                5) new=4 ;; 6) new=1 ;; 7) new=2 ;; 8) new=3 ;;
              esac
              ;;
            *)
              echo "usage: swayimg-rotate FILE cw|ccw" >&2
              exit 1
              ;;
          esac
          exiftool -overwrite_original -n -Orientation="$new" "$img" >/dev/null
        '';
      };
    in
    {
      home.packages = with pkgs; [
        # images
        swayimg
        libwebp
        imagemagick

        # video
        vlc
        mpv
        yt-dlp
        ffmpeg
        obs-studio

        # audio
        strawberry
        picard
        audacity
        guitarix
        gxplugins-lv2
        crosspipe
      ];

      xdg.mimeApps.defaultApplications = {
        "image/gif" = "swayimg.desktop";
        "image/jpeg" = "swayimg.desktop";
        "image/png" = "swayimg.desktop";
        "image/webp" = "swayimg.desktop";
        "image/svg+xml" = "swayimg.desktop";
        "video/mkv" = "mpv.desktop";
      };

      # swayimg replaces imv because, unlike imv, it honours the EXIF Orientation
      # tag (built with libexif). So 'r' / 'Shift+r' rotate purely by rewriting
      # that tag - no pixel data is ever touched, making it completely lossless.
      # swayimg's exec waits for the command to finish, then `reload` re-reads the
      # file and re-applies the new orientation, so the view follows immediately.
      xdg.configFile."swayimg/config".text = ''
        # Opening one image also loads its folder siblings, mirroring the old
        # imv-dir behaviour so you can still page through the directory.
        [list]
        all = yes

        # imv's vim-like bindings ported onto swayimg. Keys not listed keep
        # swayimg's own defaults (m/Shift+m flip, [ ] view-rotate, Return
        # gallery, Insert mark, +/- and Equal zoom, all mouse bindings).
        # swayimg has no multi-key sequences, so imv's `gg` collapses to `g`.
        [keys.viewer]
        # Lossless rotate via the EXIF Orientation tag (our feature). Ctrl+r is
        # imv's native rotate-clockwise key, bound here to the same command.
        r = exec ${rotate}/bin/swayimg-rotate '%' cw; reload
        Shift+r = exec ${rotate}/bin/swayimg-rotate '%' ccw; reload
        Ctrl+r = exec ${rotate}/bin/swayimg-rotate '%' cw; reload

        # Navigation (imv: Left/Right prev/next, gg/G first/last, x close, q quit)
        Left = prev_file
        Right = next_file
        g = first_file
        Shift+g = last_file
        x = skip_file
        q = exit

        # Pan with hjkl (imv)
        h = step_left 10
        j = step_down 10
        k = step_up 10
        l = step_right 10

        # Zoom & scale (imv: Up/Down and i/o zoom, a actual size, s next scale
        # mode, c center; Backspace resets scale + position like imv's reset)
        Up = zoom +10
        Down = zoom -10
        i = zoom +10
        o = zoom -10
        a = zoom real
        s = zoom
        c = position center
        BackSpace = zoom optimal; position center

        # Animation (imv: `.` next frame, Space pause/play)
        period = next_frame
        Space = animation

        # Overlay, fullscreen, slideshow, print-to-stdout (imv: d/f/t/p)
        d = info
        f = fullscreen
        t = mode slideshow
        p = exec cat '%'

        # Carry the vim navigation keys into gallery mode too.
        [keys.gallery]
        h = step_left
        j = step_down
        k = step_up
        l = step_right
        g = first_file
        Shift+g = last_file
        q = exit
      '';
    };
}
