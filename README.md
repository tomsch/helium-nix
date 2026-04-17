# Helium for NixOS

Unofficial Nix package for [Helium](https://helium.computer/) - a private, fast, and honest web browser built on Chromium.

## Installation

### Flake Input (NixOS / Home Manager)

```nix
{
  inputs.helium.url = "github:tomsch/helium-nix";

  outputs = { self, nixpkgs, helium, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          helium.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

### Direct Run (no install)

```bash
nix run github:tomsch/helium-nix
```

### Imperative Install

```bash
nix profile install github:tomsch/helium-nix
```

## Features

- Chromium-based, privacy-focused browser from imputnet
- Native Wayland support enabled by default (`--ozone-platform-hint=auto`)
- PipeWire Screen Sharing via `WebRTCPipeWireCapturer`
- Wayland IME support

## Update Package

Maintainers can update to the latest version:

```bash
./update.sh
```

The GitHub Actions workflow (`.github/workflows/update.yml`) runs every 6 hours and auto-commits new releases.

## License

The Nix packaging is MIT. Helium itself is GPL-3.0.

## Links

- [Helium Website](https://helium.computer/)
- [helium-linux releases](https://github.com/imputnet/helium-linux/releases)
- [imputnet/helium](https://github.com/imputnet/helium) (source)
