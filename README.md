# tilt-overlay

Nix flake overlay for [Tilt](https://tilt.dev), a multi-service dev environment for teams on Kubernetes.

Pre-built binaries are fetched from official [GitHub releases](https://github.com/tilt-dev/tilt/releases), automatically updated every 12 hours via GitHub Actions.

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

Run directly:

```bash
nix run github:0xbigboss/tilt-overlay
```

Build locally:

```bash
nix build .#tilt
```

## Specific Version

For non-flake usage (e.g., `nix-build`), set `TILT_VERSION` to select a version from `sources.json`:

```bash
TILT_VERSION=0.36.1 nix-build -A tilt
```

For flake usage, version selection requires `--impure`:

```bash
TILT_VERSION=0.36.1 nix build .#tilt --impure
```

## Updating

Sources are automatically updated via GitHub Actions. To update manually:

```bash
./update        # Update to latest release
./update 0.36.0 # Update to specific version
```

## License

MIT (overlay code). Tilt itself is Apache-2.0.
