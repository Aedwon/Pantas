#!/bin/bash
# Build the web app and publish it to staging (https://staging.pantas.study, project pantas-staging).
# Staging has its own data and sign-in; prod is not touched. firebase.staging.json serves only the
# app target and adds X-Robots-Tag: noindex. The App Check key is staging's public reCAPTCHA key.
# Usage: tool/deploy/staging_web.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
dart run build_runner build --delete-conflicting-outputs
flutter build web --release -t lib/main_staging.dart \
  --dart-define=APP_CHECK_WEB_SITE_KEY=6Lcp8xUuAAAAAICQRMX8-J2JYzU5dxKsj8Qp3sQa \
  --dart-define=BUILD_NUMBER="$(git rev-list --count HEAD)"
node tool/web/stamp_worker_version.mjs build/web
node tool/web/retain_builds.mjs https://staging.pantas.study build/web
firebase deploy --config firebase.staging.json --only hosting:app --project pantas-staging --non-interactive
