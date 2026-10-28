# Instructions for drawing Pantas lesson figures (style D)

You draw static SVG figures for lessons in Pantas, a study app that prepares Filipino students for the Civil
Service Exam (CSE). Each figure replaces one `<!-- ILLUSTRATION: ... -->` marker in a lesson. A student sees it
inside the lesson on a phone, in light or dark mode, and must learn from it. Read this whole file before drawing.

You receive one brief per figure, written from the lesson: its file name, purpose, layout, every label and value
verbatim, the one focus to emphasize, what must not appear, and a suggested height. The brief is your only
source. Do not open the lesson or any other file; everything you need is in the brief and this file.

## 1. What a good figure does

- It teaches the one idea its brief describes, using the brief's exact labels, numbers, units, names and
  wording. Never invent a value, label, date, law section or example that is not in the brief.
- It is readable at a glance on a phone: few elements, large text, clear grouping, an obvious reading order
  (top to bottom or left to right).
- It is accurate. A wrong arrow, a mislabeled region or a value that disagrees with the brief is worse than no
  figure. If the brief seems contradictory or impossible to draw clearly, draw the closest faithful version and
  say so in your report.
- It shows nothing the brief lists under "Must not show", such as the answer to an exercise the student solves.
- Prefer a diagram, flow, comparison, timeline, table-like grid or labeled picture over decoration. No clip art,
  no people's faces, no logos, no flags or seals of real agencies, no copyrighted characters.

## 2. Files and names

- Folder: `content/illustrations/<subject>/<topic>/<lesson-slug>/`, where the three parts come from the lesson
  path `content/lessons/<subject>/<topic>/<lesson-slug>.md`.
- One file per marker, numbered in marker order: `01-<slug>.svg`, `02-<slug>.svg`, ... Each brief gives the
  exact folder and file name; use them.
- Create only those files. Do not edit the lesson or any other file. Do not run git.

## 3. Canvas and size

- Root element: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 H" width="360" height="H">` with the
  same numbers in `viewBox` and in `width`/`height`. Width is always 360. Choose the height H for the content,
  usually 200 to 480. Avoid figures taller than 560; split the idea or simplify instead.
- The app draws one SVG unit as one screen pixel and never enlarges a figure, so 360 units is the full phone
  column.
- Keep a 16-unit margin inside the panel on every side. Nothing touches or crosses the panel edge.

## 4. Style D: modern flat with depth

Approved by Aedwon on October 25, 2026. The references are `fig1-D.svg` (monsoon) and `fig2-D.svg` (Venn
diagram) in this folder; they are drawn at 800 wide, so scale their sizes by 0.45 for a 360-wide figure.

- **Colors follow the app theme (Aedwon, Oct 29, option C).** Figures use the app's reserved theme color
  tokens, which the renderer swaps for the active light or dark theme (`docs/content/lesson-svg-authoring.md`,
  "Theme colors without CSS"). Panel: `<rect width="360" height="H" rx="14" fill="url(#bg)"/>` with both
  gradient stops `#030303` (paper). Tokens: `#010101` ink (main text, foreground marks, dots), `#020202`
  secondary ink (connectors, outlines, axis lines, secondary text), `#030303` paper (cut-outs such as punched
  holes), `#050505` accent (the one focus; app teal), `#060606` error (only when the meaning is wrong).
  Shapes are tints of a token through `fill-opacity` (or `stop-opacity` in gradients): structure `#050505`
  at 0.22, secondary shapes `#010101` at 0.12, light tiles `#010101` at 0.05, focus fill `#050505` at 0.45.
  Lines never fade: strokes are a token at full strength unless they are grid or divider lines.
  No gold or warm colors (gold means Pro in the app).

  | Role | Value |
  |---|---|
  | Panel | `#030303` |
  | Main text, foreground marks | `#010101` |
  | Secondary text, connectors, outlines | `#020202` |
  | Structure shapes | `#050505` at fill-opacity 0.22 |
  | Secondary shapes | `#010101` at 0.12 |
  | Light tiles, cards | `#010101` at 0.05 |
  | Focus (one per figure) | `#050505` stroke, fill at 0.45 |
  | Wrong (only when meaning needs it) | `#060606` |

  Exception: when the lesson names black and white shapes (figure series, some matrices), draw the whole
  figure in fixed colors so black stays black in dark mode: white panel `#FFFFFF`, tiles `#F5F5F7`, black
  `#1D1D1F`, white `#FFFFFF`, outlines `#8A8A8E`, text `#1D1D1F`, focus `#0B7A68` with fill `#E4F1EE`.
