#!/usr/bin/env bash
set -euo pipefail

export FLUTTER_SWIFT_PACKAGE_MANAGER=true

candidate=""
content_sha=""
device=""
diagnostics=""
results_file=""
summary_written=0
state_touched=0
ports_allocated=0
auth_port=""
firestore_port=""
run_started="$(date +%s)"

fail() {
  printf 'release e2e runner failed: %s\n' "$1" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --candidate)
      [ "$#" -ge 2 ] || fail "--candidate requires a value"
      [ -z "$candidate" ] || fail "--candidate may be supplied only once"
      candidate="$2"
      shift 2
      ;;
    --content-sha)
      [ "$#" -ge 2 ] || fail "--content-sha requires a value"
      [ -z "$content_sha" ] || fail "--content-sha may be supplied only once"
      content_sha="$2"
      shift 2
      ;;
    --device)
      [ "$#" -ge 2 ] || fail "--device requires a value"
      [ -z "$device" ] || fail "--device may be supplied only once"
      device="$2"
      shift 2
      ;;
    *)
      fail "unknown or extra argument: $1"
      ;;
  esac
done

[ -n "$candidate" ] || fail "--candidate is required"
[ -n "$content_sha" ] || fail "--content-sha is required"
[ -n "$device" ] || fail "--device is required"
[[ "$candidate" =~ ^[0-9a-fA-F]{40}$ ]] || fail "candidate must be a full 40-character Git SHA"
[[ "$content_sha" =~ ^[0-9a-fA-F]{64}$ ]] || fail "content hash must be a full 64-character SHA-256"
[[ "$device" =~ ^[^[:space:]]+$ ]] || fail "device must be one explicit ADB serial"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
cd "$repo_root"
support="$repo_root/tools/release/e2e/runner_support.py"
firebase_helper="$repo_root/tools/release/e2e/run_firebase_scenarios.sh"
app_package="com.aedwon.pantas.dev"
firebase_scenarios=(
  firebase_sync_roundtrip_e2e_test.dart
  firebase_conflict_isolation_e2e_test.dart
)

command -v python3 >/dev/null 2>&1 || fail "python3 is required for runner support"
[ -f "$support" ] || fail "runner support helper is missing"
[ -f "$firebase_helper" ] || fail "Firebase scenario helper is missing"
: "${PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64:?missing PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64}"
export PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64


# Preflight is intentionally complete before diagnostics, state clearing, app launch,
# or emulator startup. Any provenance failure leaves the target untouched.
preflight_json="$(
  python3 "$support" preflight \
    --repo-root "$repo_root" \
    --candidate "$candidate" \
    --content-sha "$content_sha" \
    --device "$device"
)" || fail "preflight rejected provenance, toolchain, content, or device state"

if ! dart run tools/verify_content_package/verify_content_package.dart \
  assets/seed/content.db \
  assets/seed/content.manifest.json \
  assets/seed/content.manifest.sig >/dev/null 2>&1; then
  fail "protected content package verification failed"
fi


run_tag="$(date -u +%Y%m%dT%H%M%SZ)-$$"
diagnostics="$repo_root/build/release-e2e/$run_tag"
python3 "$support" prepare-diagnostics --path "$diagnostics" >/dev/null || fail "could not create diagnostics directory"
results_file="$diagnostics/results.jsonl"
: > "$results_file"
printf '%s\n' "$preflight_json" > "$diagnostics/provenance.json" || fail "could not record provenance"

write_summary() {
  local outcome="$1"
  local now total
  now="$(date +%s)"
  total=$((now - run_started))
  python3 "$support" write-summary \
    --results "$results_file" \
    --json-output "$diagnostics/summary.json" \
    --text-output "$diagnostics/summary.txt" \
    --candidate "$candidate" \
    --content-sha "$content_sha" \
    --device "$device" \
    --total-runtime-seconds "$total" \
    --outcome "$outcome"
}

pm_clear() {
  local output
  state_touched=1
  output="$(adb -s "$device" shell pm clear "$app_package")" || return 1
  python3 "$support" verify-pm-clear --output "$output"
}

wait_ports_free() {
  local ok=0
  if [ "$ports_allocated" -eq 1 ]; then
    python3 "$support" wait-port-free --port "$auth_port" --deadline-ms 5000 || ok=1
    python3 "$support" wait-port-free --port "$firestore_port" --deadline-ms 5000 || ok=1
  fi
  return "$ok"
}

cleanup_on_exit() {
  local original_status="$?"
  local cleanup_status=0
  trap - EXIT INT TERM
  set +e
  if [ "$state_touched" -eq 1 ]; then
    local clear_output
    clear_output="$(adb -s "$device" shell pm clear "$app_package" 2>/dev/null)"
    if [ "$?" -ne 0 ] || ! python3 "$support" verify-pm-clear --output "$clear_output" >/dev/null 2>&1; then
      cleanup_status=1
      printf 'release e2e runner cleanup failed: app state could not be cleared\n' >&2
    fi
  fi
  if ! wait_ports_free; then
    cleanup_status=1
    printf 'release e2e runner cleanup failed: emulator port did not become free\n' >&2
  fi
  if [ "$original_status" -ne 0 ] && [ -n "$diagnostics" ] && [ "$summary_written" -eq 0 ]; then
    if write_summary fail; then
      summary_written=1
    else
      cleanup_status=1
      printf 'release e2e runner cleanup failed: failure summary could not be written\n' >&2
    fi
  fi
  if [ "$original_status" -ne 0 ] || [ "$cleanup_status" -ne 0 ]; then
    exit 1
  fi
  exit 0
}
trap cleanup_on_exit EXIT INT TERM

