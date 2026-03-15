{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.devops-toolbox.crane;
in
{
  options.devops-toolbox.crane = {
    enable = lib.mkEnableOption "crane — interact with remote container images and registries";
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.crane
    ];
  };
}
