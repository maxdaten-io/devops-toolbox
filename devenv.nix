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

  pre-commit.hooks = {
    nixfmt-rfc-style.enable = true;
    deadnix.enable = true;
    statix.enable = true;
    yamllint.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    actionlint.enable = true;
    check-merge-conflicts.enable = true;
    check-added-large-files.enable = true;
  };

  enterShell = ''
    echo "devops-toolbox development shell"
  '';
}
