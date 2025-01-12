{
  description = "Scala Playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    let overlay = import ./nix/overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            overlays = [ overlay ];
            inherit system;
          };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages = pkgs;
          devShells.default = pkgs.mkShell ({
            inputsFrom = [ ];
            nativeBuildInputs = [ pkgs.mill ];
          });
        }) //
    {
      inherit inputs;
      overlays.default = overlay;
    }
  ;
}
