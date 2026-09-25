# SUBAGENTS.md

**The contract every dispatched subagent works under.** Code implementors and content
authors both. If you were dispatched to do work in this repository, this file and the three
it names are your instructions, and they outrank your own judgment about how the work should
be done.

The same repository rules govern every provider:

| File | Governs |
|---|---|
| `AGENTS.md` | **How to build.** Build commands, the visual identity, the voice, the landmines, the never-invent-a-figure rule. |
| `WORKFLOW.md` | **How to collaborate.** Shared scope choices, spec approval, planning, roles, permissions, and decision history. Applies to every role. |
| **`SUBAGENTS.md`**, this file | **How to run.** Isolation, the task loop, the verification protocol, when to stop, and what to report. |

---

## Part 1: Before you touch anything

**Read these, in this order, in full. Not skimmed, not grepped.**

On every dispatch or resumption, retrieve the current policy from `Aedwon/Pantas`
on main, even when the assigned code branch has older copies of these files.
Record the policy revision. Read the product spec and plan from the assigned
workstream revision. Do not merge or switch branches merely to obtain policy.

1. **`AGENTS.md` and `WORKFLOW.md`.** Every applicable rule applies to you. The identity bans and the voice rules are
   the ones most often broken by an agent that read only its plan.
2. **Your plan**, end to end, before starting Task 1. Its Global Constraints, its Dependencies
   table and its file table are as binding as its steps.
3. **The spec your plan cites.** Every plan names one by path. The plan tells you what to
   build; the spec tells you why, and you need the why the moment a step is ambiguous.
4. **The current workstream's dependency and collision map.** The historical map in
   `docs/superpowers/2026-08-04-execution-pipeline.md` is Part 9. For those plans,
   read the relevant rows and check them against current assignments before writing.

**If any of those four is missing or unreadable, stop and say so.** Do not proceed on three
out of four.

Plans follow the Plan detail and simplicity rule in `WORKFLOW.md`. A concise plan is sufficient
when it defines the assignment, constraints, expected behavior, and checks.
Routine implementation details may be resolved within those boundaries. Do not
require full code in the plan or invent missing product decisions. Escalate a
contradiction or necessary scope change to the lead; existing precise requirements
remain binding.

---

## Part 2: Isolation

**Work in your own git worktree. Never write to the main checkout.**

This is not a style preference. A previous background run in this project wrote outside its
worktree and left a half-applied `app_database.dart` in the main tree with `schemaVersion`
raised and no migration: a broken state that compiled, and therefore a state nobody noticed
until much later.

- **One plan per agent. One worktree per agent.** Never two plans against the same tree.
- **Never `git add` a file your plan's file table does not name.** If you needed to touch
  something else, that is a finding to report, not a file to quietly stage.
- **Never commit generated files.** `*.g.dart`, `*.freezed.dart` and the generated
  localization delegate are gitignored. If `git status` shows one, you have made a mistake.
- **Do not merge your own work.** Report and stop.

---

## Part 3: The task loop, for code

**One task at a time, in the plan's order. Never batch.**

For each task:

1. **Write the failing test first.** The plan tells you what to assert. Write it before the
   implementation exists.
2. **Run it and confirm it fails**, for the reason you expect. A test that fails because of a
   typo in the import proves nothing.
3. **Write the smallest code that makes it pass.**
4. **Run the task's own tests.**
5. **Run other checks affected by this task**, following Part 5. The lead runs or
   assigns the full required checks on the completed feature.
6. **Commit**, with a message that says why, not what.

**Do not skip step 2.** A test written after the code passes on the first run and has never
demonstrated that it can fail, which means it is not yet a test.

### After merging a schema change, regenerate before you judge anything

**This has cost time twice on 4 August and it looks like a catastrophe both times.**

`*.g.dart` is gitignored, so **a merge that moves `schemaVersion` cannot bring the generated
code with it.** The tree is then source-at-17 against generated-at-16, and the symptom is not a
clear error:

- the first time, a single test **would not load at all** and the analyzer reported nothing;
- the second time, **151 tests failed** and two analyzer issues appeared, on a merge where both
  branches had been fully green alone.

**So, immediately after any merge that touches the schema, and before running the gates:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Do not start diagnosing a post-merge failure until you have done this.** Both times the real
answer was that nothing was wrong with either branch.

