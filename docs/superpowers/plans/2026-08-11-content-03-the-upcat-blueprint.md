# Content 03: the UPCAT blueprint

**Plan, 11 August 2026.** Stage 3 of `specs/2026-08-11-content-path-and-the-mock.md`.

> **Required reading before Task 1:** `AGENTS.md`, Section 4.3 of the spec, the
> UPCAT table in `specs/2026-07-28-mock-exam-ui-design.md`, and
> `lib/features/mock_exam/data/blueprint_section.dart` in full.

**Content 01 and 01b must be merged first. Both are.** This plan does **not**
depend on Content 02: a blueprint is read from the content database by
`mockBlueprintRepoProvider`, and Progress reads published sizes through it
today, whichever database the app's other readers point at.

**Reasoning is settled by measurement.** Not one of its 64 questions is tagged
for UPCAT: they carry ACET, USTET, DOST-SEI and both CSE tracks. **So no part
of this blueprint draws from a Reasoning topic**, and that is a fact rather
than a judgment call.

**Every figure in this plan came from Aedwon on 11 August and is marked
reported, not published.** Do not adjust one to make an arithmetic check pass.
If the numbers do not add up, stop and report it: **a wrong duration on the
setup screen is not cosmetic**, and this project has a standing rule that
nothing it inferred on its own may be printed as a figure.

---

## The composition

| Part | Language | Items | Minutes |
|---|---|---|---|
| Language Proficiency | English and Filipino | 80 | 70 |
| Reading Comprehension | English and Filipino | 50 | 35 |
| Mathematics | English | 60 | 75 |
| Science | English | 60 | 50 |
| **Total** | | **250** | **230** |

**UPCAT is sectional.** A part cannot be re-entered once its time is called;
the evidence is quoted in the mock UI spec's Section 2 table.

**UP publishes the four subtest names and "about five hours" of
administration, and nothing else.** The five hours is the administration and
230 minutes is time on the paper. **They do not contradict each other** and
neither should be printed in place of the other.

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze`, or
  `dart run build_runner`.** You may run a single test file. **The full gate
  set is run for you after you finish.** Never use `&`, `nohup`, or any
  background mechanism.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes.**
- **No em dashes.** American spelling.
- **Reasoning is not one of the four parts.** The seed carries it as a UPCAT
  subject and UP does not list it as a subtest. **Its questions are not in this
  blueprint.** Whether it stays a Study subject is Aedwon's open question and
  not yours to settle.

### Gate command

```bash
flutter test test/features/mock_exam/ test/features/progress/
```

---

## Task 1: The blueprint document

**Files:**
- Create: `content/mock/upcat.yaml`
- Modify: `tools/build_content_export/build_content_export.dart`

**Authored beside the questions**, in the same shape the corpus already uses,
and emitted by the export as a `mockBlueprint` document.

The document needs `_id`, `_updatedAt`, `schemaVersion`, `isActive`, `exam` as
a reference, `name`, `durationMinutes`, `sectionalTiming`, `totalPublishedItems`
and `sections`. Read `parsers/mock_blueprint_parser.dart` for the field names.

**Each section needs `id`, `name`, `questionCount`, `suggestedMinutes`,
`topicIds`, `topicWeights` and `sectionalMinutes`**, per
`BlueprintSection.parseList`. `topicWeights` must sum to 1.0 within a section.

**`sectionalMinutes` is the published limit and `suggestedMinutes` is the same
number here.** They differ only on a paper that is not sectionally timed.

**`topicIds` come from the corpus**, not from this plan. Read them from the
built content database and map each part to the topics of its subject:
Language Proficiency, Reading Comprehension, Mathematics, Science. **Reasoning's
topics belong to no part.**

### Recording the evidence

The blueprint carries where its numbers came from, per spec Section 4.3. Since
no field exists for this yet, **add one** rather than leaving it in a comment:
`source: reported`, `sourceNote: 'Supplied by Aedwon, 11 August 2026. UP
publishes the four subtest names and about five hours of administration only.'`

**Thread it through the parser and the table.** A schema version bump is
correct here; `SchemaVersions.mockBlueprint` goes to 2 and the parser accepts
1 by treating a missing source as unknown rather than as published.

---

## Task 2: The blueprint reaches the app

**Files:**
- Test: `test/features/mock_exam/upcat_blueprint_test.dart`

Build the content database from the corpus and read the UPCAT blueprint back.

**Assert every figure**: four sections, the item counts and minutes above, 250
total, 230 minutes, sectional timing on, and that each section's topic weights
sum to 1.0.

**Assert no section contains a Reasoning topic.**

**Assert the questions exist to fill it.** A section asking for 80 items from
topics that hold 12 is a paper that cannot be built. Report the shortfall per
section rather than failing on the first: Aedwon needs the whole list, and the
answer may be that the corpus is not deep enough yet, which is a content
finding rather than a bug in this plan.

---

## Task 3: Progress prints the published sizes

**Files:**
- Test: `test/features/progress/presentation/widgets/performance_section_test.dart`

`_publishedSizeForSubject` already sums the sections that sit wholly inside a
subject, and returns null when no blueprint ships. **With the blueprint in
place the subtext appears**: "60 of 180 questions" in the spec's example.

**Add a test that a subject with a section prints its size**, and one that a
subject with none prints nothing rather than a zero.

**A section spanning two subjects is not divided between them.** That rule is
already in the code with its reasoning; do not relax it to make a number
appear.

---

## Done when

- The content database holds one UPCAT blueprint whose figures match the table
  above exactly.
- The Progress table prints published sizes for the four subjects that have
  them.
- Any section the corpus cannot fill is reported to Aedwon with its shortfall.
- The gate command passes.
