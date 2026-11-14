# Versioned web builds

Approved directly by Aedwon's November 14 implementation assignment on
web/update-at-once-r1. Supplements and supersedes only the web transport and
attempt-consumption behavior in the earlier update-at-once spec and plan.

His final ruling: "replace the web-layer approach with VERSIONED BUILD FOLDERS,
and keep the app-side safe points."

## Approved outcome

Each build has its own permanent file paths. An open old app continues reading
its own files after a deployment. Hosting keeps the new build and its two most
recent predecessors. During the first transition, hosting also keeps the old
flat files at their original paths; the next deployment drops that flat copy.
An offline app starts from a complete cached build and its matching index.

The app checks for updates on visibility return, every five minutes, and at its
existing safe points. Checks never reload. Applying an update reloads at an
existing safe point after local writes finish. Detection, slow checks and failed
checks do not consume the allowed update attempt. No new UI or storage reset.

This pass permits local implementation, verification and plain local commits.
It prohibits push, deploy and Firebase access. A pass lasts about 25 minutes;
a longer task ends on a coherent committed checkpoint with remaining work stated.

## Engineering contract

Use the existing stamped opaque version. Package all build files under `/b/v/`;
keep root index, a small loader, version metadata, manifest, icons and worker.
Publish a per-build inventory. Before deployment, a preparation tool verifies and
restores live current plus its predecessor beside the new build. Detect and test
the first legacy flat rollout explicitly; do not guess a missing published list.

The service worker caches immutable folder URLs first. Root index, loader and
version metadata use network-first with a short timeout and cache fallback.
Other origins, credential/range/no-store and unrelated requests bypass handling.
Keep current and last two folder caches. Activate immediately without client
identity messages or safe-point worker activation messages.

`pantasUpdate.check()` fetches version.json with no-store and returns
`{available, version}` compared with its running page identity. `apply()` reloads.
Keep the app coordinator's route, overlay and write-durability guards. A failed
check or application remains eligible at the next safe point.

Acceptance: failing-first Node regressions for folder startup, old deferred
bytes, hosting retention plus legacy migration, cache retention and check/apply;
Dart regressions for retry and detection; changed-Dart format, analyze lib test,
app_update tests, design lint and layering. Build staging web with a dummy site
key, package it and list the resulting folder. Serialize Flutter jobs and inspect
flutter_tester ownership. Record evidence and limits, then commit locally.
