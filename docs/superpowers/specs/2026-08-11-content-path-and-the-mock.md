# One content path, and a mock a student can sit

**Written 11 August 2026**, after Aedwon asked where mock exams were and the
answer turned out to be two questions deep.

**This spec describes the destination**, not the diff. Code belongs in the plans
that follow it.

---

## Section 1: The problem, in one paragraph

**A student cannot sit a mock exam, and no single change makes them able to.**
The mock screens are built, its routes exist, and `MockPanel` is finished. It
has never been on screen because the router passes `const QuizTabHome()` and
the tab's `mockPanel` parameter is never filled. Wiring it would open a door
onto an empty room: a mock is built from a `mockBlueprint`, blueprints are read
from `content.db`, and **`content.db` is not the database the app runs on**.

## Section 2: What exists today, counted rather than remembered

**Two content stores, and the app uses the one that was meant to be temporary.**

| | `assets/seed/v1.json` → `AppDatabase` | `assets/seed/content.db` → `ContentDatabase` |
|---|---|---|
| Built by | `tools/build_dev_seed` from `content/` | `tools/build_content_seed/seed_writer.dart` |
| Its input | The authored corpus | **`test/fixtures/sanity/content_sample.json`**, a unit test's fixture |
| Exams | 7, two of them with content | **1** |
| Topics | 19 | **1** |
| Questions | **2,000** | **1** |
| Mock blueprints | none, no table | **1**, and it is the fixture's |
| Read by | every screen a student sees | `performance_provider` for published sizes, and the mock's blueprint providers |

**The one blueprint is `blueprint_cse`**, a 90 minute "CSE Practice" keyed to
`exam_cse`. **The app ships no exam with that id**; its Civil Service exam is
`exam_cse_pro`. So the single blueprint that exists is addressed to nobody.

**The counts above are from a fresh build**, which is what a checkout and what
CI produce. A stale `content.db` dated 20 July, holding 16 questions and no
blueprints, was in one working tree and briefly gave this document worse
numbers. The file is gitignored; there is no committed copy to disagree with.

**The generator says so itself.** `build_dev_seed.dart` opens with: *"Temporary
dev tool: the app's shipping content path is the Sanity to content.db pipeline,
which no UI reads yet."*

**And the roadmap agrees.** Spec 5 specifies "blueprint-driven mock generation
from `mockBlueprint` Sanity docs", and the Sanity spec's own scope line is
"replace bundled `assets/seed/v1.json` with Sanity-sourced data".

### What is already built on the Sanity side

More than the state of it suggests. `SanityClient` with GROQ queries for all
eight doc types and an incremental `_updatedAt` variant; parsers for every type
with a schema-version check; `seed_writer` to build the database; and
`SeedInstaller`, which installs the bundled copy to application support and is
called from `bootstrap`. **What is missing is that nothing feeds the real
corpus through it, and no screen reads the result.**

## Section 3: Scope, stated plainly because it was overstated

**"A mock on every exam" is two exams, not seven.**

| Exam | Active | Subjects | Composition on record |
|---|---|---|---|
| UPCAT | yes | 5 | **Yes**, supplied 11 August |
| CSE Professional | yes | 1 | Total only: 170 items, 3h10, one booklet |
| ACET, DLSUCET, USTET, PUPCET, CSE Sub | **no** | **0** | ACET and USTET partly; the rest not at all |

**Five of the seven ship inactive with zero subjects and zero questions.** A
blueprint for them is blocked on content, not on this work. The timings
collected on 4 August cover **DCAT and MSU-SASE, which are not in the roster at
all**, and the roster's DLSUCET and PUPCET have none.

**This spec covers UPCAT.** CSE Professional follows when its per-section
composition is established; it needs none to run, being one untimed booklet,
but it has one subject of content and a mock of it would be thin.

## Section 4: The decisions this spec makes

### 4.1 The content database becomes the one the app reads

