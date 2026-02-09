{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    nix-prefetch
  ];

  languages.nix.enable = true;

  enterShell = ''
    echo "devops-toolbox development shell"
  '';
}
