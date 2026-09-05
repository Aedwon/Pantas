#!/usr/bin/env bash
set -euo pipefail

: "${RELEASE_E2E_SUPPORT:?missing RELEASE_E2E_SUPPORT}"
: "${RELEASE_E2E_DEVICE:?missing RELEASE_E2E_DEVICE}"
: "${RELEASE_E2E_CANDIDATE:?missing RELEASE_E2E_CANDIDATE}"
: "${RELEASE_E2E_CONTENT_SHA:?missing RELEASE_E2E_CONTENT_SHA}"
: "${RELEASE_E2E_PROJECT_ID:?missing RELEASE_E2E_PROJECT_ID}"
: "${RELEASE_E2E_AUTH_PORT:?missing RELEASE_E2E_AUTH_PORT}"
: "${RELEASE_E2E_FIRESTORE_PORT:?missing RELEASE_E2E_FIRESTORE_PORT}"
: "${RELEASE_E2E_DIAGNOSTICS:?missing RELEASE_E2E_DIAGNOSTICS}"
: "${RELEASE_E2E_RESULTS:?missing RELEASE_E2E_RESULTS}"
: "${RELEASE_E2E_FIREBASE_SCENARIOS:?missing RELEASE_E2E_FIREBASE_SCENARIOS}"

support="$RELEASE_E2E_SUPPORT"
device="$RELEASE_E2E_DEVICE"
candidate="$RELEASE_E2E_CANDIDATE"
content_sha="$RELEASE_E2E_CONTENT_SHA"
project_id="$RELEASE_E2E_PROJECT_ID"
auth_port="$RELEASE_E2E_AUTH_PORT"
firestore_port="$RELEASE_E2E_FIRESTORE_PORT"
diagnostics="$RELEASE_E2E_DIAGNOSTICS"
results="$RELEASE_E2E_RESULTS"
app_package="com.aedwon.pantas.dev"
read -r -a firebase_scenarios <<<"$RELEASE_E2E_FIREBASE_SCENARIOS"
[ "${#firebase_scenarios[@]}" -eq 2 ] || {
  printf 'release e2e firebase helper failed: expected exactly two Firebase scenarios\n' >&2
  exit 1
}

export FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:$auth_port"
export FIRESTORE_EMULATOR_HOST="127.0.0.1:$firestore_port"
export GCLOUD_PROJECT="$project_id"
export GOOGLE_CLOUD_PROJECT="$project_id"

python3 "$support" validate-emulator-isolation \
  --project-id "$project_id" \
  --auth-host "$FIREBASE_AUTH_EMULATOR_HOST" \
  --firestore-host "$FIRESTORE_EMULATOR_HOST"

pm_clear() {
  local output
  output="$(adb -s "$device" shell pm clear "$app_package")" || {
    printf 'release e2e firebase helper failed: adb pm clear failed\n' >&2
    return 1
  }
  python3 "$support" verify-pm-clear --output "$output"
}

reset_emulators() {
  python3 "$support" reset-emulators \
    --project-id "$project_id" \
    --auth-port "$auth_port" \
    --firestore-port "$firestore_port"
}

append_result() {
  python3 "$support" append-result \
    --results "$results" \
    --scenario "$1" \
    --outcome "$2" \
    --runtime-seconds "$3"
}

run_scenario() {
  local scenario="$1"
  local target="integration_test/release/$scenario"
  local log="$diagnostics/${scenario%.dart}.log"
  local started ended runtime command_status redact_status

  [[ "$scenario" =~ ^[a-z0-9_]+_e2e_test\.dart$ ]] || {
    printf 'release e2e firebase helper failed: invalid scenario name\n' >&2
    return 1
  }
  reset_emulators
  pm_clear
  started="$(date +%s)"

  set +e
  flutter test --no-pub -d "$device" --flavor dev \
    --dart-define=RELEASE_E2E_CANDIDATE="$candidate" \
    --dart-define=RELEASE_E2E_CONTENT_SHA="$content_sha" \
    --dart-define=RELEASE_E2E_FIREBASE_PROJECT_ID="$project_id" \
    --dart-define=RELEASE_E2E_AUTH_EMULATOR_HOST="$FIREBASE_AUTH_EMULATOR_HOST" \
    --dart-define=RELEASE_E2E_FIRESTORE_EMULATOR_HOST="$FIRESTORE_EMULATOR_HOST" \
    "$target" 2>&1 | python3 "$support" redact-stream --output "$log" --max-lines 500
  command_status="${PIPESTATUS[0]}"
  redact_status="${PIPESTATUS[1]}"
  set -e

  ended="$(date +%s)"
  runtime=$((ended - started))

  if [ "$redact_status" -ne 0 ]; then
    printf 'release e2e firebase helper failed: diagnostic redaction failed for %s\n' "$scenario" >&2
    reset_emulators || true
    return 1
  fi
  if [ "$command_status" -ne 0 ]; then
    append_result "$scenario" fail "$runtime"
    tail -n 80 "$log" >&2 || true
    reset_emulators || true
    printf 'release e2e firebase helper failed: scenario %s failed\n' "$scenario" >&2
    return 1
  fi

  append_result "$scenario" pass "$runtime"
  reset_emulators
}

for scenario in "${firebase_scenarios[@]}"; do
  run_scenario "$scenario"
done
pm_clear
reset_emulators
