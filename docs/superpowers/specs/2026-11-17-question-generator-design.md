# Question generator: problem types with checked versions

Status: Part A approved by Aedwon on November 17, 2026 ("Part A is approved. go with your reco
for other items"). Decisions 2 and 3 under "Decisions for you" are settled as recommended.
Nothing is built yet; the plan is next.
Date: November 17, 2026. Lane: Question generator session (lead, Claude Fable 5.2).
Policy read: `origin/main` 0edf1dcf6 (`AGENTS.md`, `WORKFLOW.md`,
`docs/workflow/process-improvement.md`).
Source read: `origin/main` 0edf1dcf6. Prod serves a CSE content branch, not main
(`2026-11-13-bite-sized-lessons-design.md`, Part A), so the plan re-reads content there.
Decision log, with his exact words: `docs/superpowers/decisions/2026-11-17-question-generator-log.md`.
Velocity row: E-103 (this session). The build gets its own rows.
This spec has no screen change, so it has no visual companion. Figure answer choices
are a second spec, with boards.

---

## Part A: for Aedwon

### Your goal, in your words

- "a student never re-encounters the same set of figures for a given problem type"
- For math, you accepted: a student never meets the same problem with the same numbers.
- "it would be ideal if all types of question be encountered first before encounters of
  the same prob with different figures"
- "near-duplicates are okay for launch, we will build a parameterized question
  generation engine later on"
- The engine is the release requirement for PSHS-NCE and the academy exams, and you aim
  to sell PSHS-NCE for this cycle. The test is January 30, 2027.

This design meets all five. One limit is stated under "Limits".

### What changes for a student

- A lesson's practice is built from **problem types**. A problem type is one pattern,
  for example "a figure turns by the same angle each step" or "find the percent of a
  number".
- Each time the app serves a problem type, the student gets a **new version**: new
  figures or new numbers, a new answer, new wrong choices.
- The student meets every problem type in a lesson once before any type comes back.
- When a type comes back in review, it comes back as a new version. A missed type
  comes back sooner, as review already does.
- Explanations and wrong-choice notes keep today's rules. Every wrong choice still
  catches one named mistake.
- Streaks, history, review dates and stats carry over.
- Nothing on screen changes its layout. The count of new questions on Home can go
  down in lessons where near-duplicates merge into one type.

### What we found, and how the design answers it

The first idea was a pool of about 1,000 ready questions per problem type. We checked
it against the app and it does not fit.

- The roadmap sets each day's load from the number of unseen questions. Thousands of
  new questions would push the daily load into the hundreds. "All covered" would never
  arrive.
- Review brings back the exact same question. That breaks your first goal.
- Mastery, follow-ups and "why you miss" track each question on its own. Every new
  version would look brand new, with no history.
- Sync, web delivery and the server's totals are sized for about 3,200 questions.

The answer is one change in how the app counts: **one problem type is one question**.
It keeps one identity, one review date and one history. Only its content changes each
time. The roadmap, review, mastery, mocks, sync and the server limits then keep
working as they do today, and your "every type first" rule is the roadmap's existing
"unseen first" rule.

### Decisions you already made (November 17)

1. Versions are made and checked before release. The app reads a list. Making versions
   inside the app is a later step, only if real students near the end of a list.
2. Not strict "never": no version returns while an unseen one remains. If a student
   finishes a list, the oldest versions return first.
3. Scope: abstract reasoning and math. Math means CSE first, working toward CET and
   PSHS-NCE.
4. Generated types replace the hand-written near-duplicates. The hand-written
   questions become the first versions of their type. Questions that cannot be made
   into a type stay as they are.
5. Figure questions get figure answer choices, in a second, small spec with boards.
6. Complexity: balanced.
7. PSHS-NCE is aimed at this cycle.

### What gets built (balanced)

1. **The generator.** A tool that runs on our computers, not in the app. For each
   problem type it makes a list of versions. Start size: 100 versions per type.
2. **The checker.** A script that fails the build unless every version has exactly one
   correct answer, every wrong choice matches its named mistake, and no two versions
   of a type share the same figures or the same numbers.
3. **Abstract reasoning first.** Problem types for the five existing lessons: figure
   series, figure matrices, figure grouping, paper folding, mental rotation. The 100
   hand-written questions become first versions. This is the sale gate.
4. **A math pilot.** Two or three live CSE math lessons, after abstract reasoning. It
   proves the engine on numbers and measures the cost per lesson. The full math
   rollout (roughly 300 to 450 types) is a separate decision after the pilot, with
   that measured cost.
5. **App and server support.** The app fills a type with a version, records which
   version each answer used, and never repeats a version while a new one remains.
   Practice and the lesson quiz prefer types the student has not met.
6. **A count of list use.** A report of how far students are through each list, from
   their own answers. If any student passes 70% of a list, we refill it in the next
   content update.

### How correctness is checked

Answer keys build trust, so four checks stand between a version and a student:

1. The checker script proves every version (item 2 above). It solves each version a
   second way, separate from the generator.
2. A different AI vendor from the one that wrote a type blind-solves 5 of its
   versions without the key. One miss blocks the whole type.
3. Codex GPT 6.1 Sol at high effort audits each type once: its rule, its wording and
   its named mistakes.
4. You look at one sheet of sample figures per figure type before the first release.

### Cost

| | |
|---|---|
| Planning | About half a day: the implementation plan and its review |
| Build | About 11 to 16 days, abstract reasoning first, then the math pilot |
| Your time | Approve this spec. Look at five figure sheets. Say "ship it" for prod |
| Usage | Mostly Codex, through `codex-pick`. Claude only for the plan and lead reviews |
| Money | $0. No new service, scheduled job or secret. Web delivery is counted against the free tier before anything ships |
| Upkeep | Low. A refill is one generator run and one content update |

The times are rough. Past estimates in the velocity log ran longer than the actual
work, and this build is larger than most logged tasks.

### Order and dates

- On your approval: the plan, then the generator, the checker and the abstract
  reasoning types. These touch no app code.
- From November 23, after the beta ends: the app and server parts. Nothing reaches
  prod before the beta ends, and prod waits for your "ship it".
- Target for abstract reasoning on prod: the second week of December.
- The math pilot follows. It does not block the PSHS-NCE gate.
- The figure answer choices spec starts as soon as this one is approved, because
  PSHS-NCE now depends on it.

### Limits

- A student who uses up a list of 100 sees its oldest versions again. The list-use
  count exists so we refill before that happens.
- No official list of PSHS-NCE abstract item kinds was found. The types come from
  the five lessons we have.
- This build alone does not put PSHS-NCE on sale. It also needs figure answer
  choices, PSHS-NCE content, an account path for takers under 13, the pass as a
  product, live payments and the public launch. The operations manager owns those.
- Research does not show that a new version in review teaches better than the same
  question. It does not show it teaches worse. The choice rests on your goal.

### Decisions for you

All three were settled on November 17: "Part A is approved. go with your reco for other
items". They stand as recommended below.

1. **Approve Part A.** This also sets the start: offline parts on approval, app and
   server parts from November 23.
2. **The 20-question rule.** Your October 1 rule says each lesson has at least 20
   active questions. Recommended wording: at least 20 questions counting versions,
   and a type counts only when its list holds at least 20 versions.
3. **Who approves a version.** Today the lead approves each question after a separate
   agent re-solves it. Re-solving 100 versions per type by hand is not affordable.
   Recommended: a type is approved as a whole when the four checks above pass.

### How we will know it is done

- A test student answers a figure type until the list ends and never sees the same
  figures twice before that.
- A new student meets every type in a lesson before any type repeats.
- A missed type returns in review with new figures or numbers.
- Daily load, "all covered", mastery, mocks and sync behave as before on the same
  account.
- An account with answers on the old hand-written questions keeps its streak,
  history, review dates and stats after the change.
- The checker fails on a planted bad version of each kind: two correct answers, a
  wrong key, a duplicate.

---

## Part B: for agents

Part B agrees with Part A. Where the plan finds a fact here is wrong on the working
branch, the plan corrects it and tells the lead; a change to Part A returns to Aedwon.

### B1. Facts (read on `origin/main` 0edf1dcf6; the plan re-verifies each)

- Keys. Review state has one row per question id
  (`lib/core/storage/data/tables/review_state_local_table.dart:6,20`). Mastery,
  follow-ups, "why you miss", sync (`fsrs_cards`, one document per question) and the
  server answer totals are per question id.
- Roadmap. "Seen" means the question has review state. `unseenLeft` counts questions
  without it (`lib/features/roadmap/domain/build_roadmap.dart:70`); the daily
  new-question load is `ceil(unseenLeft / workingDays)`; `allCovered` needs
  `unseenLeft == 0` (`:123`). New questions are ordered by lesson order, then id
  (`day_selection.dart`). Mastery needs at least 5 answers per lesson
  (`mastery_thresholds.dart`).
- Review re-serves the same id. Every answer, including mock and assessment answers,
  creates or updates review state.
- Practice and drill push questions answered in the last 7 days to the back. The
  in-lesson quiz takes one question per key point, then fills at random, and does not
  avoid seen questions. The mock avoids only the ids of the last 2 mocks.
- Limits. Server answer totals: `MAX_QUESTIONS = 6000`, `MAX_ID_BYTES = 150_000`
  (`functions/src/_answerTotals.ts:36-37`). Web content: 300 delivered documents per
  account per day and a global daily ceiling. A session accepts 1 to 300 answers.
  A Firestore document is at most 1 MiB.
- Content. Questions live in `content/questions/**.yaml`, 20 to 23 per file. The
  exporter writes `figureSpec` and `keyPoint`; it does not write `type`,
  `difficulty` or `approved`, and it writes `version: 1` always. Withdrawal is
  `isActive = false`. The ledger (`content/question-ledger`, `tool/content/`) holds a
  hash per question id and the content gate fails on an unapproved new or edited
  question. Wrong-choice notes are Pro-only and travel in a separate document.
- Abstract reasoning today: five files under
  `content/questions/reasoning/spatial-abstract-reasoning/`, 20 questions each, 94
  with a `figureSpec` (mental rotation has 14 of 20). Figure kinds in use:
  `figure-series`, `figure-matrix`, `shape-row`, `paper-fold`, `cube-net`, drawn by
  `lib/core/ui/figures/`. Choices are text.
- Math today on main: 46 question files, 44 tagged for the college entrance tests, 12
  for CSE by the older tags. The live CSE set is larger after the bite-sized split.
- Math lessons (reported by the math lessons lead on November 17, branch
  `content/math-for-generator-r1` 4b5bd5086, lists in
  `docs/content/math-for-generator/lesson-lists.md`; not re-checked by this lead):
  CSE has 54 live math lessons (41 arithmetic, 7 data interpretation, 6 Algebra
  word-problem parts), prod root `content/bite-sized-cse-algebra-r1` 88f38e698. CET
  has 121 math lessons with the audit complete. PSHS-NCE has 3 new lessons (counting
  and digit patterns, practical measurement, clock time) with 20 questions each and
  5 choices per question; 12 existing lessons cover the rest of the official
  sample's item kinds. PSHS-NCE has no exam entry in the content export yet.
- PSHS-NCE math source: the official PSHS NCE reviewer for 2024 (Internet Archive
  copy of the pshs.edu.ph file) and the 2015 official sample: 20 sample math items,
  no topic list, item count or grade level. A type may claim only that the official
  sample has items like it.
- Not verified: the compiled engine the server runs (`scheduleReviews`,
  `sampleMock`), sync paging limits, whether the content gate runs in CI, Wrapped
  internals.

### B2. Evidence for the learning-method choices

- Mixing problem types beats practicing one type at a time in math. Rohrer, Dedrick
  and Stershic (2015), J. Educational Psychology 107, 900-908: 126 seventh graders,
  d about 0.42 at 1 day and 0.79 at 30 days. Rohrer, Dedrick, Hartwig and Cheung
  (2020), J. Educational Psychology 112(1), 40-52: 54 classes, 787 students, 61%
  against 38% a month later, d = 0.83. Strength: good, for grade 7 math in one
  district. "Every type once before any type twice" is an inference from it.
- Same question or a new version at review. Freund and Holling (2011), Intelligence
  39(4), 233-243, 189 people, generated figure matrix items: no large difference in
  retest gains between identical and parallel forms. Strength: one study, figures
  only, read from its abstract. So evidence does not decide this; Aedwon's goal does.
- Inference to watch: the review scheduler was designed for identical items. Here one
  schedule tracks a type across versions, so it tracks the skill. The plan adds
  nothing for this; real accuracy at review will show whether intervals fit.
- Figures here come from search summaries and abstracts, not full texts.

### B3. Rules

Terms: a **type** is one question to every system. A **version** is one concrete
question made from a type. A **single** is an ordinary question that is not a type.

1. A type has one id, one lesson, one key point, one difficulty, one set of exam
   tags, one review state, one ledger entry. Harder variants are separate types.
2. A version is stored as values: numbers or figure data, the correct choice, each
   wrong choice with the id of its named mistake, and the values the explanation and
   notes need. The type holds the shared wording with slots for those values.
3. The app turns (type, version index) into a normal question object before any
   screen or scheduler sees it. Nothing downstream learns about versions except the
   answer record.
4. Each answer records the type id and the version index. Reviewing a past answer
   shows the exact version answered.
5. Per student and type, the app keeps the set of version indexes already served. It
   serves an unused index. The order is fixed per student (seeded by account and type
   id) and differs between students. When none is unused, it serves the least
   recently served. This state syncs with the type's review state and merges as a
   union.
6. Roadmap, review scheduling, mastery, follow-ups, "why you miss", mock sampling and
   the assessment keep their logic. They see fewer ids where questions merged.
7. Practice and drill order: ids never met come first. Among ids already met, the
   existing 7-day rule still applies (answered in the last 7 days go to the back),
   and fewer answers come before more. The in-lesson quiz keeps one question per key
   point and prefers ids not yet met inside each key point.
8. "Retake mistakes" serves a new version of each missed type.
9. Merging hand-written questions: each merged question becomes a version of its
   type with a fixed index, and its id maps to (type id, index). Attempts under the
   old id count toward the type's history and mark that index as served. The type
   takes the review state of the most recently answered merged question. The old ids
   become inactive, not deleted. A question merges only if the type's rule produces
   it exactly; otherwise it stays a single.
10. The October 25 allowance for near-duplicates ends for a lesson when its types
    ship. `docs/content/question-style-guide.md` gets the generated-versions
    exception: versions of one type differ in values by design.
11. No figure shown to a student is invented: list use is measured from answers.

### B4. The generator and its formats

- Location: `tool/generator/`, in Dart, so the same code can later run in the app
  (option C's later step) without a rewrite. Not shipped in the app in this build.
- One file per type under `content/types/<subject>/<topic>/<lesson>/<type>.yaml`:
  id, lesson, key point, difficulty, exam tags, wording with slots (stem, choices,
  explanation, one note per named mistake), the named mistakes, value ranges, and the
  generator rule's name. The rule's code lives in `tool/generator/rules/`.
- Generated lists are committed next to the type as data, with the generator seed and
  tool version, so a build is reproducible and a refill appends without changing
  existing indexes.
- Abstract reasoning rules use only the five figure kinds the app draws today. Each
  choice carries figure data and a text description. The text is shown as the choice
  until the figure-choice screen ships, and is the screen reader label after.
- Math values: exact rational arithmetic, answers in the forms the lesson teaches,
  ranges set per type. Maths markup follows `AGENTS.md` (`\dfrac`, single dollars).
- Wording follows `AGENTS.md` and both style guides: realistic exam stems, Grade 5
  explanations that say only why the answer is correct, wrong-choice notes with the
  mistake, why it looks right and one check. Filipino items follow the Filipino rule.

### B5. The checker (in `tool/checks/`, run in CI on content changes)

For every version of every type:

1. Exactly one choice is correct by a second solver that shares no code with the
   rule that made it. Math: independent evaluation. Figures: a search over the rule
   library; the shown figures must fit the type's rule, and no wrong choice may
   complete any rule in the library that also fits the shown figures.
2. Each wrong choice equals the value its named mistake produces. All choices
   differ. The number of choices is set per type: 4, or 5 where the lesson's
   hand-written questions use 5 (the PSHS-NCE math lessons do).
3. No two versions of one type share a figure signature or the same numbers. The
   signature treats rotated or mirrored copies of a whole question as the same.
4. Values stay inside the type's ranges; text has no empty slot; markup parses.
5. Size: a type's delivered document stays under 200 KB and the Pro note document
   never reaches a Free account.

The checker's own tests plant one bad version of each kind and must fail on it.

### B6. Approval and the ledger

- One ledger entry per type. Its hash covers the type file, the rule's code version
  and the version list. Any change cancels approval.
- The lead approves a type when: the checker passes; a blind solve of 5 versions by a
  different vendor from the author matches the key on all 5; the Codex GPT 6.1 Sol
  high audit of the type has no open Blocker or Major. Evidence is recorded with the
  approval.
- Aedwon's sheets: one offscreen sheet per figure kind, light and dark, 12 sample
  versions each, under the November 9 screenshot exception. His pass gates the first
  prod release only.

### B7. App and server changes (no screen change)

- Content model: a question row may carry a version list; a resolve step in the
  content repository returns a normal question for (id, index).
- Local database: the answer record gains the version index; review state gains the
  served-index set. Drift migration with tests. Generated files are not hand-edited.
- Sync and server: the same two fields in the synced documents and in answer
  ingestion; the server rejects an index outside the list. Server-side selection for
  web mirrors B3.5 and B3.7.
- Export and upload: types and lists are exported; the old-id map is exported; the
  size limit in B5.5 is enforced at build.
- Free tier (written rule 7): before staging, count the change in Firestore reads,
  stored bytes and egress per student against the free tier, for both projects
  together. Do not ship if it would bill.
- UI: none. If any screen must change, stop and return to the lead.

### B8. Rollout and rollback

1. Offline parts on a branch off the current content branch; no app code.
2. App and server parts on a branch off the current engineering candidate, started
   November 23. Staging first.
3. Abstract reasoning types replace the 100 questions on staging; the lead runs the
   acceptance checks; Aedwon passes the sheets; prod on his "ship it".
4. Rollback: types off, the old questions back on, by `isActive`. Answers given on
   types stay stored and are ignored while types are off. Nothing is deleted.
5. The math pilot repeats steps 3 and 4 for its lessons. The lead picks 2 or 3 live
   CSE lessons: one mostly computation, one mostly word problems, one with questions
   that cannot become types.
6. List use: a script run on demand in the manager's sweep, not a scheduled job.

### B9. How agents are used

- Lead: an Opus 5.5 build lead under the operations manager, with this spec, the
  plan and the decision log. Escalation to a Fable 5.2 adviser for rulings.
- Generator, checker, rules, type files: Codex GPT 6.1 Sol through `codex-pick`, one
  run at a time, sized to one account's 5-hour window, findings written as found.
- App and server code: Codex GPT 6.1 Sol or Sonnet 5.5, with tests first.
- Blind solves: the vendor that did not write the type. Audit: Codex GPT 6.1 Sol at
  high effort, never used to fix.
- No UI work in this spec, so no UI worker.
- Each task logs its estimate and timer in the velocity log.

### B10. Acceptance criteria

1. Never repeat: a scripted student answers one figure type and one math type to the
   end of the list; no figure signature or number set repeats before the end; after
   the end the least recently served returns.
2. Every type first: a new scripted student in a lesson with N types and singles
   meets all ids once before any repeats, through the roadmap path and through
   practice.
3. Review: a missed type is scheduled as today's rules schedule a missed question,
   and returns with an unused index.
4. No regression: on a fixed test account, daily load, `allCovered`, mastery, mock
   sampling and sync results are unchanged except for the merged ids, and each
   difference is explained in the verification record.
5. Carry-over: an account with answers on merged questions keeps streak, history,
   review dates and stats; those versions are marked served.
6. Two devices: served sets merge as a union after sync; an offline device never
   serves an index the other device served before the last sync.
7. The checker fails on each planted bad version and passes on the shipped lists.
8. Free tier count recorded and under the limit.
9. Every shipped type has its approval evidence.

### B11. Out of scope

- Showing figure answer choices (second spec).
- Making versions inside the app.
- The full math rollout beyond the pilot.
- New figure kinds, and the 6 mental rotation questions that have no figure data.
- PSHS-NCE content, the under-13 account path, the pass product, live payments.
- The existing difference between the Today topic path and the roadmap path.

### B12. Risks

- A figure question with a second defensible answer. Mitigation: the rule library
  search in B5.1, the blind solve, the audit. The library must grow with each new
  rule, or the search proves less than it claims.
- Carry-over mistakes on live CSE accounts. Mitigation: B10.5 on a copy of real
  account shapes before prod; rollback by `isActive`.
- Fewer ids lower the daily load in merged lessons. This is intended; the lead
  reports the before and after counts for the pilot lessons.
- Dates. The second week of December is a target with about 7 weeks to the
  PSHS-NCE test. The other sale items carry more risk than this build.

### Sources

- https://ies.ed.gov/use-work/awards/interleaved-mathematics-practice
- https://ies.ed.gov/ncee/wwc/Study/88770
- https://zendy.io/pdf-viewer/10.1037/edu0000367
- https://fis.leuphana.de/en/publications/how-to-get-really-smart-modeling-retest-and-training-effects-in-a/
