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
      nushell = import ./nix/wrapNu.nix {
        pkgs = final;
        lib = nixpkgs.lib;
      };
    };

    packages = forEachSystem (system: pkgs: rec {
      nushell = import ./nix/wrapNu.nix {
        inherit pkgs;
        lib = nixpkgs.lib;
      };

      default = nushell;
    });
  };
}
