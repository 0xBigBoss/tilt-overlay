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
            tiltRev = tilt-src.rev or "unknown";
            tiltLastModified = tilt-src.lastModifiedDate or null;
            tiltDate =
              if tiltLastModified == null then
                null
              else
                "${builtins.substring 0 4 tiltLastModified}-${builtins.substring 4 2 tiltLastModified}-${builtins.substring 6 2 tiltLastModified}T${builtins.substring 8 2 tiltLastModified}:${builtins.substring 10 2 tiltLastModified}:${builtins.substring 12 2 tiltLastModified}Z";
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
            version = old.version;
            tags = (old.tags or []) ++ [ "osusergo" ];
            ldflags =
              old.ldflags
              ++ (if tiltDate == null then [] else [ "-X main.date=${tiltDate}" ])
              ++ [ "-X github.com/tilt-dev/tilt/internal/cli.commitSHA=${tiltRev}" ];
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
