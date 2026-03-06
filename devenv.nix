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
    # Nix linters (formatting is handled by treefmt/nix fmt)
    deadnix.enable = true;
    statix.enable = true;

    # Shell linting (formatting is handled by treefmt/shfmt)
    shellcheck.enable = true;

    # GitHub Actions linting
    actionlint.enable = true;

    # General safeguards
    check-merge-conflicts.enable = true;
    check-added-large-files.enable = true;
  };

  enterShell = ''
    echo "devops-toolbox development shell"
  '';
}
