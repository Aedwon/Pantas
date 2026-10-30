#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
# Prefer the Functions runtime required by this repository on Homebrew Macs.
if [[ -d /opt/homebrew/opt/node@22/bin ]]; then
  export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi
if [[ -d /opt/homebrew/opt/openjdk@21 ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk@21
  export PATH="$JAVA_HOME/bin:$PATH"
fi
export BETA_PRO_UNTIL='2026-11-16T00:00:00+08:00'
exec python3 tools/local/run_web_local.py "$@"
