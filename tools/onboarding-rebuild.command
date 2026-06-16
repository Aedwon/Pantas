#!/bin/zsh
# Double-click to wipe local data, rebuild from source, and run the dev app at
# the first onboarding screen. Leaves `flutter run` attached in this Terminal
# window, so r = hot reload, R = hot restart, q = quit.

cd "${0:A:h}/.." || exit 1

PKG="com.aerol.csecet.dev"
AVD="pantas_pixel"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
FLUTTER="/opt/homebrew/bin/flutter"
[[ -x "$ADB" ]] || ADB="$(command -v adb)"
[[ -x "$FLUTTER" ]] || FLUTTER="$(command -v flutter)"

if [[ ! -x "$FLUTTER" || ! -x "$ADB" ]]; then
  echo "flutter or adb not found on PATH."
  read -r "?Press return to close..."
  exit 1
fi

if ! "$ADB" devices | grep -q "device$"; then
  echo "No device attached — launching $AVD..."
  "$FLUTTER" emulators --launch "$AVD" >/dev/null 2>&1
  "$ADB" wait-for-device
  echo -n "Waiting for boot"
  until [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    echo -n "."
    sleep 2
  done
  echo
fi

echo "Clearing app data..."
"$ADB" shell pm clear "$PKG" >/dev/null 2>&1

echo "Building and running — first build takes a couple of minutes."
exec "$FLUTTER" run --flavor dev -t lib/main_dev.dart
