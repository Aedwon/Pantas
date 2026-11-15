#!/bin/bash
# Upload a built web app to the Cloudflare Worker for one environment.
# Usage: tool/cloudflare-app/deploy.sh staging|prod [build dir, default build/web]
# Publishes from a local build folder only: the output of the usual flutter build and stamp step,
# the same files the Firebase deploy uploaded. It never downloads anything from Firebase, which
# bills every byte (Fable 5.2 rule 7 ruling 2, Nov 15, 2026). Uses the wrangler login on Aedwon's Mac.
# Attaching the custom domain is a separate DNS step (docs/deploy-prod.md, section 14). Afterwards:
#   node tool/cloudflare-app/compare.mjs https://<host> <build dir> <web api key>
set -euo pipefail
env="${1:?staging or prod}"
case "$env" in staging|prod) ;; *) echo "staging or prod" >&2; exit 2;; esac
here="$(cd "$(dirname "$0")" && pwd)"
src="$(cd "${2:-$here/../../build/web}" && pwd)"
test -f "$src/index.html" || { echo "$src has no index.html; build first" >&2; exit 1; }
rm -rf "$here/dist" && mkdir "$here/dist"
cp -R "$src/." "$here/dist/"
# Firebase's reserved /__/ files are served by Firebase through the forwarding, never from here.
rm -rf "$here/dist/__" "$here/dist/.last_build_id" "$here/dist/README.md"
cp "$here/headers.$env" "$here/dist/_headers"
cd "$here" && npx -y wrangler@4.162.0 deploy -c "wrangler.$env.jsonc"
