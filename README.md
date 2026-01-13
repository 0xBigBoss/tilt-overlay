# tilt-overlay

This repository provides a Nix flake overlay that builds Tilt from the `0xbigboss/tilt` fork.

## Usage

Add the overlay to a flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tilt-overlay.url = "github:0xbigboss/tilt-overlay";
  };

  outputs = { self, nixpkgs, tilt-overlay, ... }: {
    nixpkgs.overlays = [ tilt-overlay.overlays.default ];
  };
}
```

Build Tilt from the fork:

```bash
nix build .#tilt
```

If the build fails with a vendor hash mismatch, replace the `vendorHash` in `flake.nix` with the hash printed by Nix.

## Updating to the latest fork revision

```bash
nix flake update --update-input tilt-src
```

## License

MIT
