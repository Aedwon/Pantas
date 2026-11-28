# Brief: fix the math layout in four Math pictures (manager, Nov 28; one worker, one pass)

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from GitHub main (`git show origin/main:<file>`) and follow
them. Read `git show origin/main:docs/content/lesson-svg-authoring.md`. Lead's policy commit `3bffd9286`.

Worktree: `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-cse-math-finish-55955c9731459ccd/7ab66a46-209f-4182-80b0-634771f1bda3/scratchpad/reasoning`.
Hard rules: edit only the four SVG files below, only with the Edit or Write tool. Bash only for read-only commands, git
show/diff/status/log and the check below, with plain arguments (no pipes into sed, no redirection, heredocs or scripts).
Do not commit. Do not start subagents. Do not change any lesson file.

## The defect (release lead's staging picture check)

On the app's renderer, these pictures set exponents and subscripts on top of the "=" sign. Each builds a label such as
"a₁ = 5" or "i² = −1" as one `<text>` with nested `<tspan dy="...">` pieces and `text-anchor="middle"`. The app does not
advance the following tspan past a shifted one, so the raised or lowered digit and " = ..." overlap. No picture that
passed the staging check uses `tspan` with `dy`.

## Files (under `content/illustrations/mathematics/arithmetic-number-sense/`)

1. `arithmetic-sequence-terms/01-five-terms-four-steps.svg`
2. `imaginary-unit-and-powers/01-four-step-cycle-of-powers-of-i.svg`
3. `greatest-common-factor/01-shared-prime-tiles-of-48-and-180.svg`
4. `prime-factors-and-powers/01-factor-tree-for-60.svg`

## The fix

- Replace every label that raises or lowers text with separate `<text>` elements, each with its own absolute `x` and `y`
  and `text-anchor="start"`: the base (for example `a` or `i`), the raised or lowered digit (smaller font, its own `y`
  about 6 px above or 3 px below the base line), and the rest (" = 5") starting after the digit. No `tspan` with `dy`,
  `dx` or `baseline-shift` anywhere in these files.
- Work out each piece's x from the font size: Geist at 16 px averages about 9 px per character, at 12 px about 7 px; a
  digit is about 0.6 of the font size wide, "=" about 0.6, a space about 0.3. Leave at least 2 px between the raised or
  lowered digit and the next piece. Keep each whole label centered where it is now (shift the start x left by half the
  label's estimated width).
- Keep every other element, every color (theme colors only: `#010101`, `#020202`, `#030303`, `#040404`, `#050505`), the
  `viewBox`, the `<title>` and every number and label exactly as they are. Light and dark both come from the theme colors,
  so do not add fills.
- Text stays 12 px or larger. Nothing may run outside its box or the viewBox.

## Check

`cd <the worktree> && python3 /Users/aedwon/.t3/worktrees/Pantas/content-cse-math-finish-55955c9731459ccd/tools/check_lesson_svgs.py . --validate-only`
Report its lines for these four folders (the 2 known failures in `docs/content/rewrite/figure-style/` are not yours).
Also confirm with `grep -c "dy=" <file>` that each file has 0.

## Report (under 250 words)

Per file: which labels changed, the x positions you used for one label, and the check output. Anything you could not fit.
