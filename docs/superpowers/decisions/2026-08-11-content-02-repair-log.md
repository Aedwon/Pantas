# Repairing Content 02

**11 August 2026.** Content 02 was merged nowhere: its branch carried all five
tasks committed, a report claiming the gates passed, and 55 analyzer errors.
This log records what the repair found, which is much more than a broken test
migration.

Aedwon's instruction, verbatim:

> "Content 02 is NOT merged: its branch wt-content02c has all five tasks
> committed, its own report claims the gates passed, and its HEAD carries 55
> analyzer errors from the test migration. There is a stash on that worktree
> that makes it worse, not better. Repair it or redo its Task 5 on top of the
> sound parts, which are Tasks 2, 3 and 4."

---

## What I got wrong, first, because it shaped two rounds

**I reported the problem as a test migration, three times, before it was.** The
55 analyzer errors were real and confined to six test files, so after fixing
them I told him the remaining work was "one uniform cause, a test problem, 32
files, mechanical, suitable for Gemini". That was wrong. Most of the 144
failures were tests correctly reporting that **the application itself had not
finished moving**.

**I also told him the loader decision cost three tests. It cost thirteen**, ten
of which were passing. He had already said "proceed" on the wrong number, so I
stopped and put the corrected figure to him before deleting anything.

---

## The finding: five production areas never moved

Task 1 of the plan was to inventory every reader. That inventory walked the
public methods of `ContentRepository`. **Every reader that queried the content
tables straight off `AppDatabase` was therefore invisible to it by
construction**, and there were five:

| Area | What it would have done on the device |
|---|---|
| Custom track creation | Wrote its exam row where nothing lists it, and inverted the included set against an empty topics table: the track appeared nowhere and hid nothing |
| Progress performance and pace | No subject rows at all, so both tables empty |
| Home's up next and tab providers | No lessons to suggest |
| Settings carry-over count | Counted exam membership by decoding a JSON column the content schema replaced with a table |
| The metrics signals | Study profile blank: no subject names, no correct-answer position |

**Custom track creation is the one worth remembering.** It is silent. Nothing
throws, nothing logs; the student taps Continue, a track is created, and it is
simply absent everywhere afterwards.

The reader inventory has been left as it was written. It is accurate about what
it surveyed and the lesson is in its scope, not its contents.

---

## Two traps the schema change set

**Choice ids must now be unique per question.** A choice used to be an entry in
a JSON list on its question, so tests reused `'a'` and `'b'` across every
question harmlessly. Choices are rows with their own primary key now, so the
second question's insert overwrote the first's, and every question after the
first had no choices at all. Three signal tests were quietly measuring a corpus
with one answerable question in it.

**A test that wants a blank state needs its own empty corpus.** Several tests
build a second database to assert on a specific data state. Handing them a
shared corpus let them see rows another test's setup had seeded.

---

## The boundary the repair broke and put back

Moving the carry-over count to the content database **violated the rule that
the Settings feature may not import it**, and the boundary test caught it. The
count belongs on the content repository, which is where it went. The rule was
right and the first fix was wrong.

---

## The decision: the superseded asset loader

The app used to load its corpus from a JSON file packed into the bundle. It
loads a prebuilt database now, installed at first launch. After Tasks 3 and 4
nothing called the JSON loader and its asset no longer shipped, so three of its
tests failed reading a file that was not there.

| Option | Cost |
|---|---|
| **Delete the loader and its tests** | Loses 13 tests, 10 of them green, and the only code that can build a database from a JSON asset |
| Point the three failing tests at a fixture | Keeps all 13 green and about 130 lines of code nothing calls, which the next reader will assume is live |
| Keep the code, drop the tests | Untested dead code |

**Recommended: delete.** Tests passing against code the app never runs read as
coverage without being coverage.

**Aedwon:** *"okay do what you recommend. proceed"*

### What was kept, because the plan says so

Task 4 of the plan says, of the JSON asset and its generator: **"Do not delete
this file or the asset yet, as Stage 3 needs a known-good corpus to compare
against."** Both are untouched. Only the loader inside the app went.

**The plan's stated reason has in fact expired**: Stage 3 is the UPCAT
blueprint, merged earlier the same day. The file and generator stay anyway, on
the plan's instruction rather than on its rationale, and deleting them is a
separate decision nobody has taken.

### He also asked whether deleting could break the emulator

It cannot: on this branch nothing called it. **The behaviour change had already
happened** in the merged tasks that stopped calling it. Worth separating,
because the emulator is running `main`, where the JSON loader is still the live
seeding path. **The risk is in the merge, not the deletion**, and the check is
the one the plan already assigns to Aedwon: launch on an install with real
attempt history and confirm the corpus is all there and past attempts still
resolve to their questions.

---

## Where it ended

**144 failures to zero.** 2,182 tests pass, analyzer clean, `check_layering`
and `check_no_ai_attribution` OK. Not merged: the plan's done-condition is a
device check with real history, which no test can claim.
