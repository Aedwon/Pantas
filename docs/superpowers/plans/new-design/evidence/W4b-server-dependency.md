# W4b server dependency evidence
Base0c17bfb0, isolated codex/w4b-server-dependency. Technical ruling main04f184d3; later future-date Pro decision cd99f7f6 and exam-day client query73aa5b90. Root owns final integration and review.

## C9 observations
- Relay11577: new timing/version tests failed, actual fields absent and invalid values accepted.
- Relay11580: same two tests pass after optional field validation/copy.
- Relay11584: account rebound accepted and lesson endpoint absent, both new emulator tests fail.
- Relay11589: 10/10 event and accepted mock review regressions pass. Actual log build/w4b-server/events-green.log.
- Added expectedUid identity check, attributable exam/origin metadata, actual timing/version preservation, normal review seeding and idempotent earliest lesson-read observations.
- Existing correctness trust limit preserved. Legacy payload metadata remains absent.
- No published branch, deployment, visual acceptance or combined W4b acceptance claimed.

## Lead C9 review correction
Root identified actual accepted origins new_questions/flagged and attributable immutable retry after retirement. Relay11604 demonstrated both failures. Relay11606 after correction: tests12, pass12, fail0 including accepted mock due-feed regressions. Conflicting reuse fails and actual successful payload replay no longer depends on today's content. Native metrics extraction remains uncommitted; native99/99 passed at relay11632 with accepted integration assets, no combined acceptance.

## October 24 resumed continuation

Policy: origin/main `94bfe9da3fd906c720bacf9f614496736cd42187`.
Worktree HEAD is unchanged at
`2c95a9d910daf49e3526804a8a481af35b298301` on
`codex/w4b-server-dependency`. The inherited dirty patch was retained. No fetch,
pull, commit, merge, push, deployment, new dependency, or protected-content
package build occurred.

Inherited changes reviewed and exercised:
- `getStudyInsights` returns complete authored topic lesson inventory and actual
  persisted lesson read flags only with current exam coverage. Free responses
  omit topicDetails, topics and lessons. Cache revision includes the new shape;
  future read observations participate in cache validity.
- Shared-topic lesson metadata resolves its authored owning catalog, including
  lessons with no answered question. Ordering uses actual authored order.
- Deep Thinker replaces Pressure Tightener as a profile. Slow is strictly above
  the existing 12,000 ms Night Owl fast threshold. Correct answers must exceed
  incorrect answers in the existing measured split. Pressure findings remain
  tendencies. The comment explains this rule. D-80 labels and identity lines are
  updated. The bridge and its unchanged-output fixture are reconciled.
- Original RED logs for those inherited edits were not recovered. Emulator
  assertions now run and pass; this continuation does not invent prior TDD proof.

Necessary verification performance correction:
- The new future-day query repeatedly scanned the remaining calendar for every
  planned lesson day. The 200-lesson, five-year preview regression took
  `Duration:<0:01:00.553789>` against a two-second budget before correction.
- The shared query now counts study days once and subtracts one per emitted study
  day. It preserves original dates, weekdays, authored membership, quotas and
  ordering. No displayed figure or planning rule changes.
- Both worktrees contain the exact same shared source and regression. The
  existing compiled-Dart bridge was rebuilt with `server_dart/build.sh`.

Verification environment:
- Default Node was v26.10.0. The first npm run had 181 plain and 231 emulator
  passes, but exited after a Firebase CLI config/update-check write failed.
- Rerunning with installed Node 22 and the required Java 21 still reproduced the
  CLI shutdown config write issue. No elevated permissions or user config edits
  were attempted.
- Final runs use installed Node 22/Java 21 and disposable
  `XDG_CONFIG_HOME=/private/tmp/w4b-firebase-config`, with
  `NO_UPDATE_NOTIFIER=1`. This uses demo emulators without moving credentials.
  No global setting or dependency changed. Actual final output is recorded below.
- The initial native metrics/roadmap run was interrupted while the property test
  remained active at 17:38, with 311 passes. It is incomplete evidence, not a
  suite pass. Final verification follows the shared calendar-scan correction.


## October 25 continuation: final dependency checks

User-selected policy/workstream revision: `2329b9ee7d404c7e6e750ba375cf1391613c7d0f`.
Server HEAD remains `2c95a9d910daf49e3526804a8a481af35b298301`.
The entire supplied dirty patch is retained. No fetch, pull, commit, merge,
push, deploy, new dependency or protected package rebuild occurred.

The source already includes DT_Topic authored lesson/read details and public
Home Today extras. The latter carries actual previous stored day/mock status,
today's missed-work fact, stored weekdays and authored blueprint duration.
Repeated Today reads retain the actual missed-work event without exposing paid
history. Topic detail includes all authored lessons of shared topics, including
lessons with no questions, and remains absent from Free/expired responses.
The received server Dart changes and generated JS remain intact.

