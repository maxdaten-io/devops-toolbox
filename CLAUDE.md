# Project: devops-toolbox

Reusable [devenv](https://devenv.sh) modules that bundle DevOps tools not available in nixpkgs.

## Tech Stack

- **Nix Flakes** with `flake-parts` for project structure
- **devenv** modules for xpdig and ASH tools
- **treefmt** for formatting (nixfmt-rfc-style, yamlfmt, shfmt, prettier)

## Common Commands

The devenv shell is activated automatically via the session start hook (`.claude/hooks/session-start.sh`), so commands can be run directly:

```bash
# Format all files
nix fmt

# Check flake integrity
nix flake check

# Build packages
nix build .#xpdig
nix build .#ash
```

## CI Validation

After pushing changes, use the `gh` CLI to check pipeline status and self-validate that CI passes:

```bash
gh run list --branch <branch-name>
gh run view <run-id>
gh run watch <run-id>
```

## Project Structure

- `flake.nix` — Flake entry point, defines packages and devenv modules
- `treefmt.nix` — Formatter configuration (nixfmt, yamlfmt, shfmt, prettier)
- `nix/packages/` — Package derivations (xpdig, ash)
- `nix/modules/` — devenv module definitions
- `devenv.nix` — Local development shell config
