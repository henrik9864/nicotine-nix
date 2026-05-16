{
  description = "Collection of custom packages and NixOS modules";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsDir = builtins.readDir ./pkgs;
      packageNames = builtins.filter (
        name: pkgsDir.${name} == "directory"
      ) (builtins.attrNames pkgsDir);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          packages = nixpkgs.lib.genAttrs packageNames (
            name: pkgs.callPackage ./pkgs/${name} { }
          );
        in
        packages // {
          default = packages.nicotine or (builtins.head (builtins.attrValues packages));
        }
      );
      apps = forAllSystems (
        system:
        let
          packages = self.packages.${system};
          apps = nixpkgs.lib.genAttrs packageNames (name: {
            type = "app";
            program = "${packages.${name}}/bin/${packages.${name}.meta.mainProgram or name}";
          });
        in
        apps // {
          default = apps.nicotine or (builtins.head (builtins.attrValues apps));
        }
      );
      nixosModules =
        let
          modules = nixpkgs.lib.genAttrs packageNames (
            name:
            { config, lib, pkgs, ... }:
            let
              cfg = config.programs.${name};
            in
            {
              options.programs.${name} = {
                enable = lib.mkEnableOption name;
                package = lib.mkOption {
                  type = lib.types.package;
                  default = self.packages.${pkgs.system}.${name};
                  description = "The ${name} package to install.";
                };
              };
              config = lib.mkIf cfg.enable {
                environment.systemPackages = [ cfg.package ];
              };
            }
          );
        in
        modules // {
          default = modules.nicotine or (builtins.head (builtins.attrValues modules));
        };
    };
}
