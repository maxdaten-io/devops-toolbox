#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Nix in single-user (no-daemon) mode for containerized environments.
# The Determinate Systems installer crashes in containers due to PID handling
# bugs, so we use the official Nix installer instead.
if ! command -v nix &>/dev/null; then
  echo "Installing Nix (single-user mode)..."

  # Disable build-users-group for single-user (root) installs in containers
  # where the nixbld group does not exist.
  export NIX_CONFIG="build-users-group ="
  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon 2>&1 || true

  # If the installer failed to create a profile (e.g. nix-env crashed), create
  # a manual symlink so that the nix binaries are reachable via ~/.nix-profile.
  if [ ! -e "$HOME/.nix-profile/bin/nix" ]; then
    nix_store_path=$(find /nix/store -maxdepth 1 -name '*-nix-*' -type d | grep -v '\.\(drv\|dep\)' | head -1)
    if [ -n "$nix_store_path" ] && [ -x "$nix_store_path/bin/nix" ]; then
      mkdir -p "$(dirname "$(readlink -f "$HOME/.nix-profile" 2>/dev/null || echo "$HOME/.nix-profile")")" 2>/dev/null || true
      ln -sfn "$nix_store_path" "$(readlink -f "$HOME/.nix-profile" 2>/dev/null || echo "$HOME/.nix-profile")" 2>/dev/null || true
    fi
  fi

  # Source the nix profile
  if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
fi

# Ensure nix is on PATH for this session
if ! command -v nix &>/dev/null; then
  if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# Persist Nix environment for subsequent session commands
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >>"$CLAUDE_ENV_FILE"
elif [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  echo '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >>"$CLAUDE_ENV_FILE"
else
  echo 'export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"' >>"$CLAUDE_ENV_FILE"
fi

# Enable flakes and accept this project's flake config (extra substituters/public keys)
cat >>"$CLAUDE_ENV_FILE" <<'ENVEOF'
export NIX_CONFIG="extra-experimental-features = nix-command flakes
accept-flake-config = true
sandbox = false
build-users-group ="
ENVEOF

export NIX_CONFIG="extra-experimental-features = nix-command flakes
accept-flake-config = true
sandbox = false
build-users-group ="

# Install devenv if not available
if ! command -v devenv &>/dev/null; then
  echo "Installing devenv..."
  nix profile install --accept-flake-config nixpkgs#devenv 2>&1 || true
fi

# Activate devenv shell environment for subsequent commands
echo "Activating devenv shell environment..."
cd "$CLAUDE_PROJECT_DIR"
DEVENV_ENV=$(devenv print-dev-env --no-tui 2>/dev/null) || true
if [ -n "$DEVENV_ENV" ]; then
  echo "$DEVENV_ENV" >>"$CLAUDE_ENV_FILE"
fi

# Pre-build treefmt formatter so nix fmt is fast during the session
echo "Pre-building treefmt formatter..."
nix build .#formatter.x86_64-linux --no-link 2>&1 || true

echo "Session start hook completed successfully."
