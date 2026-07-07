{
  description = "Terraform for AlterLinux infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: pkg |> nixpkgs.lib.getName |> (name: name == "terraform");
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.terraform.enable = true;
          programs.nixfmt.enable = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.terraform
            treefmtEval.config.build.wrapper
          ];
        };

        formatter = treefmtEval.config.build.wrapper;

        checks.formatting = treefmtEval.config.build.check self;
      }
    );
}
