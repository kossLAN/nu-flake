{
  description = "stupid nushell dots";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forEachSystem = fn:
      nixpkgs.lib.genAttrs
      ["x86_64-linux" "aarch64-linux"]
      (system: fn system nixpkgs.legacyPackages.${system});
  in {
    overlays.default = final: prev: {
      nushell = final.callPackage ./nix/wrapNu.nix {
        lib = nixpkgs.lib;
        prevNushell = prev.nushell;
      };
    };

    packages = forEachSystem (system: pkgs: let
      pkgsWithOverlay = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in rec {
      nushell = pkgsWithOverlay.nushell;
      default = nushell;
    });
  };
}
