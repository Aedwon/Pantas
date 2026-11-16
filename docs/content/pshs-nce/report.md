# PSHS-NCE verbal, science and abstract: report

November 17, 2026 (Philippine time). Branch `content/pshs-nce-r1`. Nothing uploaded.

## Result

- Map of the 70 official sample items (Tests II to IV): 45 covered, 21 partial, 4 missing (`map-summary.md`, `map.jsonl`). Transcript: `reviewer-transcript.md`. Source and disputed keys: `source.md`.
- **Overlapping Shapes and Dot Placement** (IV-13 to IV-16): lesson written by Codex GPT 6.1 Sol; Astra round 1 found 1 Major (radius used but not taught), fixed; round 2 clean. **No questions**, by the manager's ruling: the figure kind does not exist and the generator does not own it (backlog D22).
- **More Figure Rules: Counts, Grids and Analogies** (IV-5, 6, 8, 10, 11, 12, 17, 18, 19): lesson clean on Astra round 1 (1 Minor). 20 questions, five choices, `exams: [pshs-nce]`, using only the five figure kinds the app draws, text choices. Fit read 1: 5 Majors (correct answer always first, two wrong rationales, a giveaway, a stem clue), all fixed by Sol. Blind solve: 20 of 20 match. Fit read 2: 1 Major (the key was the only choice written "Figure 4"), fixed by the lead; one wrong choice in question 1 normalized the same way. Validator exit 0.
- Methods taught in the lesson but with no question, because their figure cannot be drawn with existing kinds: closed solids versus open surfaces, grids with several blanks or stripe backgrounds, missing pattern pieces, fill-swap analogies, opening tracking, marked prism nets.

## Deferred (backlog on main)

- D21: 4 grammar and 3 science partials, decided before the Dec 8 go/no-go.
- D22: the dots-in-shapes figure kind, engineering.

## Tooling note

The blind-solve packet builder accepts only CET exam tags (`qloader.py`, `CET_EXAMS`). The solve ran from a scratch copy that adds `pshs-nce`; the repository tool is unchanged. Adding `pshs-nce` there is a one-line change for whoever owns the tool.

Figures: both lessons carry ILLUSTRATION markers only; the figure phase stays paused.
