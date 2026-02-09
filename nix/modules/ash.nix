{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.devops-toolbox.ash;
  ash = pkgs.callPackage ../packages/ash.nix { };
in
{
  options.devops-toolbox.ash = {
    enable = lib.mkEnableOption "ASH — Automated Security Helper";
  };

  config = lib.mkIf cfg.enable {
    packages = [
      ash
      pkgs.uv
      pkgs.python3
    ];
  };
}
