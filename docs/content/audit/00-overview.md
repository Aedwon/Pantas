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

See `mathematics.md`, `science.md`, `language-proficiency.md`,
`reading-comprehension.md`, `reasoning.md`. Roll-up completed in the final
task.

<!-- ROLL-UP SECTIONS (totals, top blockers, template reform, style guide
v2, de-AI scope, fix order) added in Task 13 after judgment pass. -->
