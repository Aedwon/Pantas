# Content upgrade: make new questions reach a student who already has the app

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
> one you introduced.


**Goal:** Turn `Seeder` from a first-run install into something that can also apply an update,
so that every content pass Aedwon generates reaches the people who already have Pantas.

**Architecture:** The seed JSON gains a `contentVersion` integer. The app stores the last
applied value in device preferences. At bootstrap, a lower stored value than the bundled one
runs an upgrade pass: one transaction, upserts into the five content tables, and **not one
write to any table holding the student's own work.**

**Tech Stack:** Flutter, Drift, Riverpod, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-03-content-delivery-and-seed-upgrade-design.md`.

**Decision log:** `docs/superpowers/decisions/2026-08-03-plan-audit-log.md`, round 2.

**Required reading before task 1:** `AGENTS.md` in full, and Section 8 of the source spec,
which says which of the two content paths this plan owns.

## Why this exists

`lib/core/storage/data/seeder.dart:14` reads the exams table and **returns immediately if it
is not empty.** A student who installed in July and updates in September receives the new
`assets/seed/v1.json` in the bundle and sees zero new questions. The only workaround today is
to uninstall and reinstall, which destroys their progress.

**Every content item in the launch checklist is undeliverable until this lands.**

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.**
- **No new dependencies.**
- **The upgrade pass writes content and never writes progress.** `attempts_local`,
  `review_state_local`, flags, bookmarks, sessions, mock attempts and settings are untouched.
  **This is the safety property of the whole plan** and Task 3's test is the one that proves
  it.
- **A revised question keeps its id.** Never mint a new id for a correction.
- **The student sees nothing.** No progress bar, no "updating content", no dialog.
- **Never invent a figure.** Nothing here is displayed, but the rule governs the withdrawal
  logic in Task 4: a withdrawn question keeps counting in history because the student really
  did answer it.
- **Analyzer baseline is 27 issues, all under `tools/` or `test/tool/`. `lib/` is clean.**
- `dart format --output=none --set-exit-if-changed lib test` before any commit.
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-02-content-seed-delivery.md` | Nothing, and read spec Section 8 before touching either. That plan owns `content.db` for **blueprints and mock papers**. This plan owns `v1.json` for **questions and lessons**. They must not both claim content delivery. | No |
| `2026-08-02-quiz-tab-01-storage-and-content-fields.md` | Merged already. It added the nullable `lessonId`, `rationale` and `shortLabel` fields the upsert must carry. | No, already landed |

## File structure

| File | Responsibility |
|---|---|
| `tools/build_dev_seed/build_dev_seed.dart` (modify) | Emit `contentVersion`. |
| `lib/core/storage/data/seeder.dart` (modify) | The version check and the upgrade pass. |
| `lib/core/storage/data/repos/app_preferences_repository.dart` (modify) | Store and read the applied version. |
| `lib/core/storage/data/tables/questions_table.dart` (modify) | The withdrawn flag. |

---

## Task 1: The seed carries a version

**Files:**
- Modify: `tools/build_dev_seed/build_dev_seed.dart`
- Modify: `assets/seed/v1.json` (regenerated, not hand-edited)
- Test: `test/tools/build_dev_seed_test.dart` (create if absent)

**Interfaces:**
- Produces: a root-level `contentVersion` integer in the emitted JSON, beside the existing
  `schemaVersion` and `generatedAt`.

**It increments on every build.** Derive it from the build timestamp as
`YYYYMMDDHH` so it is monotonic without a counter anyone has to remember to bump. Record the
scheme in a comment, because a later reader will otherwise assume it is a sequence.

**`build_dev_seed.dart` has two `unnecessary_cast` warnings in the analyzer baseline.** They
are pre-existing. **Do not fix them in this plan**, or the baseline check in every other plan
stops matching.

- [ ] **Step 1: Write the failing test**

Assert the emitted JSON has a `contentVersion`, that it is an int, and that two builds an hour
apart produce a strictly increasing value.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Emit the field**
- [ ] **Step 4: Regenerate the seed and confirm the question count is unchanged**

Run the tool. Then:

```bash
python3 -c "import json;d=json.load(open('assets/seed/v1.json'));print(d['contentVersion'], len(d['questions']), len(d['lessons']))"
```

Expected: a version, and counts **no lower than 1117 and 144**. A lower count means the tool
dropped content and this task has broken the app. **Stop and say so.**

- [ ] **Step 5: Run the gates and commit**

---

## Task 2: The app remembers what it applied

**Files:**
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Test: `test/core/storage/data/repos/app_preferences_repository_test.dart`

**Interfaces:**
- Produces:

```dart
Future<int?> appliedContentVersion();
Future<void> setAppliedContentVersion(int version);
```

**Device preferences, not account preferences.** It describes this installation's database,
not the student, so it must not sync. Getting this wrong means a student's phone believes it
has content their tablet actually has.

- [ ] **Step 1: Write the failing test**

Assert: absent reads as null; a written value round-trips; the key lands in `devicePrefs` and
**not** in `accountPrefs`; it is not in the sync collection registry.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Add the key and the two methods**
- [ ] **Step 4: Run the gates and commit**