- **Depth.** Flat shapes with gentle gradients (radial gradients centered slightly up and left, `cx="0.4"
  cy="0.3"`). A thin white arc at `stroke-opacity="0.35"` can suggest a highlight. No drop shadows, blurs or
  glows from filters; filters are not allowed.
- **Shapes.** Rounded rectangles (`rx` 6 to 10) for boxes, circles for sets and nodes, simple paths for arrows.
  Strokes 1.5 to 2.5 units; arrows 2 to 3 units with a filled triangular head drawn as a `polygon` or `path`
  (no `marker` elements).
- **Text.** `font-family="Geist, sans-serif"`, the app's font (Aedwon, Oct 29). Math (variables, equations,
  inequalities, coordinates, axis numbers) uses `tspan` runs: italic variables in `font-family="KaTeX_Math, serif"`,
  numbers, operators and words in `font-family="KaTeX_Main, serif"`, both `font-weight="400"`, matching the
  lessons' KaTeX math. Use `−`, `≥`, `≤`, `²` and spaced operators (`y = x² − 4x + 3`). Single capital labels
  (A, B, O) stay in Geist. Sizes: title 16 to 18 bold (`font-weight="700"`),
  labels 14 to 15 semibold (`600`), notes 14 regular (`400`). Never below 14. Text is `#010101` (ink) or `#020202` (secondary ink); a focus label may use `#050505`. Center labels with
  `text-anchor="middle"`. Break long labels into lines with `tspan` (`x` repeated, `dy="1.2em"`); keep lines
  under about 28 characters at 14 units. Leave at least 6 units between any text and a shape edge.
- **Title.** Optional. Use a short title (2 to 6 words) only when the figure needs one to be understood; the
  lesson text around it usually supplies context.
- **Filipino and symbols.** Write Filipino words exactly as in the lesson. Write `₱` for pesos, real minus
  signs as `−` only if the lesson uses them, and math typeset with the KaTeX `tspan` runs above, not LaTeX.

## 5. Technical rules the app enforces

The app draws SVG with `flutter_svg` 2.3.0, and a checker rejects anything else.

- Allowed elements only: `svg, g, defs, path, rect, circle, ellipse, line, polygon, polyline, text, tspan,
  linearGradient, radialGradient, stop, clipPath, use, symbol, title, desc`.
- Forbidden: `style` attributes or elements, classes, CSS, filters (blur, shadow), masks, `image`, scripts,
  event handlers, `foreignObject`, animation or SMIL, `marker`, external references or fonts, entities,
  doctypes, comments that contain `--`.
- Use simple presentation attributes (`fill`, `stroke`, `stroke-width`, `stroke-opacity`, `fill-opacity`,
  `opacity`, `stroke-linecap`, `stroke-linejoin`, `font-family`, `font-size`, `font-weight`, `text-anchor`,
  `x`, `y`, `dx`, `dy`, `transform`, `rx`, `ry`, `points`, `d`, gradient attributes). Unknown attributes fail.
- Give every visible element an explicit `fill` (use `fill="none"` for outlines); the default black fill is
  invisible on the panel.
- References are local only (`url(#id)`, `href="#id"`), and every `id` is unique within the file.
- Add a `<title>` with a short plain description of the figure as the first child of `<svg>`.
- Keep files hand-written and small, ideally under 12 KB. Round coordinates to whole numbers or one decimal.

## 6. Check your work

After writing the files, run the app's checker and fix every failure it names, then run it again until it
reports 0 failures:

```sh
cd /Users/aedwon/Documents/Projects/Pantas-wt-svg-check
python3 tools/check_lesson_svgs.py <your worktree>/content/illustrations --validate-only
```

Then reread each SVG against its brief, and confirm:

1. Every label, number and name matches the brief exactly; nothing is invented.
2. No text overlaps another element or runs past the panel margin. Estimate text width as about 0.55 times the
   font size per character.
3. All text is 14 units or larger, and the reading order is obvious.
4. Only one warm accent focus, and it marks the brief's focus.
5. Nothing from the brief's "Must not show" list appears.

## 7. Report

Report in under 120 words: the files written, the checker result, and any brief you could not draw faithfully
(with the reason).