### Schema changes carry one extra rule

**The `schemaVersion` bump and its migration land in the same commit.** Always. A version
raised without its migration is a state that compiles and is broken, and it has already
happened here once.

**Confirm the current value before bumping it.** Plans that touch the schema carry a Step 0
that does this. If the value is not what your plan expects, another plan has landed ahead of
yours: **stop and say so.** Do not renumber, and do not renumber another plan.

---

## Part 4: The task loop, for content

**Content subagents follow the same discipline with different tools.** The remaining question
generation runs this way.

**Your plan is one of:** `docs/superpowers/plans/2026-07-20-question-generation-science.md`,
`-language-proficiency.md`, `-reasoning.md`, or a Mathematics or comprehension plan written
later. Each carries a manifest table with a Done column and a per-row generation procedure.
**Follow that procedure exactly**; this section adds the rules that sit above it.

### One subtopic at a time, validated before the next

1. **Read the source lesson** the manifest row names. Its "Traps to Watch For" section is the
   best distractor material there is, because those traps are real student mistakes.
2. **Write the YAML** to the exact path in the manifest, ids ascending, difficulty ramping
   from easy to exam level.
3. **Validate immediately:**
   ```bash
   dart run tools/import_questions/import_questions.dart --root content/questions
   ```
   Exit code 0, or fix and rerun. **Never batch several subtopics before validating.** The
   validator names the exact file and question id, and that precision is worth nothing if you
   have written six files since the mistake.
4. **Review in Question Studio**, `node tools/question_studio/server.mjs`, port 4323. No
   validator errors, no duplicate-stem warning, the highlighted correct choice matching your
   intent. Approve, save, stop the server.
5. **Re-validate**, because the studio writes back to the YAML.
6. **Tick the manifest row** in the plan and commit both.

**Always redirect the validator's output.** It prints the full converted JSON of every
question under `--root`, which is **2.8 MB** across the whole corpus. Ingesting that on every
run is the single largest avoidable cost in a content dispatch. Check the exit code, not the
dump, and scope `--root` to your own subject directory:

```bash
dart run tools/import_questions/import_questions.dart \
  --root content/questions/<your subject dir> >/dev/null 2>&1; echo "exit: $?"
```

**Read the output only when the exit code is non-zero**, and then drop the redirect so the
error message is visible.


### The four ways a content run broke on 3 August

Every one of these shipped from a real agent that reported success. **Check each before you
report.**

1. **LaTeX inside double-quoted YAML.** A backslash is an escape character in double quotes,
   so `"$\frac{5}{3}$"` and `"$\dots$"` fail the parse. **Use single quotes or a block
   scalar for anything containing a backslash.** Every Mathematics and Science file carries
   LaTeX, so this is the most likely failure you will hit.
2. **A `meta:` block missing `exams:`.** The validator dies with an unhandled null cast and a
   raw stack trace naming no file. **All four keys, every file:** `subject`, `topic`,
   `subtopic`, `exams`.
3. **Writing outside the repository.** One run authored into `/tmp` and its work would never
   have arrived. **Write to the path the plan names, under the project root, and nowhere
   else.**
4. **Reporting an exit code you did not read.** Three separate runs reported exit 0 against a
   validator that was exiting 65 or 255.

### Content rules that no validator enforces

These are the ones a fast model breaks, and none of them fails a build.

- **Exam level, not textbook level.** A question a student could answer by reading the lesson
  once is not the target. The target is the question the real exam asks.
- **Realistic exam language in questions and answer choices.** This applies to Mock,
  normal quizzes, and in-lesson quizzes. The Grade 5 language benchmark applies to
  lesson teaching content, not quiz questions. Do not simplify away the language
  skills or subject knowledge the target exam tests.
- **Coverage exhaustive within the subtopic.** Do not write twelve questions on the one
  concept you found easiest to write about.
- **Every distractor is a real mistake**, traceable to something in the lesson or to a known
  trap. A distractor nobody would pick teaches the student to eliminate rather than to know.
  Each wrong choice must plausibly reflect a meaningful reasoning error or misconception.
