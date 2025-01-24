{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs = { self, flake-utils, opam-nix, nixpkgs }@inputs:
    let package = "hello"; # Change this to the name of your package
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        olib = opam-nix.lib.${system};
        devPackagesQuery = {
          # You can add "development" packages here. They will get added to the devShell automatically.
          ocaml-base-compiler = "*";
          ocaml-lsp-server = "*";
          ocamlformat = "*";
        };
        scope = olib.buildOpamProject { } package ./. devPackagesQuery;
        overlay = final: prev: { };
        sicpPacks = scope.${package};
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        legacyPackages = scope.overrideScope' overlay;
        packages = self.legacyPackages.${system};
        devShells.default = pkgs.mkShell {
          inputsFrom = [ sicpPacks ];
          buildInputs = devPackages ++ [
            # You can add packages from nixpkgs here
          ];
        };
      });
}
