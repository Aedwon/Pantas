# FSRS-6, and the review log that has to start now

**Plan, 9 August 2026.** Approved by Aedwon: move to FSRS-6, and write the review log into this
plan rather than leaving it for the optimizer.

> **Required reading before Task 1:** `AGENTS.md` in full, then
> `decisions/2026-08-08-fsrs-version-log.md` for why 6 and not 7, then Sections 3 and 4 of
> `specs/2026-08-09-fsrs-optimizer-design.md` for what the log must carry and why.

**If what you find disagrees with this plan, stop and say so** rather than inventing a
solution. A plausible invention in a scheduler is worse than a stop, because a wrong interval
looks exactly like a right one.

---

## Why the log is in this plan and not the optimizer's

**Every day without it is a day of history the optimizer can never use.** The rating is
computed at review time and thrown away, and it cannot be reconstructed afterwards: the
heuristic reads the interval the card was on at that moment, and that value is overwritten by
the review itself.

**The optimizer can be built whenever. The log has to start now or it starts from zero.**

---

## Global constraints

- **The scheduler is 158 lines and has tests. This is a contained change, not a rewrite.**
- **Never run `flutter test` with no arguments, `flutter analyze`, or `dart run build_runner`.**
  You may run a single test file. **The full gate set is run for you after you finish.** Never
  use `&`, `nohup`, or any background mechanism.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes**, before starting the next.
- **No em dashes.** Use a colon or a comma.
- **No figure derived from these parameters may reach a screen.** Section 2 of the spec.

### Gate command

```bash
flutter test test/core/fsrs/
```

---

## Task 1: The FSRS-6 weights and constants

**Files:**
- Modify: `lib/core/fsrs/default_weights.dart`
- Test: `test/core/fsrs/default_weights_test.dart` (create)

**FSRS-6 has 21 parameters, not 17.** The published defaults:

```
0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001,
1.8722, 0.1666, 0.796, 1.4835, 0.0614, 0.2629, 1.6483, 0.6014,
1.8729, 0.5425, 0.0912, 0.0658, 0.1542
```

**`w[20]` is the decay.** It replaces the `kFsrsDecay = -0.5` constant, and the factor is
derived from it rather than fixed at `19/81`.

- [ ] **Step 1: Write the failing test**

Assert the vector has exactly 21 entries, that `w[20]` sits inside FSRS's published decay
bounds, and that the difficulty and stability bounds are unchanged.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Replace the vector and derive the factor from `w[20]`**

**Keep the comment block that names each parameter's role, updated for 21.** The existing one
is why this file is readable at all.

- [ ] **Step 4: Run the gate**

Expected: the scheduler's own tests now fail. **That is correct and Task 2 fixes them.**

---

## Task 2: The FSRS-6 formulas

**Files:**
- Modify: `lib/core/fsrs/fsrs_scheduler.dart`
- Test: `test/core/fsrs/fsrs_scheduler_test.dart`

**Four formulas change. The state variables do not:** stability in days and difficulty on 1 to
10, exactly as now.

| What | Change |
|---|---|
| Initial difficulty | `D₀ = w[4] - e^(w[5] × (G - 1)) + 1`, clamped to 1 to 10 |
| Difficulty update | Grade-dependent change, then **linear damping as D approaches 10**, then mean reversion toward `D₀(4)`, not `D₀(3)` |
| Same-day review | **A real formula, using `w[17]`, `w[18]`, `w[19]`.** 4.5 had none |
| Forgetting curve | `R(t) = (1 + FACTOR × t / S) ^ decay` with **decay from `w[20]`** |

- [ ] **Step 1: Update the existing tests to FSRS-6 expectations first**

**The current tests encode 4.5's arithmetic and will fail. Do not delete them.** Recompute the
expected values under FSRS-6 and keep every case: they cover the boundaries that matter.

- [ ] **Step 2: Confirm they fail**
- [ ] **Step 3: Implement the four formulas**
- [ ] **Step 4: Add the cases 4.5 could not express**

At minimum: **two reviews of the same card on the same day** produce a sensible stability
rather than the same result as two reviews a day apart.

