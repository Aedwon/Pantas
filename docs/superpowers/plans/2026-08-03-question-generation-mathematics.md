# Mathematics Question Generation, Content Plan

> **How to work this plan.** One subtopic at a time, in order. Write the YAML, validate it,
> and only then move on. Never batch several subtopics before validating.
>
> **Required reading before row 1:** `SUBAGENTS.md` at the repository root, Part 4 in full,
> then `AGENTS.md`, then `docs/content/question-blueprints/mathematics.md`, then
> `docs/content/question-style-guide.md`.
>
> **Follow the plan. Do not redesign.** If a lesson named in a manifest row does not exist,
> or the validator fails in a way its message does not explain, **stop and say so**.

**Goal:** Author, validate and commit question YAML for all 44 Mathematics subtopics across
six topics, using the static question pipeline that already produced science, language and
reasoning.

**Why this plan exists.** Mathematics was always going to be produced by a template quiz
engine, and that engine was deferred to a later version on 3 August 2026. **Deferring it took
the entire subject with it:** all six Mathematics topics have zero questions today, and
Mathematics is a section in UPCAT, ACET, DLSUCET, USTET and PUPCET. Without this,
`MockSampler` cannot fill a paper for five of the seven exams.

**Source lessons already exist:** 44 files under `content/lessons/mathematics/`, verified on
3 August. Nothing here needs authoring from scratch.

**Decision log:** `docs/superpowers/decisions/2026-08-03-plan-audit-log.md`.

## Global Constraints

- **Work only inside your worktree.** Never write to the main checkout.
- **Write only under `content/questions/mathematics/`.** Nothing in `lib/`, nothing in
  `test/`, no other subject's directory.
- **Never invent a figure.** Every number in a stem, a choice or an explanation is one you put
  there on purpose and can defend. **Work the item yourself before writing the explanation**:
  an explanation reverse-engineered from a chosen letter is how a wrong key ships.
- **LaTeX for anything that is not plain prose.** `$\frac{3}{4}$`, never `3/4`. `$x^2$`, never
  `x^2`. It renders through `flutter_math_fork`.
- **American spelling. No em dashes**, use a comma or a colon.
- **Leave `approved:` unset.** Question Studio sets it and Aedwon approves by hand.
- **Do not tick a Done box in this file, do not run Question Studio, and do not commit**
  unless the dispatching instruction says to. Validation is not approval.
- **Never generate an image.** Figures are hand-made. Add `figure: <slug>` and log it.
- **12 to 20 questions per subtopic**, ids ascending, difficulty ramping easy to exam level.

## The Generation Procedure, applied to every row

- [ ] **Step 1: Read the source lesson**

`content/lessons/mathematics/<topic>/<subtopic>.md`. Note its worked examples and especially
its **"Traps to Watch For"** section: those traps mirror real student mistakes and are the
best distractor material available.

- [ ] **Step 2: Pick archetypes**

From `docs/content/question-blueprints/mathematics.md`, choose the archetypes that genuinely
fit. **`error-spotting` is the highest-value archetype in this subject** and the one exams use
most, so include it wherever the subtopic has a procedure that can go wrong. Skip any
archetype that does not fit rather than forcing it.

- [ ] **Step 3: Write the YAML**

`content/questions/mathematics/<topic>/<subtopic>.yaml`:

```yaml
meta:
  subject: mathematics
  topic: <topic slug>
  subtopic: <subtopic slug>
  exams: [upcat, acet, dlsucet, ustet, pupcet]
questions:
  - id: q-<topic slug>-<subtopic slug>-0001
    type: <archetype name>
    difficulty: easy
    stem: |
      ...
    choices:
      - text: ...
        correct: true
      - text: ...
      - text: ...
      - text: ...
    explanation: |
      ...
```

**Set word problems in the student's own world.** Jeepney fares, load, rice by the kilo, a
sari-sari store, a tricycle queue. Not baseball statistics and not dollars.

