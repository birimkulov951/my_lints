#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Flutter SDK if not already installed
if ! command -v flutter &> /dev/null; then
  FLUTTER_DIR="/usr/lib/flutter"
  wget -q -O /tmp/flutter-sdk.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.3-stable.tar.xz
  mkdir -p "$FLUTTER_DIR"
  tar -xf /tmp/flutter-sdk.tar.xz -C /usr/lib/
  rm -f /tmp/flutter-sdk.tar.xz
  # Mark Flutter directory as safe for git
  git config --global --add safe.directory "$FLUTTER_DIR"
  # Disable analytics
  "$FLUTTER_DIR/bin/flutter" config --no-analytics 2>/dev/null || true
  echo "export PATH=\"$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
  export PATH="$FLUTTER_DIR/bin:$FLUTTER_DIR/bin/cache/dart-sdk/bin:$PATH"
fi

# Ensure git safe.directory is set (idempotent)
git config --global --add safe.directory /usr/lib/flutter 2>/dev/null || true

# Install dependencies
cd "$CLAUDE_PROJECT_DIR"
flutter pub get