Independent read-only family review found one Important parity defect: server
session aggregation excluded inline lesson quizzes, although native session
windows, working-hour and session-shape readers include them. A new actual
emulator test ingests thirteen drills and one inline quiz. Before correction it
returned profile:null below the fourteen-session floor. After including inline,
it returns the earned profile and actual When you work count14/average10min.
The source revision was bumped to invalidate old derived caches after the rule
correction. No native rule, confidence threshold, paid gating or new statistic
was introduced. Focused RED relay11690 exited1 with the expected assertion;
GREEN relay11691 exited 0, 1/1 passed. Logs are build/w4b-completion/inline-*.log.

Initial final checks through relay11687:

```text
npx tsc --noEmit: exit 0
npm test: plain181/181 passed; emulator did not start (Firestore port8080 in use)
flutter test test/features/metrics test/features/roadmap: 313 tests passed
server_dart/build.sh --check: generated JS is current
```

No foreign emulator process was stopped or reused. Equivalent emulator command
with an ignored temporary config and isolated ports18080/19099/19199 passed233/233
before the inline correction (relay11688). The config preserves actual rule and
index file paths and the demo test project. Production firebase.json is unchanged.
A final post-correction full backend run follows. Relay11692's log wrapper failed
because the runner Python does not support glob(root_dir=...); no test result is
claimed for that wrapper failure. The compatible runner uses Path.glob instead.
All actual command logs are retained under build/w4b-completion/.

Shared metrics/signals and roadmap/domain sources were compared byte-for-byte
between both worktrees. They match. No independent visual, phone, deployed-callable
or live staging acceptance is claimed.


### Final dependency results

Relay11693, after the inline-session correction:

```text
cd functions && npx tsc --noEmit
exit 0

Functions plain suite (same test glob as npm test)
ℹ tests 181
ℹ pass 181
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0

Functions emulator suite (same command/test globs as npm test, isolated ports)
ℹ tests 234
ℹ pass 234
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
```

The exact npm test invocation was attempted first and its emulator start was
blocked by the occupied default Firestore port. The successful isolated run is
an explicit equivalent command, not a claim that the original exact invocation
passed. Its temporary config changes only emulator ports/UI and resolves rules
and indexes to their unchanged actual files. It does not modify firebase.json.
The Firebase SDK printed MetadataLookupWarning during isolated execution;
all 234 emulator assertions passed. No live backend result is claimed.

The 313 Dart tests and current generated-JS check above remain applicable:
the final correction touches TypeScript aggregation and its emulator test only.
No Dart source or compiled bridge input changed after those checks.

```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4b-server-dependency.md
 M functions/src/_answers.ts
 M functions/src/_examContent.ts
 M functions/src/generated/pantas_core.js
 M functions/src/ingestSession.ts
 M functions/src/roadmap.ts
 M functions/src/studyInsights.ts
 M functions/test/study-roadmap.emulator.mjs
 M lib/core/time/study_days.dart
 M lib/features/metrics/archetypes/archetype_catalog.dart
 M lib/features/metrics/archetypes/archetype_templates.dart
 M lib/features/roadmap/domain/week_preview.dart
 M server_dart/fixtures/insights_expected.json
 M test/core/time/study_days_test.dart
 M test/features/metrics/archetypes/archetype_resolver_test.dart
 M test/features/metrics/archetypes/archetype_templates_test.dart
 M test/features/metrics/providers/current_archetype_provider_test.dart
?? test/features/metrics/archetypes/archetype_identity_test.dart
?? test/features/roadmap/domain/week_preview_performance_test.dart
```

All changes remain uncommitted. Final dirty source identity, including untracked
source/tests, is retained in each worktree's completion manifest and local gate logs. The server is a dependency worktree; it was never merged into
the client.


### Configured Node 22 runtime verification

Relay11696 exited 0 with the existing Node 22.23.3 executable first on PATH,
beside Java 21.0.12.1. No runtime or dependency was installed. The prior default
host executable reports Node 26.10.0; its earlier results remain historical.
Final runtime-compatible results:

```text
node --version
v22.23.3
cd functions && npx tsc --noEmit
exit 0
npm run build
exit 0

Functions plain tests
# tests 181
# pass 181
# fail 0
# cancelled 0
# skipped 0
# todo 0

Functions emulator tests, same npm test globs on isolated ports
# tests 234
# pass 234
# fail 0
# cancelled 0
# skipped 0
# todo 0
```

Dart SDK reports 3.12.2 stable on macos_arm64. The prior 313 Dart tests and bridge
freshness check remain applicable to the unchanged Dart/JS inputs. No source
changed after this runtime verification. All 19 status entries remain uncommitted.