- **Never make the correct answer the longest choice, and check it per question.** An answer
  written to be unambiguous naturally runs longer than a distractor written to be wrong, so
  this one breaks silently. On 4 August a run broke it in **120 of 160 questions** while
  quoting the rule back in its own report. Fix it by tightening the answer, not by padding the
  distractors: four bloated choices is a new tell, not a fix.
- **Do not hand-vary which position the answer sits in.** Write it wherever it falls. The app
  orders a question's choices from its id when it reads them, so authored position no longer
  reaches a student. Before that landed the answer was first in 96% of the corpus.
- **Never invent a figure.** If a question needs a number, it comes from the lesson, from the
  testing body, or from arithmetic you show. It is never approximated to make a question work.
- **No em dashes. American spelling.** Both are checked below.
- **Filipino items where the manifest says so.** Several rows name a Filipino counterpart in
  the lesson title and mean it.
- **Do not set `approved:`.** Question Studio sets it.
- **Figures are hand-made and never AI-generated.** If a question is unanswerable without a
  diagram, add `figure: <slug>` and add the row to the worklist. **Do not generate an image.**

### The content gates, as one command

Run this from the project root, substituting your own directory. It is the whole check:

```bash
P=content/questions/<your subject dir>
dart run tools/import_questions/import_questions.dart --root $P >/dev/null 2>&1
echo "validator: $?  files: $(ls $P/*.yaml | wc -l)  questions: $(grep -hc '^  - id:' $P/*.yaml | awk '{s+=$1}END{print s}')  emdash: $(grep -rl '—' $P | wc -l)  approved: $(grep -rl 'approved:' $P | wc -l)  noexams: $(grep -L '  exams:' $P/*.yaml | wc -l)"
```

**Expected: validator 0, emdash 0, approved 0, noexams 0.** Anything else is yours to fix
before you report. **Paste that line's actual output into your report.**

If the validator is non-zero, rerun without `>/dev/null` to see which file and id it names.

`python3 tools/audit/run_all.py` sweeps **lessons, not questions**. Run it only if you touched
a lesson.

`tools/audit/run_all.py` sweeps **lessons, not questions**: structure, devices,
illustrations, formulas and AI tells. Run it if you touched a lesson. Its AI-tell sweep counts
em dashes, shouty caps, "not just X but Y" constructions and stock phrases, and **a rising
count is a finding you report**, not a number you tune until it drops.

---

## Part 5: The verification protocol

**Ordinary changes: focused checks during work, all required checks on the completed
feature.** This September 25, 2026 decision replaces the blanket instruction to run
the entire gate set after every task.

- Implementors run the task's tests and other affected checks while editing. Use
  the actual changed behavior and dependencies to choose scope; do not skip an
  affected check because it is slow.
- The lead runs or assigns all required checks on the combined feature before
  acceptance. The list below is the ordinary code baseline. Include backend,
  content, generated-output, coverage, or other checks required by the affected
  work and approved spec. Documentation-only changes need relevant document checks,
  not an unrelated Flutter suite.
- Fixes require checks of the amended behavior. Source-changing integration or
  changed material inputs require renewed relevant verification before acceptance.
- Preserve exact source and dirty-patch identity, command, result, and material
  environment/content inputs in evidence. A reviewer may inspect applicable existing
  evidence instead of blindly repeating unchanged checks. Re-run when evidence is
  missing, invalidated, unreliable, or the approved contract requires independent
  execution. Independent review itself is not removed.
- Approved release and high-risk contracts retain their specific checkpoints,
  repetitions, device coverage, and artifact identity requirements. This rule does
  not waive E09-E14 or turn historical results into a current pass.

