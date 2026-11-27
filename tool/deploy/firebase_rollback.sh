#!/bin/bash
# Rollback: put a full stamped build back on Firebase Hosting (docs/deploy-prod.md, section 14).
# The same guard as the Worker deploy runs first, so a rollback cannot publish an unstamped
# build, a build for the other environment, or the worker that shipped before build folders
# (which would put the build mix back for phones that hold a stamped build).
# The repository's configs list their sites as an array, and the Firebase CLI refuses --public
# with an array, so the build folder goes into a temporary config of the same `app` entry.
# Usage: tool/deploy/firebase_rollback.sh staging|prod [build dir, default build/web]
set -euo pipefail
env="${1:?staging or prod}"
case "$env" in staging|prod) ;; *) echo "staging or prod" >&2; exit 2;; esac
here="$(cd "$(dirname "$0")" && pwd)"
src="$(cd "${2:-$here/../../build/web}" && pwd)"
# PANTAS_GUARD_PINS is for the tests only: stand-in bytes for the files the guard pins.
pins=()
if [ -n "${PANTAS_GUARD_PINS:-}" ]; then pins=(--pins "$PANTAS_GUARD_PINS"); fi
node "$here/check_worker_stamp.mjs" "$src" --target "$env" ${pins[@]+"${pins[@]}"}
cd "$here/../.."
config=".firebase-rollback-$env-$$.json"
trap 'rm -f "$config"' EXIT
node "$here/firebase_rollback_config.mjs" "$env" "$src" > "$config"
firebase deploy --only hosting:app --config "$config" --project "pantas-$env"