**`v1.json` is retired as a runtime input.** Every screen reads
`ContentDatabase`. This is the roadmap's design and the reason the parsers,
the queries and the installer already exist.

**It is not retired as a build step.** The corpus under `content/` is the
source of truth an author edits, and it keeps its generator. What changes is
its output: **the corpus is written as Sanity-shaped documents, and
`seed_writer` builds the content database from those**, rather than the corpus
being written straight into a second schema that only the app understands.

**The fixture stops being the shipped input.** CI builds the asset from the
corpus. `test/fixtures/sanity/content_sample.json` returns to being what its
name says.

### 4.2 One id convention: underscores

`exam_upcat`, `topic_upcat_algebra`, `subj_upcat_mathematics`. **Not because
underscores are better, but because 2,000 questions, 144 lessons and every
attempt a student has already recorded are keyed to them.** The hyphenated ids
exist only in a test fixture and in a 16-question database nothing reads.

**A student's history is the constraint.** Attempts, review state and lesson
progress store question and topic ids. Changing them orphans a real person's
record, which is the one thing a migration may not do.

### 4.3 Blueprints live with the content, and carry their evidence

A `mockBlueprint` document per exam, authored in `content/` beside the
questions, built into the content database by the same step.

**Every blueprint records where its numbers came from**, because the setup
screen prints them to a student before they commit an afternoon:

- `source: published` with a citation, or
- `source: reported`, attributed and dated.

**UPCAT is `reported`.** UP publishes the four subtest names and "about five
hours" of administration, and nothing else. Aedwon supplied the composition on
11 August, marked reported rather than published, the same standing ACET and
DCAT have carried since 4 August.

### 4.4 The mock panel is wired last

**Not first.** A door onto an empty room is worse than a wall, and the panel
already knows how to say it is unavailable.

## Section 5: The destination

**A student opens Quiz and sees the mock panel under the session panel.** It
states the paper: 4 parts, 250 questions, 3 hours 50 minutes. Tapping through
reaches the setup screen, which names each part with its items and its minutes,
says the paper runs part by part and cannot be re-entered, and starts a clock.

**Progress fills in at the same moment.** The performance table's subtext
carries each section's published size, which is blank today for exactly the
same reason. **One blueprint lights both.**

**Nothing else a student sees changes.** The same 2,000 questions, the same
lessons, the same progress, read from a different database.

## Section 6: Sequence

Each step ships and is verifiable on the device before the next begins.

1. **The corpus builds Sanity-shaped documents.** `content/` gains an export
   that `seed_writer` accepts. Verified by counts: the content database holds
   2,000 questions and 144 lessons, not 16 and 0.
2. **The app reads the content database.** Readers move over behind the
   existing repos. Verified by the app running with `v1.json` removed from
   `pubspec.yaml`.
3. **The UPCAT blueprint is authored** and lands with the rest of the content.
   Verified by the Progress table printing published sizes.
4. **The mock panel is wired** into the Quiz tab from the router, which is the
   contract `MockPanel` already documents.
5. **A full UPCAT mock is sat end to end** on the device, with the sectional
   clock, and its results reach Progress.

## Section 7: What this is not

- **Not a live Sanity sync.** The client exists and stays unused for now; the
  app ships a bundled database and installs it. Remote refresh is a later
  spec, and nothing here blocks it.
- **Not a content project.** No question is written or rewritten. The five
  empty exams stay empty.
- **Not a redesign.** Every mock screen is already specified in
  `2026-07-28-mock-exam-ui-design.md` and built.

## Section 8: Open, and Aedwon's to answer

1. **Is Reasoning a UPCAT subject?** UP lists four subtests and the seed
   carries five, adding Reasoning. The blueprint has four parts either way;
   the question is whether Study and Progress should keep teaching a fifth
   that is not on the paper.
2. **CSE Professional's per-section composition**, if its mock should be more
   than one untimed booklet of 170.
3. **DLSUCET and PUPCET timings**, whenever their content is authored. Not
   blocking.
