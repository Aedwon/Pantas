# Content Quality Audit — Design

Date: 2026-07-18
Scope: all 151 lessons in `content/lessons/` (5 subjects, 18 topics).

## Goal

A student who opens a lesson their teacher has not taught can learn the
topic alone and answer real CET questions on it. Also: remove every
detectable sign that the content was AI-written.

## Benchmark

CET coverage only: UPCAT, ACET, DLSUCET, USTET, DOST-SEI. For each
subject, compile a tested-topics checklist from published exam scopes and
reviewer coverage, then diff the corpus against it. DepEd curriculum
coverage beyond the CETs is out of scope.

## Process: three-layer audit

Run layer 0 (outline coverage) first, then layer 1 (mechanical) across
all lessons, then layer 2 (judgment) topic by topic. Record findings as
they are found; checkpoint after each topic so the audit survives
context loss.

### Layer 0 — outline coverage check

Diff `tools/lesson_author/outline.json` (every subject, topic, lesson,
and section) against the researched scope of each benchmark exam,
including the DOST-SEI scholarship exam's distinct areas (it tests
science aptitude and self-assessment sections the university CETs do
not). Output: missing lessons or topics to add to the outline, plus any
outline entries no exam tests (candidates to deprioritize, flagged but
never deleted without approval). The user has checked this before; the
audit re-verifies it against sources rather than assuming it.

### Layer 1 — mechanical sweeps (scripted, exhaustive)

1. **Referenced-device check.** Any question that mentions an
   "underlined" / "boldfaced" / "italicized" word, a figure, or "which
   of the following" must contain the actual device: the marked word,
   the illustration placeholder, the answer choices. Markdown has no
   native underline, so the audit also proposes one rendering
   convention (verify what the app's markdown renderer supports before
   choosing).
2. **Formula completeness.** Every formula used in an Examples solution
   must first be taught in Core Concept. Extract display/inline math
   from solutions and match against the teaching sections.
3. **Per-example illustration check.** In visual topics
   (spatial-abstract reasoning, mechanical reasoning, geometry,
   trigonometry graphs, physics setups, chemistry structures, biology
   diagrams), every example that describes a figure needs a placeholder
   at that spot. Known offender: all 5 spatial-abstract lessons carry
   one placeholder each while every example describes figures in prose.
4. **AI-tell inventory.** Per-lesson counts of: ALL-CAPS emphasis,
   em-dash density, "not just X — Y", rule-of-three constructions,
   stock phrases ("it's important to note", "delve", "crucial"),
   uniform trap openers ("Test-makers often…"), identical summary
   openers ("This lesson teaches you…").
5. **Structure inventory.** Section names and order per lesson, missing
   `**Solution:**` labels, frontmatter shape, `estimatedMinutes` range,
   answer-choice formatting consistency.

### Layer 2 — judgment pass (read every lesson)

Per topic, against the CET checklist:

1. **Exhaustiveness.** Which tested sub-skills have no lesson or no
   example? Which lessons skip a standard question form?
2. **Correctness.** Re-derive every worked answer. Flag questions that
   give away their own answer (e.g. `context-clues.md` #1 defines
   "edict" inside the question).
3. **Self-teachability.** Missing prerequisites, undefined terms,
   missing Filipino terms where exams use them, difficulty ramps that
   jump.
4. **Template fit.** Where the Math-derived five sections misfit the
   subject, propose the per-subject replacement structure.
5. **Illustration judgment.** Figures a topic conventionally needs that
   neither text nor placeholders provide.

## Deliverable

`docs/content/audit/` — `00-overview.md` plus one findings file per
subject. Every finding gets an ID (`MATH-ALG-007`), a severity, and a
fix type:

- **Blocker** — wrong answer, broken reference, unteachable example.
- **Important** — coverage gap, missing figure, template misfit.
- **Polish** — AI tells, wording, formatting drift.

The user approves findings in bulk by severity or line by line.

## Fix phases (each starts only after approval)

1. Blockers: correctness, broken references, formula gaps.
2. Per-subject template restructure plus style guide v2. The v2 guide
   also drops guide-mandated AI tells so new lessons stay clean.
3. De-AI rewrite pass (after restructure, so prose is rewritten once).
4. New lessons and examples for CET coverage gaps.
5. Illustration placeholder backlog: add missing ones, sharpen vague
   ones.

## Out of scope

- Producing the images themselves (placeholder pipeline only).
- Quiz/question-bank features (see dynamic-quiz idea, deferred).
- DepEd-only topics that no CET tests.

## Error handling

- A finding the audit cannot verify (e.g. an exam's exact scope) is
  marked "unverified" with its source, never silently asserted.
- Ambiguous severity defaults upward (blocker over important).

## Testing the audit itself

- Mechanical sweeps are scripts checked into `tools/audit/`; rerunning
  them after fixes must return zero findings for the fixed classes.
- Known seeded cases (context-clues underline, spatial figures,
  quadratic formula intro) must appear in the findings, or the sweep is
  broken.
