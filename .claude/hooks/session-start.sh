#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Nix using the Determinate Systems installer (idempotent)
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- install linux --no-confirm --init none 2>&1 || true

  # The installer may fail on profile setup in sandboxed environments,
  # but nix binaries are still usable from the store. Set up the profile manually.
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  else
    # Find the nix binary in the store and add it to PATH
    NIX_BIN=$(find /nix/store -maxdepth 2 -name "nix" -path "*/bin/nix" -type f 2>/dev/null | grep "determinate-nix" | head -1)
    if [ -n "$NIX_BIN" ]; then
      export PATH="$(dirname "$NIX_BIN"):$PATH"
    fi
  fi
fi

# Ensure nix is on PATH for this session
if ! command -v nix &>/dev/null; then
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# Persist Nix environment for subsequent session commands
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  echo '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >>"$CLAUDE_ENV_FILE"
else
  echo 'export PATH="/nix/var/nix/profiles/default/bin:$PATH"' >>"$CLAUDE_ENV_FILE"
fi

# Enable flakes and accept this project's flake config (extra substituters/public keys)
cat >>"$CLAUDE_ENV_FILE" <<'ENVEOF'
export NIX_CONFIG="extra-experimental-features = nix-command flakes
accept-flake-config = true
sandbox = false"
ENVEOF

export NIX_CONFIG="extra-experimental-features = nix-command flakes
accept-flake-config = true
sandbox = false"

# Pre-build treefmt formatter so nix fmt is fast during the session
echo "Pre-building treefmt formatter..."
cd "$CLAUDE_PROJECT_DIR"
nix build .#formatter.x86_64-linux --no-link 2>&1 || true

echo "Session start hook completed successfully."
