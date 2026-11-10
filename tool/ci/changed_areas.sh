#!/usr/bin/env bash
# Decides which CI areas a push or pull request touches. CI speed plan S6:
# docs/superpowers/plans/2026-11-08-ci-speed.md.
#
# Writes flutter=, functions= and android= (true or false) to $GITHUB_OUTPUT.
# Runs everything on main, web/design-system-4, tags, workflow_dispatch, and whenever there is no
# usable base to compare with (new branch, force push, empty diff).
#
# Inputs, from the environment: EVENT, REF, REF_TYPE, BEFORE, PR_BASE.
# Android runs only for android/** or pubspec.* (Aedwon accepted that an
# Android-only break then shows on main, not on the branch).
set -euo pipefail

out="${GITHUB_OUTPUT:-/dev/stdout}"

emit() {
  {
    echo "flutter=$1"
    echo "functions=$2"
    echo "android=$3"
  } >>"$out"
}

everything() {
  echo "Running everything: $1"
  emit true true true
  exit 0
}

[ "${EVENT:-}" = workflow_dispatch ] && everything "manual run"
[ "${REF:-}" = refs/heads/main ] && everything "main"
# The release line that staging and prod deploy from. A filtered push is
# compared only with the previous tip, so this line is always tested whole.
[ "${REF:-}" = refs/heads/web/design-system-4 ] && everything "release line"
[ "${REF_TYPE:-}" = tag ] && everything "tag"

if [ "${EVENT:-}" = pull_request ]; then
  base="${PR_BASE:-}"
else
  base="${BEFORE:-}"
fi
case "$base" in
  '' | 0000000000000000000000000000000000000000) everything "no base commit" ;;
esac
git cat-file -e "$base^{commit}" 2>/dev/null || everything "base $base is not in history"

files="$(git diff --name-only "$base" HEAD)" || everything "diff failed"
[ -n "$files" ] || everything "empty diff"
echo "Changed files since $base:"
echo "$files" | sed 's/^/  /'

# Anything that changes how a workflow behaves re-runs the Flutter and
# functions checks. Known limit: a push is compared with the previous tip, so
# an earlier red commit is not re-tested by a later push that skips its area.
workflows='^\.github/(workflows|actions)/'
rules='^(firestore\.rules|firestore\.indexes\.json|storage\.rules|firebase\.json)$'

flutter=false
functions=false
android=false
echo "$files" | grep -Eq "^(lib|test|tool|tools|content|assets|web|design)/|^pubspec\.|^(build|l10n|analysis_options)\.yaml$|$rules|$workflows" && flutter=true
echo "$files" | grep -Eq "^functions/|^content/exams/catalog\.json$|$rules|$workflows" && functions=true
echo "$files" | grep -Eq '^android/|^pubspec\.' && android=true

echo "flutter=$flutter functions=$functions android=$android"
emit "$flutter" "$functions" "$android"
