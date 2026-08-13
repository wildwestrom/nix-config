{
  lib,
  stdenv,
  fetchurl,
  asar,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,

  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libGL,
  libayatana-appindicator,
  libcap_ng,
  libgbm,
  libnotify,
  libseccomp,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxtst,
  nspr,
  nss,
  pango,
  systemdLibs,

  # Runtime tools the app shells out to. The "cowork" agent sandbox boots the
  # bundled smol-bin.x64.img in a VM, driving qemu with the bundled virtiofsd.
  qemu_kvm,
  OVMF,
  # MCP servers are launched as `npx ...` / `uvx ...` subprocesses.
  nodejs,
  uv,
}:
# Anthropic's own Linux build, repackaged from the .deb they publish at
# downloads.claude.ai. This replaces k3d3/claude-desktop-linux-flake, which
# repacked the *Windows* installer -- that download channel froze at 0.14.10 on
# 2025-10-29, so the flake can no longer be moved forward. The Linux package
# ships real Linux native bindings, so none of upstream's asar surgery or its
# patchy-cnb binding stub is needed here.
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.28929.0";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-POs5Emi96af+wyUg00m3BAQxZiBM3VccYtHpUHAfSPw=";
  };

  nativeBuildInputs = [
    asar
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  # Electron's own NEEDED set, plus libseccomp/libcap-ng for the bundled
  # virtiofsd. Libraries Electron dlopens rather than links go in
  # runtimeDependencies so autoPatchelfHook still puts them on the RUNPATH.
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libcap_ng
    libgbm
    libseccomp
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemdLibs # libudev
  ];

  runtimeDependencies = [
    libayatana-appindicator # tray icon
    libnotify
    libsecret # safeStorage keyring backend
    libxtst
  ];

  # The bundled libEGL.so is ANGLE's shim, which dlopens the system
  # libEGL.so.1. dlopen from a shared library consults that library's own
  # RUNPATH, not the executable's, so libglvnd has to be appended to every ELF
  # here -- runtimeDependencies alone only reaches the main binary, and the GPU
  # process then dies with EGL_NOT_INITIALIZED.
  appendRunpaths = [ "${libGL}/lib" ];

  unpackCmd = "dpkg-deb -x $curSrc .";
  sourceRoot = ".";

  # The deb's maintainer scripts only register Anthropic's apt repo and write an
  # AppArmor userns profile for Ubuntu 24.04+. Both are meaningless here, so the
  # control archive is simply dropped.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # The cowork VM resolves its three external pieces differently: qemu is
    # looked up on PATH (handled in the wrapper) and virtiofsd falls back to the
    # copy bundled in resources/, but the UEFI firmware is a hardcoded probe of
    # /usr/share/OVMF with no fallback and no environment override, so the store
    # path has to be patched into the bundle. The app derives the VARS file by
    # rewriting OVMF_CODE -> OVMF_VARS in whichever candidate it finds, and
    # OVMF.fd ships both under the same directory, so rewriting the directory
    # prefix is enough.
    asar extract usr/lib/claude-desktop/resources/app.asar asar-contents
    grep -rlF --include=\*.js /usr/share/OVMF/ asar-contents/.vite/build >ovmf-hits
    # Guard: chunk names carry content hashes, so a version bump that moves this
    # string should fail the build rather than silently drop the VM sandbox.
    test -s ovmf-hits
    xargs -a ovmf-hits sed -i 's|/usr/share/OVMF/|${OVMF.fd}/FV/|g'
    # Reproduces the three entries the shipped asar marks unpacked; the deb's
    # own app.asar.unpacked directory is kept as-is, so only the archive is
    # replaced.
    asar pack asar-contents app.asar.patched \
      --unpack '*.node' --unpack-dir 'resources/github-mcp'
    mv app.asar.patched usr/lib/claude-desktop/resources/app.asar

    mkdir -p $out/lib $out/share
    cp -r usr/lib/claude-desktop $out/lib/
    cp -r usr/share/applications $out/share/
    cp -r usr/share/icons $out/share/

    # Shipped 4755 for Chromium's SUID sandbox fallback. Nix can't set that bit,
    # and NixOS doesn't restrict unprivileged user namespaces, so Chromium's
    # namespace sandbox works without it.
    rm -f $out/lib/claude-desktop/chrome-sandbox

    runHook postInstall
  '';

  # wrapGAppsHook3 would wrap the raw Electron binary in place; make our own
  # entry point instead so its argv[0] stays inside $out/lib.
  dontWrapGApps = true;

  # --password-store: Electron guesses its safeStorage backend from
  # XDG_CURRENT_DESKTOP, which under niri names no known desktop, so it falls
  # back to plaintext and the app reports that the sign-in won't be saved.
  # gnome-keyring is running and PAM-unlocked (see hosts/default/configuration.nix),
  # so just name the backend. Same fix as the signal-desktop wrapper.

  postFixup = ''
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          uv
          qemu_kvm
        ]
      } \
      --add-flags '--password-store=gnome-libsecret' \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  '';

  meta = {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai";
    downloadPage = "https://claude.com/download";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
})
