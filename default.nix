{
  pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem,
  tiltVersion ? null,
}: let
  inherit (pkgs) lib;
  sources = builtins.fromJSON (lib.strings.fileContents ./sources.json);

  # Define target version with the following precedence:
  # 1. Explicitly provided tiltVersion parameter
  # 2. TILT_VERSION environment variable
  # 3. Default to "latest"
  envVersion = builtins.getEnv "TILT_VERSION";
  selectedVersion =
    if tiltVersion != null
    then tiltVersion
    else if envVersion != ""
    then envVersion
    else "latest";

  # Access relevant data from sources.json
  versionData =
    if builtins.hasAttr selectedVersion sources
    then sources.${selectedVersion}
    else throw "Tilt version '${selectedVersion}' not found in sources.json";

  # Create the tilt package derivation
  mkTiltPackage = {version}: let
    platformData = versionData.platforms.${system}
      or (throw "Unsupported system: ${system}");

    tilt-archive = pkgs.fetchurl {
      url = platformData.url;
      sha256 = platformData.sha256;
    };
  in
    pkgs.stdenv.mkDerivation {
      pname = "tilt";
      inherit version;

      src = tilt-archive;

      nativeBuildInputs = [pkgs.gnutar pkgs.gzip];

      dontBuild = true;
      dontConfigure = true;

      unpackPhase = ''
        runHook preUnpack
        mkdir -p source
        tar -xzf $src -C source
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp source/tilt $out/bin/tilt
        chmod +x $out/bin/tilt

        runHook postInstall
      '';

      meta = {
        description = "A multi-service dev environment for teams on Kubernetes";
        homepage = "https://tilt.dev";
        license = lib.licenses.asl20;
        platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
        mainProgram = "tilt";
      };
    };

  tilt = mkTiltPackage {
    version = versionData.version;
  };
in {
  inherit tilt;
  default = tilt;
}
