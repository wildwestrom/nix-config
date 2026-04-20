{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-0.66.1.tgz";
    hash = "sha256-NN26A3EQft5Bhyu53JmNECd1kgkNPPse6BsDnwGbzyE=";
  };

  # Inject the lock file so buildNpmPackage can use it.
  # Generate pi-lock.json with:
  #   mkdir /tmp/pi && tar -xOf <tarball> package/package.json > /tmp/pi/package.json
  #   cd /tmp/pi && npm install --package-lock-only
  #   cp /tmp/pi/package-lock.json ~/nix-config/packages/pi-lock.json
  # Then get npmDepsHash with: prefetch-npm-deps ~/nix-config/packages/pi-lock.json
  srcWithLock = runCommand "pi-coding-agent-src" { } ''
    mkdir -p $out
    tar -xzf ${src} --strip-components=1 -C $out
    cp ${./pi-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.66.1";

  src = srcWithLock;

  npmDepsHash = "sha256-7yu4erAoaq3uQesOIGRtAGVVc8xrys8nEJr30TVGg2Q=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Minimal terminal coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    license = licenses.mit;
    mainProgram = "pi";
    platforms = platforms.unix;
  };
}
