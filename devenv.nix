{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    gh
    nix-prefetch
    treefmt
    cachix
  ];

  languages.nix.enable = true;

  devops-toolbox.xpdig.enable = true;
  devops-toolbox.ash.enable = true;
  devops-toolbox.crane.enable = true;

  enterShell = ''
    echo "devops-toolbox development shell"
  '';

  enterTest = ''
    echo "==> Testing xpdig module"
    xpdig --version
    echo "==> Testing crossplane-cli (from xpdig module)"
    crossplane --version
    echo "==> Testing install-k9s-xpdig-plugin is on PATH"
    which install-k9s-xpdig-plugin
    echo "==> Testing ash wrapper script exists"
    which ash
    echo "==> Testing crane"
    crane version
    echo "==> All module tests passed"
  '';
}
