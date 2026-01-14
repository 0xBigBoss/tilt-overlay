{
  description = "Tilt fork overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tilt-src = {
      url = "github:0xbigboss/tilt";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, tilt-src }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      overlays.default = final: prev: {
        tilt = prev.tilt.overrideAttrs (old:
          let
            tiltAssets =
              (prev.callPackage "${prev.path}/pkgs/by-name/ti/tilt/assets.nix" {
                src = tilt-src;
                version = old.version;
              }).overrideAttrs (assetsOld: {
                yarnOfflineCache = assetsOld.yarnOfflineCache.overrideAttrs (_: {
                  outputHash = "sha256-duiMc4XIUKHDJOli6+IGz7+fVq4sKY7isKl/D7mTY9E=";
                });
              });
          in {
            src = tilt-src;
            preBuild = ''
              mkdir -p pkg/assets/build
              cp -r ${tiltAssets}/* pkg/assets/build/
            '';
          });
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in {
          tilt = pkgs.tilt;
          default = pkgs.tilt;
        }
      );
    };
}