---

## Task 3: The upgrade pass

**Files:**
- Modify: `lib/core/storage/data/seeder.dart`
- Test: `test/core/storage/data/seeder_upgrade_test.dart` (create)

**Interfaces:**
- Produces: `Future<void> maybeSeed({String assetPath})` gains an upgrade branch. Its
  existing first-run behavior is unchanged.

**The decision table, from spec Section 3:**

| Stored | Bundled | Action |
|---|---|---|
| absent | any | Full seed, exactly as today |
| equal | equal | **Return. One preference read, no asset load, no parse.** |
| lower | higher | Upgrade pass |
| higher | lower | Return, and `debugPrint` once. A downgrade means a sideloaded or rolled-back build. |

**The equal case is the common case and it must be cheap.** Loading and parsing a 6.3 MB
asset on every launch to discover nothing changed would be a cold-start regression this plan
introduced.

**The upgrade pass:** one transaction, upserting exams, subjects, topics, lessons and
questions on their own ids. A question is replaced in place when the bundle's `version` is
higher than the stored row's.

**Advance the stored version only after the transaction commits.** A failed pass then retries
on the next launch, which is the entire recovery story and needs no UI.

- [ ] **Step 1: Write the failing test**

This is the load-bearing test of the plan. Seed a database, write attempts, review state,
flags and bookmarks against a question, then run an upgrade that revises that question and
adds new ones. Assert **all** of:

1. The revised question's stem changed.
2. The revised question's **id did not change**.
3. New questions are present.
4. `attempts_local` is **byte-for-byte unchanged**.
5. `review_state_local` is unchanged.
6. Flags and bookmarks still point at the revised question.
7. The stored `contentVersion` advanced.
8. A pass that throws mid-transaction leaves the stored version **unadvanced** and the content
   at its old state.
9. Equal versions do not load the asset at all. Assert this with a bundle that throws if read.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the pass**
- [ ] **Step 4: Run the gates and commit**

---

## Task 4: Withdrawal

**Files:**
- Modify: `lib/core/storage/data/tables/questions_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: the session, drill and mock pickers. **Find them with `grep -rn`, do not guess.**
- Test: `test/core/storage/data/seeder_withdrawal_test.dart` (create)

**Interfaces:**
- Produces: `BoolColumn get isWithdrawn` on `Questions`, defaulting false.

**Schema bump.** Read the current `schemaVersion` in `lib/core/storage/data/app_database.dart`
first and confirm it matches what you expect before changing it. **Bump it and write the
migration in the same commit.** A version raised with no migration is a state that compiles
and is broken, and it has already happened once in this repo.

**Assigned numbering, from the 3 August ruling:** `study-01-foundations` takes 15,
`custom-track-a` takes 16, `custom-track-b` takes 17. **This plan takes the next number after
whichever of those have landed.** If none have, it takes 15 and the others shift up by one,
and you must **stop and say so** rather than renumbering their plans yourself.

**The rules, from spec Section 5:**

- A withdrawn question is **never served again**: not by a session, not by a drill, not by a
  mock, not by the scheduler.
- **It stays visible in history.** Reviews and Progress figures that already counted it keep
  counting it. A student's own numbers must not change under them.
- **It is never presented as withdrawn.** No badge, no strikethrough, no note.

- [ ] **Step 1: Write the failing test**

Assert: a withdrawn question is excluded from every picker; an attempt on it still counts in
the Progress performance figures; a review screen still renders it; nothing in the UI names
its state.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Add the column, the migration, and the exclusions**
- [ ] **Step 4: Run the full suite**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart
```

- [ ] **Step 5: Commit**

---

## Task 5: Measure the first run

**Files:**
- Test: `test/core/storage/data/seeder_performance_test.dart` (create)

Spec Section 7. Nobody has timed the full first-run seed and it grows with every subject.

- [ ] **Step 1: Time it**

Write a test that seeds a fresh in-memory database from the real asset and records the wall
time. **Do not assert a threshold**: an in-memory database on a developer machine is not a
phone, and a number asserted here would be a figure this project inferred.

**Report the measurement in the commit message and in the work checkpoint.** The real
measurement is a cold launch on the lowest device Aedwon is willing to support, and that is
his, not a model's.

- [ ] **Step 2: Record it and commit**

---

## Verification, for the reviewer

- `grep -n "if (existing.isNotEmpty) return" lib/core/storage/data/seeder.dart` returns
  **nothing**. That line is the defect.
- An upgrade run against a database holding attempts leaves `attempts_local` and
  `review_state_local` untouched. Prove it from Task 3's test, not by inspection.
- Equal versions never load the asset. Prove it with the throwing bundle.
- `schemaVersion` and its migration landed in the same commit.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `dart run tool/check_layering.dart` shows **7** violations.
- `flutter test` passes across the whole suite.

## Done when

- A student who already has the app receives new and revised questions on the next app update.
- A correction keeps the question's id, so their history with it survives.
- A withdrawn question stops being served and keeps counting in the past.
- Launching with no content change costs one preference read.
- The first-run seed time is measured and written down.
