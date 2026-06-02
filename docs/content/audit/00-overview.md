# Content Audit — Overview

Spec: ../../superpowers/specs/2026-07-18-content-audit-design.md
Benchmarks: `benchmarks/*.md` (UPCAT, ACET, DLSUCET/DCAT, USTET, DOST-SEI).
Mechanical baseline: `sweep-results.tsv` (regenerate with
`python3 tools/audit/run_all.py`).

## Outline coverage vs benchmark exams

The outline (`tools/lesson_author/outline.json`) was diffed against the
union of the five benchmark checklists. Headline: coverage is strong and
in several areas exceeds CET scope. No CET-tested topic is wholly absent.

### Missing from outline
- None material. Every subtest topic across the five exams maps to at
  least one outline lesson. The corpus is a superset of the university
  CET blueprints.

### Covered but thin (verify in judgment pass)
- OUTLINE-001 [important] Filipino-language coverage: UPCAT and USTET test
  Language Proficiency and Reading Comprehension in Filipino. Outline
  entries name Filipino counterparts (Paksa ng Talata, Sawikain at
  Tayutay, Bahagi ng Pananalita, Nang vs. Ng), but whether the lesson
  bodies actually teach the Filipino side or only gloss it is a
  depth question for Tasks 10–11.
- OUTLINE-002 [important] Filipino reading passages: Text Types lessons
  should include at least one Filipino passage type, since both UPCAT and
  USTET present Filipino comprehension texts. Confirm in Task 11.

### In outline but tested by no university CET (DOST-only or beyond)
Flag only — never delete without approval. All justified by DOST-SEI
Scientific Ability's higher physics/chemistry ceiling or STEM-strand
value; keep.
- OUTLINE-003 [polish] Pre-Calculus & Basic Calculus (Limits, Derivatives,
  Integrals, Conic Sections): beyond university CET scope; valuable for
  DOST-SEI STEM candidates and SHS STEM strand. Keep, deprioritize for
  CET-only learners.
- OUTLINE-004 [polish] Chemistry depth (Quantum Numbers, Nuclear
  Chemistry, Stoichiometry limiting-reactant): exceeds UPCAT basics;
  matches DOST-SEI Scientific Ability. Keep.
- OUTLINE-005 [polish] Inverse Trigonometric Functions, Laws of
  Sines/Cosines: light-to-absent on most CETs; useful ceiling. Keep.

## Judgment-pass findings (per subject)

Full detail: `mathematics.md`, `science.md`, `language-proficiency.md`,
`reading-comprehension.md`, `reasoning.md`.

## Totals

Mechanical sweep produced 339 lines (8 blocker, 188 important, 143 polish).
After the judgment pass curated them, **6 blockers survive** (2 sweep
blockers were false positives — see below).

| Subject | Blockers (real) | Important | Notes |
|---|---|---|---|
| Mathematics | 2 | formula gaps + illustrations | 2 real formula gaps; most FORMULA lines were FPs |
| Science | 0 | illustrations + 1 template | all FORMULA/DEVICE lines were FPs (units, elements, convention prose) |
| Language Proficiency | 4 | Filipino grammar + answer leak | the underline defect lives here |
| Reading Comprehension | 0 | visual-media images + Filipino passage | 1 sweep blocker was a FP |
| Reasoning | 0 | 40 figure-dependent examples | the largest illustration gap |