ports_json="$(python3 "$support" allocate-ports)" || fail "could not allocate emulator ports"
auth_port="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["auth_port"])' <<<"$ports_json")" || fail "could not parse Auth emulator port"
firestore_port="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["firestore_port"])' <<<"$ports_json")" || fail "could not parse Firestore emulator port"
ports_allocated=1
python3 "$support" check-ports --auth-port "$auth_port" --firestore-port "$firestore_port" || fail "emulator port isolation failed"

project_id="demo-pantas-release-e2e-$run_tag"
auth_host="127.0.0.1:$auth_port"
firestore_host="127.0.0.1:$firestore_port"
python3 "$support" validate-emulator-isolation \
  --project-id "$project_id" \
  --auth-host "$auth_host" \
  --firestore-host "$firestore_host" || fail "Firebase emulator isolation failed"

firebase_config="$diagnostics/firebase.json"
python3 "$support" write-firebase-config \
  --output "$firebase_config" \
  --rules "$repo_root/firestore.rules" \
  --indexes "$repo_root/firestore.indexes.json" \
  --auth-port "$auth_port" \
  --firestore-port "$firestore_port" || fail "could not create isolated Firebase emulator config"

append_result() {
  python3 "$support" append-result \
    --results "$results_file" \
    --scenario "$1" \
    --outcome "$2" \
    --runtime-seconds "$3"
}

run_local_scenario() {
  local scenario="$1"
  local target="integration_test/release/$scenario"
  local log="$diagnostics/${scenario%.dart}.log"
  local started ended runtime command_status redact_status

  pm_clear || fail "adb pm clear failed before $scenario"
  started="$(date +%s)"
  set +e
  flutter test --no-pub -d "$device" --flavor dev \
    --dart-define=RELEASE_E2E_CANDIDATE="$candidate" \
    --dart-define=RELEASE_E2E_CONTENT_SHA="$content_sha" \
    --dart-define=RELEASE_E2E_LOCAL_ONLY=true \
    --dart-define=PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64="$PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64" \
    "$target" 2>&1 | python3 "$support" redact-stream --output "$log" --max-lines 500
  command_status="${PIPESTATUS[0]}"
  redact_status="${PIPESTATUS[1]}"
  set -e
  ended="$(date +%s)"
  runtime=$((ended - started))

  [ "$redact_status" -eq 0 ] || fail "diagnostic redaction failed for $scenario"
  if [ "$command_status" -ne 0 ]; then
    append_result "$scenario" fail "$runtime" || fail "could not record failed scenario result"
    tail -n 80 "$log" >&2 || true
    fail "scenario $scenario failed"
  fi
  append_result "$scenario" pass "$runtime" || fail "could not record scenario result"
}

run_local_scenario shipping_cold_start_e2e_test.dart
run_local_scenario quiz_state_e2e_test.dart
run_local_scenario mock_resume_e2e_test.dart
run_local_scenario delete_local_data_e2e_test.dart

export RELEASE_E2E_SUPPORT="$support"
export RELEASE_E2E_DEVICE="$device"
export RELEASE_E2E_CANDIDATE="$candidate"
export RELEASE_E2E_CONTENT_SHA="$content_sha"
export RELEASE_E2E_PROJECT_ID="$project_id"
export RELEASE_E2E_AUTH_PORT="$auth_port"
export RELEASE_E2E_FIRESTORE_PORT="$firestore_port"
export RELEASE_E2E_DIAGNOSTICS="$diagnostics"
export RELEASE_E2E_RESULTS="$results_file"
export RELEASE_E2E_FIREBASE_SCENARIOS="${firebase_scenarios[*]}"

state_touched=1
firebase_log="$diagnostics/firebase-emulators.log"
set +e
firebase emulators:exec \
  --only auth,firestore \
  --project "$project_id" \
  --config "$firebase_config" \
  "bash tools/release/e2e/run_firebase_scenarios.sh" 2>&1 | \
  python3 "$support" redact-stream --output "$firebase_log" --max-lines 700
firebase_status="${PIPESTATUS[0]}"
redact_status="${PIPESTATUS[1]}"
set -e
[ "$redact_status" -eq 0 ] || fail "Firebase emulator diagnostic redaction failed"
if [ "$firebase_status" -ne 0 ]; then
  tail -n 80 "$firebase_log" >&2 || true
  fail "Firebase emulator scenario group failed"
fi

wait_ports_free || fail "Firebase emulators did not shut down cleanly"
ports_allocated=0
pm_clear || fail "final app-state cleanup failed"
state_touched=0

write_summary pass || fail "final summary write failed"
summary_written=1
cat "$diagnostics/summary.txt"
trap - EXIT INT TERM
