#!/bin/bash
# Drops the Cloud Run request log entries of the speed and error report function, which are
# the only log entries that hold the caller's IP address and full browser string. The report's
# own log line never held either. Privacy batch, spec choice 9 (Nov 9, 2026).
#
# Staged config: run only at deploy, with Aedwon's approval, once per project.
#   tool/deploy/telemetry_log_exclusion.sh pantas-staging
#   tool/deploy/telemetry_log_exclusion.sh pantas-prod
# Then check: tool/deploy/telemetry_log_exclusion.sh <project> --verify
# (prints the newest request entry for the function; nothing newer than the exclusion time means it works).
set -euo pipefail
project=${1:?usage: telemetry_log_exclusion.sh <project> [--verify]}
case "$project" in pantas-staging|pantas-prod) ;; *) echo "unknown project: $project" >&2; exit 2;; esac
name=drop-telemetry-request-logs
filter='resource.type="cloud_run_revision" AND resource.labels.service_name="reportclienttelemetry" AND log_id("run.googleapis.com/requests")'

if [ "${2:-}" = "--verify" ]; then
  gcloud logging sinks describe _Default --project="$project" --format='value(exclusions)' | grep -q "$name" \
    || { echo "exclusion $name is missing on $project" >&2; exit 1; }
  gcloud logging read "$filter" --project="$project" --freshness=2h --limit=1 --format='value(timestamp)'
  exit 0
fi

if gcloud logging sinks describe _Default --project="$project" --format='value(exclusions)' | grep -q "$name"; then
  echo "exclusion $name already present on $project"
  exit 0
fi
gcloud logging sinks update _Default --project="$project" --add-exclusion="name=$name,filter=$filter"
echo "added $name on $project at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