- [ ] **Step 5: Run the gate, then commit**

---

## Task 3: Existing progress keeps working

**Files:**
- Test: `test/core/fsrs/fsrs_version_migration_test.dart` (create)

**No schema change and no data migration.** Stability and difficulty mean the same thing in
FSRS-6 as in 4.5, so stored rows are reinterpreted, not invalidated.

**This task exists to prove that claim rather than assert it.**

- [ ] **Step 1: Write it**

Assert: a review state written under 4.5's values schedules sensibly under FSRS-6. A card with
stability 30 and difficulty 5 does not come back tomorrow, and does not vanish for a decade.
**Bound the assertion loosely and deliberately:** this test protects against a catastrophe, not
against a shift of a day.

- [ ] **Step 2: Run it, then commit**

---

## Task 4: The review log

**Files:**
- Create: `lib/core/storage/data/tables/review_log_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Create: `lib/core/storage/data/repos/review_log_repository.dart`
- Test: `test/core/storage/data/review_log_test.dart` (create)

**Read Section 4 of the optimizer spec before writing the table.** Every column there is there
for a reason and the reasons are stated.

- [ ] **Step 0: Confirm the current schema version**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

**Note the number and take the next one.** Do not assume a number from this document: it was
18 when this was written and plans have gone stale on exactly this before.

- [ ] **Step 1: Write the failing test**

Assert: a row round-trips; rows for one card come back in review order; **an existing database
migrates without losing a single row of `attempts_local` or `review_state_local`.**

- [ ] **Step 2: Confirm it fails**
- [ ] **Step 3: Add the table, the column set, the version bump and the migration in one commit**

**Append only.** No update path, no upsert. A review that happened is a fact.

- [ ] **Step 4: Run the gate, then commit**

---

## Task 5: Every review writes a row

**Files:**
- Modify: `lib/features/quiz/domain/use_cases/submit_answer.dart`
- Modify: `lib/core/fsrs/rating_heuristic.dart`
- Test: `test/features/quiz/domain/use_cases/submit_answer_test.dart`

**This is the task that stops the bleeding.**

- [ ] **Step 1: Give the heuristic a version**

A single named constant, `kRatingHeuristicVersion`, starting at 1. **Section 7 of the spec says
why:** a fit runs over one heuristic version's rows, and changing the heuristic must not
silently mix incompatible ratings.

- [ ] **Step 2: Write the failing test**

Assert: answering a question appends exactly one review log row; the row's rating **equals the
rating the scheduler was actually given**, not one recomputed afterwards; and the row carries
the state before the review, not after.

**That first assertion is the whole point.** A row recording a rating different from the one
that scheduled the card is worse than no row.

- [ ] **Step 3: Confirm it fails**
- [ ] **Step 4: Write the row where the rating is derived and used**, in the same transaction
      as the review state update if the repository allows it.

**If writing the log can fail independently of the review being recorded, stop and say so.** A
review that counts for the student but not for the log is a silent hole in the training data,
and it is exactly the failure this plan exists to prevent.

- [ ] **Step 5: Run the gate, then commit**

---

## Task 6: Nothing else moved

**Files:**
- Test: `test/core/fsrs/fsrs_blast_radius_test.dart` (create)

**Ten places construct a scheduler.** This proves the swap did not change what they do.

- [ ] **Step 1: Write it**

Assert: a due card is still due, an unseen card is still unseen, the assessment still schedules
what it schedules, and **the mock sampler and the pickers are untouched by any of this.**

- [ ] **Step 2: Run the gate, then commit**

---

## Verification, for the reviewer

- `grep -c "" lib/core/fsrs/default_weights.dart` shows 21 weights, and no `kFsrsDecay`.
- **Every review writes exactly one log row**, and the row's rating matches the scheduling one.
- **No figure derived from FSRS parameters appears in any widget.**
- Schema took the next number, with a migration that keeps existing rows.
- The suite is green and the analyzer is clean under `lib/` and `test/`.

## Done when

A student's answer is scheduled by FSRS-6 and recorded in a log that an optimizer can later fit
to, and no student's existing progress moved because of it.
