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

  enterShell = ''
    echo "devops-toolbox development shell"
  '';
}
