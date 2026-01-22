{
  description = "Tilt - multi-service dev environment for teams on Kubernetes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Import packages from default.nix
      # Prioritize tiltVersion from the TILT_VERSION environment variable if set
      envVersion = builtins.getEnv "TILT_VERSION";
      selectedVersion =
        if envVersion != ""
        then envVersion
        else null;
      tiltPkgs = import ./default.nix {
        inherit pkgs system;
        tiltVersion = selectedVersion;
      };
    in {
      packages = tiltPkgs;

      apps = {
        tilt = flake-utils.lib.mkApp {
          drv = tiltPkgs.tilt;
          name = "tilt";
        };
        default = flake-utils.lib.mkApp {
          drv = tiltPkgs.tilt;
          name = "tilt";
        };
      };

      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [tiltPkgs.tilt];
      };
    });
  in
    outputs
    // {
      overlays.default = final: prev: {
        tiltPackages = outputs.packages.${prev.system};
        tilt = outputs.packages.${prev.system}.tilt;
      };
    };
}
