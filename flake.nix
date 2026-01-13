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
        tilt = prev.tilt.overrideAttrs (_old: {
          src = tilt-src;
          # Set a real hash after first build.
          vendorHash = prev.lib.fakeSha256;
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