Read actual command output. Preserve it in the verification record.

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
```

**Expected outcomes:** historical issue counts are not standing exceptions.

| Command | Expected | What a different number means |
|---|---|---|
| `flutter analyze` | Clean, except any explicitly accepted exception applicable to the exact candidate | Report failures and identify any applicable recorded exception. An old issue count does not authorize ignoring a finding. |
| `dart run tool/check_layering.dart` | Exit 0, clean | Report violations. Do not raise a historical baseline to pass. |
| `flutter test` | Green across the suite | A pre-existing failure is a finding to report, not a reason to continue. |
| `dart format` | Exit 0, no formatting changes needed | Format affected files, then recheck. Avoid unrelated formatting changes. Commit only with matching authorization. |
| `dart run tool/check_no_ai_attribution.dart` | **Exit 0, clean.** | Any hit at all is yours. See below for what it catches. |

**Coverage:** `dart run tool/check_coverage.dart` enforces a 70% minimum against
`coverage/lcov.info` when coverage has been generated. Run it if your plan asks.

### What the attribution check catches

**It exits 0 on a clean tree.** It was rewritten on 3 August because it used to ban the bare
substring "claude" in every tracked file, and the project's own instruction file is named
`CLAUDE.md`, so every document referring to it tripped. It had never passed. **A gate that is
always red teaches everyone to ignore gates**, so it now enforces the rule rather than a word.

**Two tiers:**

1. **Attribution markers, banned everywhere including commit messages.** A `Co-Authored-By`
   trailer naming a vendor or AI, a "Generated with" or "Generated by" line, an "Authored by",
   "Written by" or "Assisted by" credit, and the robot marker some tools append.
2. **Bare vendor names, banned in code and content**: `lib/`, `test/`, `content/`, `assets/`,
   `functions/`, `android/`, `ios/`, `tool/`, `tools/`. Prose documentation is checked for
   tier 1 only, because a document may legitimately name `CLAUDE.md` and may legitimately
   state the rule.

**It scans commit messages**, which the old file-only check could not see and which is where a
trailer actually gets added. **Amend before you report**, because a bad commit message fails
the gate for everyone until history is rewritten.

**Two things are exempt before any scan:** the literal filename `CLAUDE.md`, and a sentence
stating the prohibition. Both are references to the rule, not breaches of it.

**The rule the check exists to enforce still binds absolutely.** No `Co-Authored-By` trailer,
no "Generated with" line, no attribution marker of any kind, in a file or in a commit
message.

### The rule that matters most in this section

**Verify, do not relay.** The first background implementor run in this project reported zero
new analyzer issues when there were nine. **Paste the actual output into your report.** A
claim of a clean run without the output behind it is worth nothing, and if it turns out to be
wrong it costs more than the failure would have.

---

## Part 6: When to stop

**Stop and report. Do not invent your way past any of these.**

- A step is ambiguous, contradicts the spec, or looks wrong.
- Your plan's Dependencies table names something that has not landed.
- A `schemaVersion` is not the value your plan expects.
- A file your plan says to create already exists, or one it says to modify does not.
- The plan requires a package that is not in `pubspec.yaml`. **You may not add a dependency.**
- The plan needs a value only Aedwon has: a support URL, an email, a sectional timing.
- A test that has nothing to do with your change is already failing.
- The plan asks for a figure the data cannot produce. Say the data is missing. **Never
  substitute a plausible constant**, which is the most damaging thing an agent can do in this
  repository.
- Accessibility and the visual identity genuinely collide and you cannot satisfy both.

**A plausible invention is more expensive than a question, because it looks finished.** That
sentence is in `AGENTS.md` and it is the reason this section exists.

**Never edit the spec or the plan to resolve a disagreement with it.** If either needs to
change, that is a decision, and decisions are recorded before code changes.

---

## Part 7: What to report

Return this, and nothing decorative:

1. **Plan and tasks completed**, by number. Say plainly which tasks you did not do.
2. **Gate output, pasted.** The actual tail of `flutter analyze`, the actual test summary, the
   actual layering count. Not "all gates pass".
3. **Files touched**, and any that were not in the plan's file table, with why.
4. **Every stop condition you hit**, even if you worked around it.
5. **Anything you found that the plan did not know**, especially a live defect. Several plans
   in this repo exist because an earlier agent reported one.
6. **What you did not verify.** If the plan asks for an emulator check, say you did not do it.

**Aedwon owns visual verification.** Do not capture app/emulator screenshots or
start autonomous visual reviews. Report automated evidence separately from visual
acceptance. If Aedwon supplies screenshots and requests corroboration, review those
images within the assignment; do not treat that as permission to capture more.
He retains the final visual judgment. Findings go in `docs/ui-audit.md`.

---

## Part 7b: The verifier tier

**Current roles, September 25, 2026.** Responsibilities depend on the assignment,
not the provider. Follow `WORKFLOW.md` for the shared process and the current
execution arrangement. The verification requirements remain; retired subscription
and model tiers do not. Historical worker self-reports were repeatedly inaccurate.

| Tier | Role | Does |
|---|---|---|
| 1 | Lead | Triage, design, spec authorship, conflict rulings, integration and final acceptance. |
| 2 | Independent reviewer | Verifies implementation with the evidence and checks below. Does not author its own review target. |
| 3 | Implementor | Implements settled plan steps in its assigned worktree. The lead retains unresolved and high-consequence decisions. |

### Why an agent can verify another agent

**Because most of verification is deterministic and none of it is authorship.** The gates
return exit codes. Counts are counts. An em dash is present or it is not. A verifier does not
need judgment to run a command and paste what came back, and that is the bulk of the job.

**The rule that makes it safe: a verifier reports evidence, never assertions.**

A verifier that writes "all gates pass" has added nothing, because that is exactly what the
six wrong reports said. A verifier that pastes the command and its output has added the thing
the tier above it needs and can no longer be wrong about.

### What a tier-2 verifier does

**1. Verify the required evidence under Part 5.** Inspect its source identity,
scope, results, and actual output. Run assigned independent checks and any checks
whose evidence is missing or no longer applies. Preserve output in the verification
record. Do not repeat every full check merely because the reviewer changed.

**2. Re-derive, do not re-read.** This is the part a gate cannot do and it is why the tier
exists.

- **For a Mathematics or Science file: re-solve five items from scratch without reading the
  explanation.** Reading the explanation and agreeing with it proves nothing, because the
  explanation was written by the thing being checked. A wrong key survives every gate in this
  repository and only an independent solve catches it.
- **For a content file: pick three distractors and say what mistake each one represents.** If
  you cannot name the mistake, the distractor is filler and the item is weak.
- **For code: read the diff against the plan's file table.** Anything touched that the table
  does not name is a finding.

**3. Report exceptions, not a narrative.** A list of findings with file and line, or the
sentence "no findings" followed by the pasted evidence. **Do not restate what the plan asked
for.** The tier above it has read the plan.

**4. Never fix what you find.** A verifier that edits becomes an author and there is then
nobody checking it. Report and stop.

### What still comes to tier 1

- Any finding the verifier reports.
- Any "stop and say so" the implementor hit.
- The merge decision itself.
- Anything touching money, entitlement, migrations, or a student's own data.

**Everything else should reach the lead agent as one page: pasted gates, and either findings or
"none".**

### One combination worth using for answer keys

**Two separately assigned workers author the same Mathematics subtopic
independently, and a separate reviewer compares the answer keys.** Disagreement
requires resolution. Agreement is supporting evidence, not proof; independent
solving and the required content checks still apply.

**Use it only where a wrong answer is expensive and invisible**, which in this project means
Mathematics and the quantitative parts of Science. It doubles the authoring cost, so it is not
the default.

---

## Part 8: Running several agents at once

This is the intended mode: implementation plans in parallel while the specs continue.

- **One worktree each, always.**
- **Consult the collision map first**,
  `docs/superpowers/2026-08-04-execution-pipeline.md` Part 9 for the historical plans.
  Check current assignments and dependencies too. Two plans that both name
  `topicAccuracyProvider`, `InkCheckbox`, `InkTableRow`, `severityFor` or `entitlementProvider`
  must not run at the same time, or one silently reverts the other.
- **`lib/app/router.dart` is touched by 25 plans.** Those are merge conflicts rather than
  logic errors, but expect them and merge deliberately.
- **Respect the phases.** `2026-08-04-execution-pipeline.md` Part 2 orders them. Everything
  inside one phase is parallel-safe unless the collision map says otherwise; across phases it
  is not.
- **Content and code work can conflict through shared assets and generated output.**
  Run them together only when current assignments and shared resources are independent.
- **The dispatcher verifies each result independently before merging.** Do not merge on an
  agent's own report, however confident it reads.

---

## Part 9: The five rules, if you read nothing else

1. **Read `AGENTS.md`, your plan and its spec before writing a line.**
2. **Work in your own worktree.**
3. **Test first, one task at a time.**
4. **Run the gates and paste the output. Verify, do not relay.**
5. **Stop and ask rather than invent. Never print a figure this project did not measure.**
