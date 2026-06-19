# Content delivery, and how new questions reach a student who already has the app

**Date:** 3 August 2026
**Status:** Written to Aedwon's instruction of 3 August. Delivery mechanism chosen by him:
content ships with app updates.
**Why it exists:** `Seeder.maybeSeed()` returns immediately when the exams table is not
empty, so **an app update carrying new content reaches nobody who already has the app
installed.** Found 3 August during the plan audit. It is in no other spec.

This spec describes the destination. It assumes nothing in the tree survives.

---

## Section 1: The decision, and why it is right

**Content ships inside the app build. There is no over-the-air content download.**
Aedwon's call, 3 August.

**It is the right call and the numbers support it.** Measured from `assets/seed/v1.json` on
3 August:

| | Count | Total | Each |
|---|---|---|---|
| Questions | 1,117 | 1.18 MB | **1.09 KB** |
| Lessons | 144 | 2.29 MB | 16.29 KB |
| Topics | 19 | 2 KB | 0.12 KB |
| Exams | 7 | 2 KB | 0.25 KB |

A hundred new questions is roughly **110 KB** of JSON before compression, and Play ships
delta updates on top of that. Storage and bandwidth are not a constraint at this size and
will not become one at ten times it.

**What bundling buys**, and it is the reason to prefer it: content is available the instant
the app opens, offline, with no fetch, no cache, no staleness, no failure mode, and no
server. It is consistent with Section 1 of the offline spec.

**What it costs:** new content requires an app update and a store review. A wrong answer
cannot be corrected in an hour. That is accepted.

## Section 2: The defect, stated exactly

`lib/core/storage/data/seeder.dart:14`:

```dart
final existing = await _db.select(_db.exams).get();
if (existing.isNotEmpty) return;
```

The seed is a **first-run install**, not an update. Consequences today:

1. A student who installed in July and updates in September gets the new `v1.json` in the
   bundle and **zero new questions in the app**.
2. A corrected question stays wrong forever on every device that already has it.
3. `Questions.version` exists as a column and nothing reads it. It was put there for exactly
   this and never wired.
4. The only way any student gets new content is to uninstall and reinstall, which destroys
   their local progress, so the workaround is worse than the defect.

**Every content pass in the launch checklist is undeliverable until this is fixed.** That
includes the ten authored reasoning files, all of Mathematics, and the `lessonId` and
`rationale` passes.

## Section 3: The seed carries a version, and the app remembers it

The JSON already carries `schemaVersion` and `generatedAt` at its root. **Add
`contentVersion`, a monotonically increasing integer**, bumped by `tools/build_dev_seed` on
every build.

The app stores the last applied `contentVersion` in device preferences, not account
preferences: it describes this installation's database, not the student.

**On every launch:**

| Stored version | Bundled version | What happens |
|---|---|---|
| absent | any | Full seed, as today |
| equal | equal | Nothing. This is the common case and it must cost one preference read. |
| lower | higher | **Upgrade pass**, Section 4 |
| higher | lower | Nothing, and log it. A downgrade means a sideloaded or rolled-back build; refusing is safer than rewriting content backward. |

## Section 4: The upgrade pass, and the line it must not cross

**The upgrade pass writes content. It never writes progress.**

| Table | On upgrade |
|---|---|
| `exams`, `subjects`, `topics`, `lessons`, `questions` | Upserted from the bundle |
| `attempts_local` | **Untouched** |
| `review_state_local` | **Untouched** |
| flags, bookmarks, sessions, mock attempts, settings | **Untouched** |

That table is the whole safety property and it is what the tests must assert. A student's
history is theirs; the content is ours.

**Upsert, keyed on the row's own id.** A question whose `version` is higher in the bundle
than in the database is replaced in place. Its id does not change, so every attempt, every
review state and every flag pointing at it still points at it.

**A revised question keeps its id.** This is a rule for the content pipeline, not just the
app: fixing a typo, correcting an answer or rewriting an explanation is a `version` bump on
the same id. Minting a new id would orphan the student's history with that question and
silently reset its scheduling.

## Section 5: Withdrawal, which is the hard case

A question that is wrong beyond repair has to leave. Deleting the row is not available: the
student's attempts reference it, and the Progress table, the review screens and the flagged
list would all render a hole.

**A withdrawn question is marked, not deleted.**

- The bundle omits it, or marks it withdrawn. The app sets a flag on the existing row.
- **A withdrawn question is never served again**: not by a session, not by a drill, not by a
  mock, not by the scheduler.
- **It stays visible in history.** A review screen or a Progress figure that already counted
  it keeps counting it, because the student really did answer it and hiding that would make
  their own numbers change under them, which Section 1 of the Progress spec forbids.
- **It is never presented as withdrawn.** No badge, no strikethrough, no note. The student is
  not owed an explanation of our editorial process.

## Section 6: When the pass runs, and what the student sees

**It runs at bootstrap, before the first frame, in one transaction.**

**The student sees nothing.** No progress bar, no "updating content", no splash extension
that is longer than it has to be. At 100 to 200 KB of parsed JSON and an upsert into a local
database this is well under the frame budget of a cold start that is already doing Firebase
initialization.

**If the pass fails, the app opens on the old content.** It does not open on a broken
database and it does not refuse to open. The stored version is only advanced after the
transaction commits, so a failed pass retries on the next launch. That is the whole recovery
story and it needs no UI.

## Section 7: First-run cost, which is unmeasured

Recorded here because it belongs to the same code path and nobody has timed it. The full
first-run seed inserts 1,117 questions and 144 lessons from a 6.3 MB asset, and it grows with
every subject Aedwon generates.

**Measure it before launch, on the lowest device you are willing to support.** If a cold
first launch is slow enough to read as broken, the fix is a pre-built database shipped as an
asset instead of a JSON parse, which is what `assets/seed/content.db` and `SeedInstaller`
were originally for. **Do not build that until it is measured.** It is a real option, not a
foregone one.

## Section 8: The other content path, which this spec does not adopt

`assets/seed/content.db` and `SeedInstaller` are a second, unfinished delivery mechanism with
stale-copy replacement logic already written, and `contentDatabaseProvider` throws.
`plans/2026-08-02-content-seed-delivery.md` finishes it.

**These two paths must not both be live.** Today the app reads `v1.json` through `Seeder` and
nothing reads `content.db`. This spec makes `v1.json` the delivery path for questions and
lessons, and leaves `content.db` to the Sanity stack for **blueprints and mock papers**,
which is what the mock plans actually need from it.

**Whoever executes `content-seed-delivery` must read this section first**, because the two
plans otherwise both claim to own content delivery and neither says which content.

## Section 9: Evidentiary tier

Nothing in this spec prints a figure to a student. `contentVersion` is internal and never
displayed. The counts in Section 1 are measured from the seed and are stated to Aedwon, not
to a student.

## Deferred, with reasons

- **Over-the-air content.** Chosen against, Section 1. Revisit if a wrong answer ever has to
  be pulled within hours rather than within a release.
- **Per-exam content packs.** Nothing is heavy enough to warrant splitting the bundle.
- **A "what's new" screen after an update.** Content arriving quietly is correct. Revisit
  only when there is a subject-sized addition worth announcing.
