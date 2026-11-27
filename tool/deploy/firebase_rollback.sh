#!/bin/bash
# Rollback: put a full stamped build back on Firebase Hosting (docs/deploy-prod.md, section 14).
# The same guard as the Worker deploy runs first, so a rollback cannot publish an unstamped
# build, a build for the other environment, or the worker that shipped before build folders
# (which would put the build mix back for phones that hold a stamped build).
# Usage: tool/deploy/firebase_rollback.sh staging|prod [build dir, default build/web]
set -euo pipefail
env="${1:?staging or prod}"
case "$env" in staging|prod) ;; *) echo "staging or prod" >&2; exit 2;; esac
here="$(cd "$(dirname "$0")" && pwd)"
src="$(cd "${2:-$here/../../build/web}" && pwd)"
node "$here/check_worker_stamp.mjs" "$src" --target "$env"
cd "$here/../.."
if [ "$env" = prod ]; then
  firebase deploy --only hosting:app --public "$src" --project pantas-prod
else
  firebase deploy --only hosting:app --public "$src" --config firebase.staging.json --project pantas-staging
fi
