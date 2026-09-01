#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

export FLUTTER_SWIFT_PACKAGE_MANAGER=true

EXPECTED_FLUTTER_VERSION="3.41.9"
EXPECTED_FLUTTER_REF="00b0c91f06209d9e4a41f71b7a512d6eb3b9c694"
EXPECTED_GRADLE_VERSION="8.14"
EXPECTED_AGP_VERSION="8.11.1"
EXPECTED_FIREBASE_PROJECT="pantas-prod"
EXPECTED_ANDROID_PACKAGE="com.aedwon.pantas"
CONTENT_DB_PATH="$REPO_ROOT/assets/seed/content.db"
CONTENT_VERSION_SOURCE="$REPO_ROOT/lib/core/content/content_seed_version.dart"
FIREBASE_TARGET="$REPO_ROOT/android/app/src/prod/google-services.json"
LOCAL_SIGNING_PROPERTIES="$REPO_ROOT/android/key.properties"
AAB_PATH="$REPO_ROOT/build/app/outputs/bundle/prodRelease/app-prod-release.aab"

fail() {
    printf 'release preflight failed: %s\n' "$1" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "required command '$1' is not available"
}

require_env() {
    var_name="$1"
    eval "var_value=\${$var_name-}"
    [ -n "$var_value" ] || fail "required environment variable $var_name is missing"
}

sha256_file() {
    file_path="$1"
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file_path" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file_path" | awk '{print $1}'
    else
        fail "neither shasum nor sha256sum is available"
    fi
}

read_signing_property() {
    property_name="$1"
    awk -v key="$property_name" '
        index($0, key "=") == 1 {
            print substr($0, length(key) + 2)
            exit
        }
    ' "$LOCAL_SIGNING_PROPERTIES"
}

require_command flutter
require_command dart
require_command java
require_command python3

require_env RELEASE_VERSION_NAME
require_env RELEASE_VERSION_CODE
require_env REVENUECAT_ANDROID_API_KEY
require_env APPROVED_CONTENT_DB_SHA256
require_env PROD_FIREBASE_GOOGLE_SERVICES_JSON

case "$RELEASE_VERSION_NAME" in
    *[!0-9A-Za-z.+-]*|'')
        fail "RELEASE_VERSION_NAME contains unsupported characters"
        ;;
esac

case "$RELEASE_VERSION_CODE" in
    ''|*[!0-9]*)
        fail "RELEASE_VERSION_CODE must be a positive integer"
        ;;
esac
[ "$RELEASE_VERSION_CODE" -gt 0 ] || fail "RELEASE_VERSION_CODE must be greater than zero"

approved_content_sha="$(printf '%s' "$APPROVED_CONTENT_DB_SHA256" | tr '[:upper:]' '[:lower:]')"
printf '%s' "$approved_content_sha" | grep -Eq '^[0-9a-f]{64}$' || \
    fail "APPROVED_CONTENT_DB_SHA256 must be a full SHA-256 digest"

[ -f "$CONTENT_DB_PATH" ] || fail "approved assets/seed/content.db is missing"
[ -f "$CONTENT_VERSION_SOURCE" ] || fail "tracked content seed version source is missing"

actual_content_sha="$(sha256_file "$CONTENT_DB_PATH")"
[ "$actual_content_sha" = "$approved_content_sha" ] || \
    fail "assets/seed/content.db does not match the approved SHA-256"

tracked_content_prefix="$(
    python3 - "$CONTENT_VERSION_SOURCE" <<'PY'
import pathlib
import re
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.search(r"^const contentSeedVersion = '([0-9a-f]+)';$", text, re.MULTILINE)
if match is None:
    raise SystemExit(1)
print(match.group(1))
PY
)" || fail "could not read the tracked content seed version"

printf '%s' "$tracked_content_prefix" | grep -Eq '^[0-9a-f]{8,64}$' || \
    fail "tracked content seed version is not a valid SHA-256 prefix"
case "$actual_content_sha" in
    "$tracked_content_prefix"*) ;;
    *) fail "approved content DB does not match the tracked content seed version" ;;
esac

firebase_source="$PROD_FIREBASE_GOOGLE_SERVICES_JSON"
[ -f "$firebase_source" ] || fail "production Firebase google-services.json source is missing"
python3 - "$firebase_source" "$EXPECTED_FIREBASE_PROJECT" "$EXPECTED_ANDROID_PACKAGE" <<'PY' || \
    fail "production Firebase config does not match pantas-prod / com.aedwon.pantas"
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
expected_project = sys.argv[2]
expected_package = sys.argv[3]
try:
    data = json.loads(path.read_text(encoding="utf-8"))
except (OSError, UnicodeDecodeError, json.JSONDecodeError):
    raise SystemExit(1)

if data.get("project_info", {}).get("project_id") != expected_project:
    raise SystemExit(1)
clients = data.get("client")
if not isinstance(clients, list):
    raise SystemExit(1)
for client in clients:
    package_name = (
        client.get("client_info", {})
        .get("android_client_info", {})
        .get("package_name")
    )
    if package_name == expected_package:
        break
else:
    raise SystemExit(1)
PY

