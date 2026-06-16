#!/bin/zsh
# Double-click to wipe local data and relaunch the dev app at the first
# onboarding screen. Does NOT rebuild — use onboarding-rebuild.command after
# changing Dart code.

cd "${0:A:h}/.." || exit 1

PKG="com.aerol.csecet.dev"
AVD="pantas_pixel"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
FLUTTER="/opt/homebrew/bin/flutter"
[[ -x "$ADB" ]] || ADB="$(command -v adb)"
[[ -x "$FLUTTER" ]] || FLUTTER="$(command -v flutter)"

if [[ ! -x "$ADB" ]]; then
  echo "adb not found. Install Android platform-tools."
  read -r "?Press return to close..."
  exit 1
fi

# Bring the emulator up if nothing is attached.
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

if ! "$ADB" shell pm list packages | grep -q "$PKG"; then
  echo "$PKG is not installed — run onboarding-rebuild.command first."
  read -r "?Press return to close..."
  exit 1
fi

echo "Clearing app data..."
"$ADB" shell pm clear "$PKG" >/dev/null

# Resolve the launcher activity rather than hardcoding it — the application id
# and the Java package differ in this project.
ACTIVITY="$("$ADB" shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER "$PKG" | tail -1 | tr -d '\r')"
if [[ -z "$ACTIVITY" || "$ACTIVITY" != *"/"* ]]; then
  echo "Could not resolve the launcher activity for $PKG."
  read -r "?Press return to close..."
  exit 1
fi

echo "Launching $ACTIVITY..."
"$ADB" shell am start -n "$ACTIVITY" >/dev/null

# Confirm it actually came up; `monkey` reports success even when it does not.
for _ in {1..15}; do
  sleep 1
  if "$ADB" shell dumpsys activity activities | grep -q "$PKG/.*MainActivity.*state=RESUMED\|ResumedActivity.*$PKG"; then
    echo "Done — the app is back at 'Build your study plan'."
    sleep 1
    exit 0
  fi
done

echo "Launched, but could not confirm the app is in the foreground. Check the emulator."
read -r "?Press return to close..."
