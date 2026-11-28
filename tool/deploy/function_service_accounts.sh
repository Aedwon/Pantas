#!/usr/bin/env bash
# Creates the five Cloud Functions runtime service accounts and grants each only what its functions need
# (M4 security pass, part 2; plan docs/superpowers/plans/2026-11-22-m4-security-pass.md). Which function
# runs as which account is in functions/src/serviceAccounts.ts. Idempotent: rerunning changes nothing.
#
# Usage: tool/deploy/function_service_accounts.sh pantas-staging|pantas-prod [--dry-run]
#
# This only adds accounts and grants. It never removes a role from the default compute account; removing
# its Editor role is a separate, logged step after a clean day on the new accounts.
set -euo pipefail
project="${1:?pantas-staging or pantas-prod}"
case "$project" in pantas-staging|pantas-prod) ;; *) echo "pantas-staging or pantas-prod" >&2; exit 2;; esac
dry=false; [ "${2:-}" = "--dry-run" ] && dry=true
run() { if $dry; then echo "would run: $*"; else "$@" >/dev/null; echo "ok: $*" | cut -c1-160; fi; }

bucket="$project.firebasestorage.app"
sa() { echo "$1@$project.iam.gserviceaccount.com"; }

# 1. Accounts.
for name in pantas-app pantas-entitlements pantas-payments pantas-identity pantas-jobs; do
  if gcloud iam service-accounts describe "$(sa $name)" --project "$project" >/dev/null 2>&1; then
    echo "exists: $(sa $name)"
  else
    run gcloud iam service-accounts create "$name" --project "$project" --display-name "Functions: $name (M4)"
  fi
done

# 2. Custom Auth roles, narrower than roles/firebaseauth.admin (no config, sessions or email sending).
role() { # id title permissions
  if gcloud iam roles describe "$1" --project "$project" >/dev/null 2>&1; then
    run gcloud iam roles update "$1" --project "$project" --permissions "$3" --quiet
  else
    run gcloud iam roles create "$1" --project "$project" --title "$2" --permissions "$3" --stage GA --quiet
  fi
}
role pantasAuthReadUpdate "Pantas: read and update Auth users" firebaseauth.users.get,firebaseauth.users.update
role pantasAuthUsers "Pantas: manage Auth users" firebaseauth.users.get,firebaseauth.users.create,firebaseauth.users.update,firebaseauth.users.delete
role pantasAuthJobs "Pantas: read, update and delete Auth users" firebaseauth.users.get,firebaseauth.users.update,firebaseauth.users.delete

# 3. Project roles.
grant() { run gcloud projects add-iam-policy-binding "$project" --member "serviceAccount:$(sa $1)" --role "$2" --condition None --quiet; }
for name in pantas-app pantas-entitlements pantas-payments pantas-identity pantas-jobs; do grant $name roles/datastore.user; done
for name in pantas-app pantas-entitlements pantas-payments pantas-identity; do grant $name roles/firebaseappcheck.tokenVerifier; done
grant pantas-app roles/firebaseauth.viewer
grant pantas-entitlements "projects/$project/roles/pantasAuthReadUpdate"
grant pantas-payments "projects/$project/roles/pantasAuthReadUpdate"
grant pantas-identity "projects/$project/roles/pantasAuthUsers"
grant pantas-jobs "projects/$project/roles/pantasAuthJobs"
# Scheduled jobs and the user-created trigger: Scheduler and Eventarc call the services as this account.
grant pantas-jobs roles/run.invoker
grant pantas-jobs roles/eventarc.eventReceiver

# 4. Secrets, each on its own secret only.
secret() { run gcloud secrets add-iam-policy-binding "$2" --project "$project" --member "serviceAccount:$(sa $1)" --role roles/secretmanager.secretAccessor --condition None --quiet; }
secret pantas-payments PANTAS_PAYMENT_SECRETS
secret pantas-identity PANTAS_APP_SECRETS
secret pantas-jobs PANTAS_APP_SECRETS

# 5. The default Storage bucket.
bucketRole() { run gcloud storage buckets add-iam-policy-binding "gs://$bucket" --member "serviceAccount:$(sa $1)" --role "$2" --quiet; }
bucketRole pantas-app roles/storage.objectViewer
bucketRole pantas-identity roles/storage.objectAdmin
bucketRole pantas-jobs roles/storage.objectAdmin

# 6. Custom sign-in tokens: pantas-identity signs them with its own key (signBlob on itself only).
run gcloud iam service-accounts add-iam-policy-binding "$(sa pantas-identity)" --project "$project" \
  --member "serviceAccount:$(sa pantas-identity)" --role roles/iam.serviceAccountTokenCreator --quiet

echo "done: $project ($($dry && echo dry run || echo applied))"
