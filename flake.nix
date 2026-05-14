{
  description = "Nicotine package and NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          nicotine = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.nicotine;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nicotine";
        };
      });

      nixosModules = {
        nicotine =
          { config, lib, pkgs, ... }:
          let
            cfg = config.programs.nicotine;
          in
          {
            options.programs.nicotine = {
              enable = lib.mkEnableOption "Nicotine";

              package = lib.mkOption {
                type = lib.types.package;
                default = self.packages.${pkgs.system}.default;
                description = "The Nicotine package to install.";
              };
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];
            };
          };

        default = self.nixosModules.nicotine;
      };
    };
}
