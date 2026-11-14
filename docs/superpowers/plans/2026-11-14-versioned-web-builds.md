# Versioned web builds replacement

Approved spec: ../specs/2026-11-14-versioned-web-builds.md.
Aedwon's November 14 assignment replaces the web
client-version protocol from 4e61f0e74, retaining safe points from 46adf8a0f.
Policy main: 05d90fdc4fd7f42af35250a29737a2ad38e03fdd.
Estimate: 25 minutes per pass. Timer: web-version-folders. No push, deploy or
Firebase access. Existing worktree web/update-at-once-r1. Non-UI only.

1. Replace protocol tests with failing path-based worker, loader, update API and
   inventory/retention tests. Add coordinator retry regressions before changes.
2. Stamp the existing opaque build version; package all build files under b/v.
   Pin index helper scripts and bootstrap to v. A small root loader reads the
   index's pinned version, so cached index and fresh loader cannot mix builds.
   Flutter config uses entrypointBaseUrl, assetBase and canvasKitBaseUrl.
   Database opener reads the same versioned base, retaining test overrides.
3. Add predeploy retention CLI: download live current and predecessor inventory
   with hashes, preserve those two folders beside the new build. For first
   rollout explicitly recover flat files using Flutter's published RESOURCES
   inventory and hashes. Fail closed on missing/invalid files. The next fresh
   build drops these legacy root files. Persist current plus last two identities
   in version.json and the worker. Never deploy from this job.
4. Replace worker with immutable folder cache-first and timed network-first root
   index/loader/version. Bypass other origins, auth, ranges, no-store and private
   responses. Precache index and current build for offline opening. Activate
   immediately; delete only folder caches outside the retained version list.
5. Simplify check to no-store version comparison, apply to reload. Retain five
   minute and visibility checks without automatic reload. Consume coordinator
   attempt only after successful apply, retry check/apply failures at safe points.
6. Run Node suites, app_update VM tests, changed Dart format, analyze lib test,
   design lint, layering, repository checks, one release staging build with dummy
   site key, then stamp and list layout. Serialize Flutter jobs and inspect
   flutter_tester processes. Independent review, evidence/status, local commit.

Files: web/{flutter_bootstrap.js,pantas_pwa.js,pantas_sw.js}, tool/web/*,
lib/core/platform/app_update/update_coordinator.dart,
lib/core/storage/data/database_opener_web.dart, test/core/platform/app_update/*,
test/web/{stamp_worker_version,pantas_pwa}.test.mjs, tool/deploy/staging_web.sh,
web/README.md, relevant decision/verification/status/estimate documents.
No new dependency, UI, data schema, entitlement or protected-content change.

Implementation review refinements within approved scope:
- Only a completely verified cached folder may replace the offline index.
- First-rollout legacy files are also cached before takeover for offline sessions.
- Existing CSS font URLs are pinned with helper scripts, preserving appearance.
- Previously stamped flat metadata is distinguished by absence of folder retention.
- Version checks time out across fetch and JSON, then permit safe-point retries.
- Flutter retains custom output directories. Discard stale b/ before packaging;
  the retention tool alone restores verified live predecessors.
- Root loader falls back to its stamped version only for a cached legacy index
  without a version attribute. Versioned indices always select their own folder.
- Verification file scope includes test/core/storage/data/database_opener_web_test.dart:
  exercise the real opener's default URLs with the running build base in Chromium.
