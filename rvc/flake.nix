{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      treefmt-nix,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        riscvPkgs = import nixpkgs {
          localSystem = "${system}";
          crossSystem = {
            config = "riscv64-unknown-linux-gnu";
            gcc.abi = "ilp32";
          };
        };
        riscvBuildPackages = riscvPkgs.buildPackages;
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = ".git/config";
          programs = {
            nixfmt.enable = true; # nix
            yamlfmt.enable = true; # yaml
            clang-format.enable = true; # c
          };
        };
        deps = with pkgs; [
          pre-commit
        ];
      in
      {
        packages = {
          c = pkgs.callPackage ./nix/pkgs/playground.nix { };
          default = self.packages.${system}.c;
        };
        devShells.default =
          with pkgs;
          mkShell {
            nativeBuildInputs = [
              cmake
              gnumake
              riscvBuildPackages.gcc
            ] ++ lib.optional stdenv.hostPlatform.isLinux riscvPkgs.buildPackages.gdb;
            buildInputs = [ deps ];
          };
        formatter = treefmtEval.config.build.wrapper;
        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}
