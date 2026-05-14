{
  description = "Nicotine — high-performance EVE Online multiboxing tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage ./package.nix { };
        packages.nicotine = self.packages.${system}.default;

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nicotine";
        };
      }
    );
}
