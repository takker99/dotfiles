{
  lib,
  stdenv,
  fetchzip,
  ripgrep,
  makeBinaryWrapper,
  patchelf,
  versionCheckHook,
}:
let
  # Official prebuilt binaries, published as npm platform packages — the same
  # files `npm i -g @opencode/cli@<version>` installs as bin/opencode.
  # Keyed by host system; meta.platforms is derived from it, so an unconfigured
  # system fails at evaluation instead of silently shipping a foreign binary.
  npmPlatforms = {
    "x86_64-linux" = {
      npm = "linux-x64";
      hash = "sha256-vUGVUnrNTWxvs11NH9n8cq+0k0mdI2etC/RtSLpLO9Q=";
    };
    "aarch64-linux" = {
      npm = "linux-arm64";
      hash = "sha256-k0NvUOrOI5dee4ePJ3Cx/pK0svy0A+JqHUWttPgoXTg=";
    };
    # x86_64-darwin is absent on purpose: nixpkgs 26.11 (nixos-unstable)
    # dropped support for it, so importing nixpkgs for that system throws.
    "aarch64-darwin" = {
      npm = "darwin-arm64";
      hash = "sha256-geeWRF71mutp9h22szT5DyZUuVuclRyYnPPyAFtUthA=";
    };
  };
  platform =
    npmPlatforms.${stdenv.hostPlatform.system}
      or (throw "opencode2: unsupported host system ${stdenv.hostPlatform.system}");

  # The Linux builds are glibc-linked ELFs with the FHS loader path hardcoded
  # (/lib/ld-linux-aarch64.so.1, /lib64/ld-linux-x86-64.so.2), which exists
  # neither in the build sandbox nor on non-FHS systems (e.g. NixOS).
  # installPhase rewrites only the interpreter — that much patchelf is safe, and
  # that much patchelf is safe, and it lets versionCheckHook actually run the
  # binary during the build. Setting an rpath is NOT safe: Bun's single-file
  # loader segfaults with one, so never add it here. Darwin builds are Mach-O
  # and need no patching.
  needsInterpreterPatch = stdenv.hostPlatform.isLinux;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opencode2";
  version = "2.0.20";

  src = fetchzip {
    url = "https://registry.npmjs.org/@opencode/cli-${platform.npm}/-/cli-${platform.npm}-${finalAttrs.version}.tgz";
    hash = platform.hash;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    versionCheckHook
  ]
  ++ lib.optionals needsInterpreterPatch [ patchelf ];

  # Ship the upstream binaries as-is: the Bun payload must not be stripped, and
  # stripping would invalidate macOS code signatures.
  dontStrip = true;
  dontConfigure = true;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/opencode $out/bin/opencode2
    ${lib.optionalString needsInterpreterPatch ''
      patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/bin/opencode2
    ''}
    wrapProgram $out/bin/opencode2 --prefix PATH : ${lib.makeBinPath [ ripgrep ]}

    runHook postInstall
  '';

  meta = {
    description = "OpenCode 2 command line interface";
    homepage = "https://opencode.ai/";
    license = lib.licenses.mit;
    mainProgram = "opencode2";
    platforms = builtins.attrNames npmPlatforms;
  };
})