cm_signing_count=0
for name in CM_KEYSTORE_PATH CM_KEYSTORE_PASSWORD CM_KEY_ALIAS CM_KEY_PASSWORD; do
    eval "value=\${$name-}"
    if [ -n "$value" ]; then
        cm_signing_count=$((cm_signing_count + 1))
    fi
done

if [ "$cm_signing_count" -gt 0 ] && [ "$cm_signing_count" -lt 4 ]; then
    fail "Codemagic signing is incomplete; set all four CM signing inputs"
fi

if [ "$cm_signing_count" -eq 4 ]; then
    [ -f "$CM_KEYSTORE_PATH" ] || fail "CM_KEYSTORE_PATH does not point to a file"
else
    [ -f "$LOCAL_SIGNING_PROPERTIES" ] || \
        fail "production signing is missing; provide android/key.properties or all CM signing inputs"
    local_store_file="$(read_signing_property storeFile)"
    local_store_password="$(read_signing_property storePassword)"
    local_key_alias="$(read_signing_property keyAlias)"
    local_key_password="$(read_signing_property keyPassword)"
    [ -n "$local_store_file" ] && [ -n "$local_store_password" ] && \
        [ -n "$local_key_alias" ] && [ -n "$local_key_password" ] || \
        fail "android/key.properties must define storeFile, storePassword, keyAlias, and keyPassword"
    case "$local_store_file" in
        /*) local_keystore_path="$local_store_file" ;;
        *) local_keystore_path="$REPO_ROOT/android/$local_store_file" ;;
    esac
    [ -f "$local_keystore_path" ] || fail "android/key.properties storeFile does not exist"
fi

flutter_machine="$(flutter --version --machine)" || fail "flutter --version failed"
FLUTTER_MACHINE="$flutter_machine" python3 - "$EXPECTED_FLUTTER_VERSION" "$EXPECTED_FLUTTER_REF" <<'PY' || \
    fail "Flutter must be exactly 3.41.9 at the pinned official release ref"
import json
import os
import sys

expected_version = sys.argv[1]
expected_ref = sys.argv[2]
try:
    data = json.loads(os.environ["FLUTTER_MACHINE"])
except (KeyError, json.JSONDecodeError):
    raise SystemExit(1)
if data.get("frameworkVersion") != expected_version:
    raise SystemExit(1)
if data.get("frameworkRevision") != expected_ref:
    raise SystemExit(1)
PY

java_version_line="$(java -version 2>&1 | head -n 1)" || fail "java -version failed"
printf '%s\n' "$java_version_line" | grep -Eq 'version "17([._+]|\")' || \
    fail "JDK 17 is required"

[ -f "$REPO_ROOT/android/gradlew" ] || fail "android/gradlew is missing"
[ -f "$REPO_ROOT/android/gradle/wrapper/gradle-wrapper.jar" ] || \
    fail "Gradle wrapper JAR is missing"
[ -x "$REPO_ROOT/android/gradlew" ] || fail "android/gradlew is not executable"

gradle_version_output="$(cd "$REPO_ROOT/android" && ./gradlew --version)" || \
    fail "Gradle wrapper could not run"
printf '%s\n' "$gradle_version_output" | grep -Eq "^Gradle ${EXPECTED_GRADLE_VERSION}$" || \
    fail "Gradle wrapper must resolve exactly Gradle 8.14"

grep -Fq "id(\"com.android.application\") version \"$EXPECTED_AGP_VERSION\"" \
    "$REPO_ROOT/android/settings.gradle.kts" || fail "AGP must remain pinned to 8.11.1"

firebase_source_real="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$firebase_source")"
firebase_target_real="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$FIREBASE_TARGET")"
staged_firebase=0
cleanup_private_inputs() {
    if [ "$staged_firebase" -eq 1 ]; then
        rm -f "$FIREBASE_TARGET"
    fi
}
trap cleanup_private_inputs EXIT INT TERM

if [ "$firebase_source_real" != "$firebase_target_real" ]; then
    [ ! -e "$FIREBASE_TARGET" ] || \
        fail "staged production Firebase target already exists; use it as the source or remove it manually"
    mkdir -p "$(dirname "$FIREBASE_TARGET")"
    cp "$firebase_source" "$FIREBASE_TARGET"
    chmod 600 "$FIREBASE_TARGET" 2>/dev/null || true
    staged_firebase=1
fi

printf 'release preflight: inputs, signing, Firebase, content, Flutter, Java, Gradle, and AGP validated\n'

flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

flutter build appbundle \
    --release \
    --flavor prod \
    --target lib/main_prod.dart \
    --build-name "$RELEASE_VERSION_NAME" \
    --build-number "$RELEASE_VERSION_CODE" \
    --dart-define=BUILD_NUMBER="$RELEASE_VERSION_CODE" \
    --dart-define=REVENUECAT_ANDROID_API_KEY="$REVENUECAT_ANDROID_API_KEY"

[ -f "$AAB_PATH" ] || fail "expected production AAB was not produced"
aab_sha="$(sha256_file "$AAB_PATH")"
printf 'release build complete: %s\n' "${AAB_PATH#$REPO_ROOT/}"
printf 'AAB SHA-256: %s\n' "$aab_sha"
