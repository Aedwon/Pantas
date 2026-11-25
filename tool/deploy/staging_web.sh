#!/bin/bash
# Build the web app and publish it to staging (https://staging.pantas.study, project pantas-staging).
# Staging has its own data and sign-in; prod is not touched. The Cloudflare Worker serves the app
# (headers.staging adds X-Robots-Tag: noindex). Firebase Hosting keeps only the tiny page in
# hosting/retired (checklist S6), so this script never deploys Hosting.
# The App Check key is staging's public reCAPTCHA key.
# Usage: tool/deploy/staging_web.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
dart run build_runner build --delete-conflicting-outputs
# --no-web-resources-cdn puts CanvasKit in the build, so the service worker can store it and the
# app starts offline; the deploy guard refuses a build that loads it from Google's servers.
flutter build web --release --no-web-resources-cdn -t lib/main_staging.dart \
  --dart-define=APP_CHECK_WEB_SITE_KEY=6Lcp8xUuAAAAAICQRMX8-J2JYzU5dxKsj8Qp3sQa \
  --dart-define=BUILD_NUMBER="$(git rev-list --count HEAD)"
node tool/web/stamp_worker_version.mjs build/web
tool/cloudflare-app/deploy.sh staging build/web
