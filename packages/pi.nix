{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
}:

let
  version = "0.67.68";
  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    # Get the hash with `nix-prefetch-url --type sha256 $url`
    # Then get the sri with `nix hash convert --hash-algo sha256 --to sri $hash`
    hash = "sha256-C2T+IeIiHhXAy5TJ3/1c+7mQGumd9BanHF2RWm6eFxc=";
  };

  # Inject the lock file so buildNpmPackage can use it.
  # Generate pi-lock.json with:
  # rm -rf /tmp/pi && mkdir /tmp/pi
  # tar -xOf /nix/store/${hash}-pi-coding-agent-${version}.tgz package/package.json > /tmp/pi/package.json
  #   cd /tmp/pi && npm install --package-lock-only
  #   cp /tmp/pi/package-lock.json ~/nix-config/packages/pi-lock.json
  # Then get npmDepsHash with: prefetch-npm-deps ~/nix-config/packages/pi-lock.json
  srcWithLock = runCommand "pi-coding-agent-src" { } ''
    mkdir -p $out
    tar -xzf ${src} --strip-components=1 -C $out
    cp ${./pi-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage {
  pname = "pi-coding-agent";
  version = version;

  src = srcWithLock;

  npmDepsHash = "sha256-c1QrnqzQOuoaOspNvFTZLhPR1NuSwyMcljfR0wublOo=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Minimal terminal coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    license = licenses.mit;
    mainProgram = "pi";
    platforms = platforms.unix;
  };
}
