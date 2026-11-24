#!/bin/bash
# Turns off every Firestore TTL policy of pantas-staging. TTL deletes have no free tier (catalog SKU
# "Cloud Firestore TTL Deletes Singapore", $0.0123 per 100,000 from the first delete), while ordinary
# deletes get 20,000 free a day, so staging runs no TTL policy (rule 7; security and billing lead
# ruling, Nov 24, 2026). firestore.indexes.json turns TTL back on: run this script after any staging
# deploy that includes Firestore indexes (docs/deploy-prod.md, section 15). Prod keeps its policies,
# because real users cause those deletes.
# The project is fixed in this file and the script takes no project argument.
# Usage: tool/deploy/staging_disable_ttl.sh [--dry-run]
set -euo pipefail
project=pantas-staging
dry=false
case "${1:-}" in
  '') ;;
  --dry-run) dry=true ;;
  *) echo "usage: $0 [--dry-run] (the project is fixed to $project)" >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { echo "usage: $0 [--dry-run]" >&2; exit 2; }

# One "<collection-group> <field>" pair per line.
fields="$(gcloud firestore fields ttls list --project="$project" --format='value(name.segment(-3),name.segment(-1))')"
count=0
failed=0
while read -r group field; do
  [ -n "$group" ] || continue
  if [ "$dry" = true ]; then
    echo "would disable $group.$field"
  elif gcloud firestore fields ttls update "$field" --collection-group="$group" --disable-ttl --project "$project" --async --quiet; then
    echo "disabled $group.$field"
  else
    echo "FAILED to disable $group.$field" >&2
    failed=$((failed + 1))
  fi
  count=$((count + 1))
done <<<"$fields"
echo "$count TTL policy(ies) in $project$([ "$dry" = true ] && echo ', dry run'), $failed failed"
[ "$failed" -eq 0 ]
