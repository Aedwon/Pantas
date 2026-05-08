#!/usr/bin/env bash
# Installs git pre-commit hooks for this repo.
# Run from repo root: ./tool/install_hooks.sh
set -euo pipefail

HOOK_PATH=".git/hooks/pre-commit"
mkdir -p "$(dirname "$HOOK_PATH")"

cat > "$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

# 1. gitleaks scan staged changes only
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --redact --config=.gitleaks.toml
else
  echo "WARNING: gitleaks not installed; skipping secret scan"
  echo "  install: brew install gitleaks"
fi

# 2. AI-attribution check
dart run tool/check_no_ai_attribution.dart

# 3. Layering check
dart run tool/check_layering.dart

# 4. Format check (just-changed Dart files)
CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)
if [ -n "$CHANGED" ]; then
  dart format --output=none --set-exit-if-changed $CHANGED
fi
HOOK

chmod +x "$HOOK_PATH"
echo "pre-commit hook installed at $HOOK_PATH"
