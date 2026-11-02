#!/usr/bin/env bash
# Build Content Pass and install it to ~/Applications/Content Pass.app.
# Usage: tools/content_pass/make_app.sh [--skip-web]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
BUILD="$ROOT/build/content_pass"
INSTALL_DIR="${CONTENT_PASS_INSTALL_DIR:-$HOME/Applications}"
APP_NAME="Content Pass.app"
SKIP_WEB=0
[[ "${1:-}" == "--skip-web" ]] && SKIP_WEB=1

say() { echo "==> $*"; }
cd "$ROOT"

# STUB_RUNTIME (testing only): a folder holding web/ and bin/, used instead of steps 1 to 3.
if [[ -n "${CONTENT_PASS_STUB_RUNTIME:-}" ]]; then
  say "Using stub runtime $CONTENT_PASS_STUB_RUNTIME"
  mkdir -p "$BUILD"
  rm -rf "$BUILD/web" "$BUILD/bin"
  cp -R "$CONTENT_PASS_STUB_RUNTIME/web" "$BUILD/web"
  cp -R "$CONTENT_PASS_STUB_RUNTIME/bin" "$BUILD/bin"
else
  say "1/5 Dependencies"
  [[ -f .dart_tool/package_config.json ]] || flutter pub get
  [[ -f lib/core/content/content_database.g.dart ]] || dart run build_runner build --delete-conflicting-outputs

  mkdir -p "$BUILD"
  if [[ $SKIP_WEB -eq 1 ]]; then
    [[ -f "$BUILD/web/index.html" ]] || { echo "No earlier web build in $BUILD/web. Run without --skip-web." >&2; exit 1; }
    say "2/5 Web build skipped, reusing $BUILD/web"
  else
    say "2/5 Building the web app"
    rm -rf "$BUILD/web"
    flutter build web -t tools/content_pass/app/main.dart --no-web-resources-cdn \
      --pwa-strategy none --release -o "$BUILD/web"
    sed 's#\$FLUTTER_BASE_HREF#/#' tools/content_pass/app/index.html > "$BUILD/web/index.html"
  fi

  say "3/5 Compiling the server and tools"
  rm -rf "$BUILD/bin"; mkdir -p "$BUILD/bin"
  dart compile exe tools/content_pass/server/server.dart -o "$BUILD/bin/content_pass_server"
  dart compile exe tools/build_content_export/build_content_export.dart -o "$BUILD/bin/build_content_export"
  dart compile exe tools/build_content_seed/seed_writer.dart -o "$BUILD/bin/seed_writer"
  cp tools/build_content_export/historical_v1.json "$BUILD/bin/"
fi

say "4/5 Building the window app"
STAGE_ROOT="$BUILD/stage"
APP="$STAGE_ROOT/$APP_NAME"
rm -rf "$STAGE_ROOT"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/runtime"
swiftc -O "$HERE/mac/ContentPass.swift" -o "$APP/Contents/MacOS/Content Pass"
cp "$HERE/mac/Info.plist.template" "$APP/Contents/Info.plist"
python3 "$HERE/mac/make_icon.py" "$APP/Contents/Resources/AppIcon.icns"
cp -R "$BUILD/web" "$APP/Contents/Resources/runtime/web"
cp -R "$BUILD/bin" "$APP/Contents/Resources/runtime/bin"
codesign --force --deep --sign - "$APP"

say "5/5 Installing to $INSTALL_DIR"
if pgrep -f "Contents/MacOS/Content Pass" >/dev/null; then
  echo "Content Pass is running. Quit it, then run this again. Nothing was replaced." >&2
  echo "The new build is at $APP" >&2
  exit 2
fi
mkdir -p "$INSTALL_DIR"
NEW="$INSTALL_DIR/.Content Pass.new.app"
OLD="$INSTALL_DIR/.Content Pass.old.app"
rm -rf "$NEW" "$OLD"
cp -R "$APP" "$NEW"
[[ -e "$INSTALL_DIR/$APP_NAME" ]] && mv "$INSTALL_DIR/$APP_NAME" "$OLD"
mv "$NEW" "$INSTALL_DIR/$APP_NAME"
rm -rf "$OLD"
mdimport "$INSTALL_DIR/$APP_NAME"
sleep 1
say "Spotlight finds:"
mdfind 'kMDItemDisplayName == "Content Pass*"' || true
say "Done: $INSTALL_DIR/$APP_NAME"
