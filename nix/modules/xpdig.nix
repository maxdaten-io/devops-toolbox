{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.devops-toolbox.xpdig;

  xpdig = pkgs.callPackage ../packages/xpdig.nix { };

  k9sPluginYaml = ../.. + "/assets/k9s-xpdig-plugin.yaml";

  install-k9s-xpdig-plugin = pkgs.writeShellApplication {
    name = "install-k9s-xpdig-plugin";
    runtimeInputs = with pkgs; [ yq-go ];
    text = ''
      K9S_PLUGIN_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/k9s"
      K9S_PLUGIN_FILE="$K9S_PLUGIN_DIR/plugins.yaml"

      mkdir -p "$K9S_PLUGIN_DIR"

      if [ ! -f "$K9S_PLUGIN_FILE" ]; then
        echo "Creating $K9S_PLUGIN_FILE"
        cp "${k9sPluginYaml}" "$K9S_PLUGIN_FILE"
      else
        echo "Merging xpdig plugin into $K9S_PLUGIN_FILE"
        yq eval-all 'select(fileIndex == 0) *+ select(fileIndex == 1)' \
          "$K9S_PLUGIN_FILE" "${k9sPluginYaml}" > "$K9S_PLUGIN_FILE.tmp"
        mv "$K9S_PLUGIN_FILE.tmp" "$K9S_PLUGIN_FILE"
      fi

      echo "k9s xpdig plugin installed successfully"
    '';
  };
in
{
  options.devops-toolbox.xpdig = {
    enable = lib.mkEnableOption "xpdig — Crossplane trace explorer TUI";

    k9s-plugin.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include the install-k9s-xpdig-plugin script";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      xpdig
      pkgs.crossplane-cli
    ]
    ++ lib.optionals cfg.k9s-plugin.enable [
      install-k9s-xpdig-plugin
    ];
  };
}