- [ ] **Step 4: Validate, before writing another file**

```bash
dart run tools/import_questions/import_questions.dart --root content/questions >/dev/null 2>&1; echo "exit: $?"
```

Exit code 0. If it fails it names the exact file and question id. Fix and rerun.

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


- [ ] **Step 5: Check your own arithmetic**

Re-solve three items from the file you just wrote, chosen at random, without looking at the
key. **If any disagrees with its marked answer, re-solve every item in the file.** No
validator can catch a wrong key and no reviewer will catch all of them.

## Definition of Done, per subtopic

- 12 to 20 questions, ids ascending with no gaps.
- Difficulty ramps: roughly a third easy, a third medium, the rest hard or exam level.
- **Every distractor is a real mistake**, traceable to the lesson's traps, to a sign error, to
  the right operation one step short, or to the other formula from the same lesson.
- No item is answerable by elimination alone.
- Every angle carries its unit. Every currency figure uses pesos.
- `approved:` unset. Validator exit 0.

---

## Manifest, Arithmetic & Number Sense

Topic slug `arithmetic-number-sense`. Exams for all rows:
`[upcat, acet, dlsucet, ustet, pupcet]`.

| Done | Subtopic slug | Primary archetypes |
|---|---|---|
| [ ] | `order-of-operations` | `error-spotting`, `direct-computation` |
| [ ] | `properties-of-real-numbers` | `which-is-true`, `direct-computation` |
| [ ] | `divisibility-rules` | `which-is-true`, `direct-computation` |
| [ ] | `prime-factorization-gcf-lcm` | `direct-computation`, `word-problem` |
| [ ] | `fractions-decimals-percentages` | `direct-computation`, `word-problem` |
| [ ] | `ratio-and-proportion` | `word-problem` |
| [ ] | `business-math` | `word-problem` |
| [ ] | `sequences-and-series` | `which-is-true`, `direct-computation` |
| [x] | `real-imaginary-numbers` | `which-is-true` |

**`business-math` is where Filipino context matters most:** discounts, commission, simple
interest, markup, and a sari-sari store's margins.

## Manifest, Algebra

Topic slug `algebra`. **The heaviest topic and the one exams weight most.**

| Done | Subtopic slug | Primary archetypes |
|---|---|---|
| [ ] | `algebraic-expressions` | `direct-computation`, `error-spotting` |
| [ ] | `linear-equations-inequalities` | `error-spotting`, `word-problem` |
| [ ] | `systems-of-equations` | `word-problem`, `direct-computation` |
| [ ] | `quadratic-equations` | `direct-computation`, `error-spotting` |
| [ ] | `polynomials` | `error-spotting`, `direct-computation` |
| [ ] | `radicals-and-rationalization` | `direct-computation`, `error-spotting` |
| [ ] | `exponents-and-logarithms` | `which-is-true`, `direct-computation` |
| [ ] | `functions-and-relations` | `which-is-true` |
| [ ] | `types-of-functions` | `which-is-true` |
| [ ] | `sets-and-set-notation` | `which-is-true`, `word-problem` |
| [ ] | `word-problems` | `word-problem` throughout |

**Three mistakes worth building `error-spotting` items around**, because they are the ones
students actually make: a dropped sign, distributing over a bracket, and squaring a sum.

**`word-problems` is the exam's standard set:** age, mixture, work, and motion.

## Manifest, Geometry

Topic slug `geometry`. **Describe the figure in words wherever the item survives it.**

| Done | Subtopic slug | Primary archetypes | Figure |
|---|---|---|---|
| [ ] | `basic-geometric-concepts` | `which-is-true` | none |
| [ ] | `parallel-perpendicular-lines` | `direct-computation` | rarely |
| [ ] | `triangles` | `direct-computation`, `which-is-true` | rarely |
| [ ] | `quadrilaterals-and-polygons` | `direct-computation` | rarely |
| [ ] | `circles` | `direct-computation` | sometimes |
| [ ] | `measurement` | `word-problem`, `direct-computation` | compound shapes only |
| [ ] | `coordinate-geometry` | `direct-computation` | **often** |
| [ ] | `logic-and-reasoning` | `which-is-true` | none |

