#!/usr/bin/env bash
# Compiles the roadmap entry to a single JS file. Run from the repo root.
# Usage: spike/roadmap_js/build.sh [O2|O4]   (default O2)
set -euo pipefail
LEVEL="${1:-O2}"
OUT="spike/roadmap_js/build/roadmap.${LEVEL}.js"
mkdir -p spike/roadmap_js/build
start=$(date +%s)
dart compile js "-${LEVEL}" -o "$OUT" spike/roadmap_js/roadmap_entry.dart
end=$(date +%s)
echo "compile ${LEVEL}: $((end - start)) s"
echo "raw bytes:  $(wc -c < "$OUT")"
echo "gzip bytes: $(gzip -9 -c "$OUT" | wc -c)"
