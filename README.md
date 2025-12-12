# nu-flake

An extensible nu-shell wrapper, made using nix flakes.

## Why?

I don't like home-management, and I want to be able to quickly run my dots using nix anywhere/anytime.

## Installation

### NixOS Configuration Installation

```nix
nixpkgs.overlays = [
    nu-flake.overlays.default
];

environment.systemPackages = [ pkgs.nushell ];
```

### Testing

```sh
$ nix run github:kossLAN/nu-flake
```