Two sweep "blockers" were dismissed as false positives:
`science/biology/taxonomy-and-classification.md:35` (prose explaining that
scientific names are italicized/underlined by hand — not a broken question)
and `reading-comprehension/.../sequencing-of-events.md:64` ("underline
time-signal words as you read" — a study instruction).

## Status: Phase 1 complete

All 6 blockers are fixed and the two target formula gaps are closed;
`run_all.py` now reports **0 blockers**. LANG-VOC-004 (answer-leak) was
withdrawn on review — it is a deliberate synonym-clue example, not a
defect. The list below is kept as the record of what was fixed.

## Top blockers (now fixed)

1. LANG-VOC-001/002 — `context-clues.md:32,81`: questions say "underlined
   word" but the target is bold.
2. LANG-VOC-003 — `spelling-rules.md:24`: four "underlined words" not
   marked at all.
3. LANG-APP-001 — `error-identification.md:40`: "underlined portion" is
   italic.
4. LANG-VOC-004 — `context-clues.md:32`: question defines its own answer
   ("edict, or official command").
5. MATH-ARI-001 — `prime-factorization-gcf-lcm.md:38`: "which of the
   following" with no choices listed.
6. MATH-GEO-001 — `logic-and-reasoning.md:84`: answer choices only
   narrated in the solution, not shown.

All four underline blockers share one root cause and one decision (below).

## The underline rendering decision (blocks the language fixes)

Markdown cannot underline. Questions authored for underlined target words
were silently reduced to bold/italic (contradicting the word "underlined")
or lost their marking. Pick one convention corpus-wide:
- **(a) bold + reword** "underlined" → "in bold" — recommended; no renderer
  change, matches existing usage in 3 of 4 cases.
- (b) `<u>…</u>` — only if the Flutter markdown renderer passes raw HTML;
  the style guide currently forbids HTML except ILLUSTRATION comments.
- (c) a fixed delimiter (e.g. «guillemets»).

Verify the renderer before choosing (b).

## Template reform (per-subject)

The app renders section titles generically (no code depends on them), so
these are pure content/style-guide changes:
- **Mathematics** — keep the five sections; add a rule that all formulas
  appear in Core Concept before Examples.
- **Science** — rename "Speed Tricks & Shortcuts" to **"Exam Strategies"**
  for conceptual biology/earth-science; keep it where real calculation
  shortcuts exist; allow an optional **"Key Terms"** glossary for
  term-dense lessons.
- **Language Proficiency** — allow **"Common Confusions" / "Usage Notes"**
  in place of Speed Tricks.
- **Reading Comprehension** — allow **"Reading Strategies"** as the
  Speed-Tricks alias.
- **Reasoning** — sanction a reduced **Core Concept → Worked Examples (with
  figures) → Common Traps** layout; drop the forced Speed Tricks/Mnemonics.

## Style guide v2 — remove the guide-mandated AI tells

The guide currently *requires* some of the strongest AI signals. v2 should:
- Replace blanket **ALL-CAPS emphasis** with bold/italic — 3,980 all-caps
  emphasis tokens across 139 lessons is the loudest tell in the corpus.
- Vary the trap opener; **29** "test-makers often…" instances read as a
  template.
- Vary lesson summaries; **90** lessons open "This lesson teaches you…".
- Curb em-dash-for-emphasis (399 corpus-wide) and the 8 "not just X but Y"
  constructions.
- Document the two illustration exceptions (visual-media, reasoning) where
  the image is load-bearing.

## De-AI rewrite scope (ranked)

Highest AI-tell density (rewrite first): science physics/chemistry lessons
and `truth-tables-propositional-logic.md` (56–76 all-caps tokens each),
then biology and the remaining science, then reasoning. Full per-lesson
counts regenerate via `python3 tools/audit/sweep_ai_tells.py`. Facts stay
unchanged; only prose rhythm, emphasis style, and stock phrasing change.

## Recommended fix order

1. **Blockers (6)** — the four underline defects (after the rendering
   decision) + two missing-choice math questions + the answer-leak
   rewrite. Small, high impact.
2. **Template restructure + style guide v2** — do before the rewrite so
   prose is touched once. ~all lessons get section-title review; science
   and reasoning change most.
3. **De-AI rewrite** — ~139 lessons, ranked above.
4. **Coverage additions** — Filipino grammar notes (7 lessons) and at least
   one Filipino reading passage; no new whole topics needed (outline is
   CET-complete).
5. **Illustration backlog** — ~250 placeholders. Prioritize the
   load-bearing sets first: reasoning (40 examples) and `visual-media.md`
   (4), then physics (13), geometry/trig (61), then the rest.

Re-run `python3 tools/audit/run_all.py` after each phase; fixed classes
should drop to zero.
