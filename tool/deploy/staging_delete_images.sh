#!/bin/bash
# Deletes every container image of staging's functions: all packages in the gcf-artifacts repository
# of pantas-staging (asia-southeast1). Run it as the LAST step of a staging functions deploy
# (docs/deploy-prod.md, section 15). Artifact Registry's free tier is 0.5 GB, and one deploy leaves
# hundreds of MiB; Firebase's own cleanup policy runs about once a day, not within the hour
# (Fable 5.2 rule 7 ruling 4, Nov 15, 2026). The next deploy builds fresh images, so nothing is lost.
# The project is fixed in this file and the script takes no project argument: prod keeps its images
# for a day. Usage: tool/deploy/staging_delete_images.sh [--dry-run]
set -euo pipefail
project=pantas-staging
repo=gcf-artifacts
location=asia-southeast1
dry=false
case "${1:-}" in
  '') ;;
  --dry-run) dry=true ;;
  *) echo "usage: $0 [--dry-run] (the project is fixed to $project)" >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { echo "usage: $0 [--dry-run]" >&2; exit 2; }

packages="$(gcloud artifacts packages list --repository="$repo" --location="$location" --project="$project" --format='value(name)')"
count=0
while IFS= read -r package; do
  [ -n "$package" ] || continue
  # `name` is the full resource path; the delete command takes the package id.
  id="${package##*/}"
  if [ "$dry" = true ]; then
    echo "would delete $id"
  else
    gcloud artifacts packages delete "$id" --repository="$repo" --location="$location" --project="$project" --quiet
    echo "deleted $id"
  fi
  count=$((count + 1))
done <<<"$packages"
echo "$count package(s) in $project/$repo ($location)$([ "$dry" = true ] && echo ', dry run')"
