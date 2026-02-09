{
  description = "Reusable devenv modules for DevOps tools: xpdig (Crossplane trace explorer) and ASH (Automated Security Helper)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "maxdaten-io.cachix.org-1:ZDDi/8gGLSeUEU9JST6uXDcQfNp2VZzccmjUljPHHS8="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://maxdaten-io.cachix.org"
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          ...
        }:
        let
          xpdig = pkgs.callPackage ./nix/packages/xpdig.nix { };
          ash = pkgs.callPackage ./nix/packages/ash.nix { };
        in
        {
          packages = {
            inherit xpdig ash;
          };

          treefmt.config = import ./treefmt.nix { inherit pkgs; };
        };

      flake = {
        devenvModules = {
          default = ./nix/modules/default.nix;
          xpdig = ./nix/modules/xpdig.nix;
          ash = ./nix/modules/ash.nix;
        };
      };
    };
}