**Amended 3 August, on Aedwon's ruling.** Where an item genuinely needs a diagram, **describe
it accurately in the stem and reserve the illustration too.** Both. The description carries
exact measurements and the item is answerable without the image, so the question ships now and
gains a picture later. Log every slug in `docs/content/question-figures/worklist.tsv`.

Angle chasing, the triangle inequality and the area of a compound shape all work as pure
prose and need no slug at all. Reserve `figure:` for coordinate geometry and for anything with
more than one intersecting line.

## Manifest, Trigonometry

Topic slug `trigonometry`. **State the angle unit in every stem**, degrees or radians.

| Done | Subtopic slug | Primary archetypes |
|---|---|---|
| [ ] | `angles-and-radian-measure` | `direct-computation`, `which-is-true` |
| [ ] | `basic-trigonometric-ratios` | `direct-computation` |
| [ ] | `unit-circle` | `which-is-true`, `direct-computation` |
| [ ] | `solving-right-triangles` | `word-problem`, `direct-computation` |
| [ ] | `laws-of-sines-and-cosines` | `direct-computation` |
| [ ] | `trigonometric-identities` | `which-is-true`, `error-spotting` |
| [ ] | `inverse-trigonometric-functions` | `which-is-true` |

## Manifest, Statistics & Probability

Topic slug `statistics-and-probability`.

| Done | Subtopic slug | Primary archetypes |
|---|---|---|
| [ ] | `measures-of-central-tendency` | `word-problem`, `which-is-true` |
| [ ] | `measures-of-variability` | `direct-computation`, `which-is-true` |
| [ ] | `data-analysis-graphs` | `word-problem` |
| [ ] | `basic-probability` | `word-problem` |
| [ ] | `combinatorics` | `word-problem` |

**Mean, median and mode confusion is the single most productive distractor source in the
subject.** Use it.

**Combinatorics stems must say plainly whether order matters**, because the exam does.

**`data-analysis-graphs` will want figures.** Where a table serves instead of a chart, write
the table into the stem as text and ship it now.

## Manifest, Pre-Calculus & Basic Calculus

Topic slug `precalculus-basic-calculus`. **The lightest topic, and deliberately so.**

| Done | Subtopic slug | Primary archetypes |
|---|---|---|
| [ ] | `limits-and-continuity` | `which-is-true`, `direct-computation` |
| [ ] | `basic-derivatives` | `direct-computation` |
| [ ] | `basic-integrals` | `direct-computation` |
| [ ] | `conic-sections` | `which-is-true` |

**Do not exceed the lesson.** Derivatives and integrals stay at the power rule and nothing
beyond it. This topic appears on UPCAT and not on the others, and inventing depth it does not
test wastes the student's time.

**Conic sections is the one row here that may want a figure.** Same rule as Geometry: describe
it in the stem with exact values, reserve the slug, log the worklist row.

---

## Suggested order

Algebra first, because it is the heaviest and the most reused. Then Arithmetic, then
Statistics, then Trigonometry, then Geometry, then Pre-Calculus. **Geometry is late on
purpose:** it is the topic most likely to need figures, and the figure worklist is Aedwon's
hand-illustration queue.

## Self-Review, before reporting

- Every manifest row you attempted has a file, and every file validates.
- You re-solved three items per file and they agreed with their keys.
- `grep -c '—'` returns 0 for every file you wrote.
- No `approved:` appears anywhere.
- No file outside `content/questions/mathematics/` changed.
- Report the per-file question count and the validator's **pasted** exit code, not a summary
  of it.
