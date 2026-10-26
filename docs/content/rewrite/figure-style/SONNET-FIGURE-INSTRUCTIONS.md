# Instructions for drawing Pantas lesson figures (style D)

You draw static SVG figures for lessons in Pantas, a study app that prepares Filipino students for the Civil
Service Exam (CSE). Each figure replaces one `<!-- ILLUSTRATION: ... -->` marker in a lesson. A student sees it
inside the lesson on a phone, in light or dark mode, and must learn from it. Read this whole file before drawing.

## 1. What a good figure does

- It teaches the one idea its marker describes, using the lesson's exact labels, numbers, units, names and
  wording. Never invent a value, label, date, law section or example that is not in the marker or the lesson.
- It is readable at a glance on a phone: few elements, large text, clear grouping, an obvious reading order
  (top to bottom or left to right).
- It is accurate. A wrong arrow, a mislabeled region or a value that disagrees with the lesson is worse than no
  figure. When the marker and the lesson disagree, follow the lesson and say so in your report.
- It does not give away the answer to a worked example that the lesson asks the student to solve, unless the
  marker asks for the solved figure.
- Prefer a diagram, flow, comparison, timeline, table-like grid or labeled picture over decoration. No clip art,
  no people's faces, no logos, no flags or seals of real agencies, no copyrighted characters.

## 2. Files and names

- Folder: `content/illustrations/<subject>/<topic>/<lesson-slug>/`, where the three parts come from the lesson
  path `content/lessons/<subject>/<topic>/<lesson-slug>.md`.
- One file per marker, numbered in marker order: `01-<slug>.svg`, `02-<slug>.svg`, ... The slug is up to five
  lowercase words from the marker, joined by hyphens, letters and digits only. The lead gives you the exact file
  names; use them.
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

- **Panel.** Every figure sits on its own rounded panel that fills the canvas:
  `<rect width="360" height="H" rx="14" fill="url(#bg)"/>`, with a vertical linear gradient from `#0E2747`
  (top) to `#143B63` (bottom). The panel carries its own background, so the figure looks the same on the light
  lesson page (`#FAF8F3`) and the dark one (`#15171A`). Do not use the app's theme tokens or `currentColor`.
- **Palette.** Cool colors for structure, one warm accent for the thing that matters most.

  | Role | Colors |
  |---|---|
  | Panel | `#0E2747` to `#143B63` |
  | Primary shapes (teal) | radial gradient `#2FB5B0` to `#17697F`; flat `#3FA28C`, `#7BD3B5` |
  | Secondary shapes (sky blue) | radial gradient `#6FD0FF` to `#2468C8`; flat `#5CC8FF`, `#2A86C1`, `#2C6A98` |
  | Light fills and highlights | `#9ADFFF`, `#B8F0FF`, `#F2F7FB` |
  | Warm accent (use for one focus only) | `#FFC857`, `#FFB347`, `#FF7A45`, `#FFD27A` |
  | Main text | `#FFFFFF` |
  | Secondary text | `#D6E6F5`, `#B7CBDD` |
  | Divider lines | `#6FD0FF` at `stroke-opacity="0.4"` |
  | Wrong or warning (only when the meaning needs it) | `#FF7A45` |

- **Depth.** Flat shapes with gentle gradients (radial gradients centered slightly up and left, `cx="0.4"
  cy="0.3"`). A thin white arc at `stroke-opacity="0.35"` can suggest a highlight. No drop shadows, blurs or
  glows from filters; filters are not allowed.
- **Shapes.** Rounded rectangles (`rx` 6 to 10) for boxes, circles for sets and nodes, simple paths for arrows.
  Strokes 1.5 to 2.5 units; arrows 2 to 3 units with a filled triangular head drawn as a `polygon` or `path`
  (no `marker` elements).
- **Text.** `font-family="Source Sans 3, Arial, sans-serif"`. Sizes: title 16 to 18 bold (`font-weight="700"`),
  labels 14 to 15 semibold (`600`), notes 14 regular (`400`). Never below 14. Labels are white on dark shapes;
  use `#0E2747` text only on light fills such as `#F2F7FB` or the warm accent. Center labels with
  `text-anchor="middle"`. Break long labels into lines with `tspan` (`x` repeated, `dy="1.2em"`); keep lines
  under about 28 characters at 14 units. Leave at least 6 units between any text and a shape edge.
- **Title.** Optional. Use a short title (2 to 6 words) only when the figure needs one to be understood; the
  lesson text around it usually supplies context.
- **Filipino and symbols.** Write Filipino words exactly as in the lesson. Write `₱` for pesos, real minus
  signs as `−` only if the lesson uses them, and math as plain text (`3x + 6 = 21`), not LaTeX.

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
python3 tools/check_lesson_svgs.py /Users/aedwon/Documents/Projects/Pantas-wt-cse-rewrite-r1/content/illustrations --validate-only
```

Then reread each SVG against its marker and the lesson, and confirm:

1. Every label, number and name matches the lesson exactly; nothing is invented.
2. No text overlaps another element or runs past the panel margin. Estimate text width as about 0.55 times the
   font size per character.
3. All text is 14 units or larger, and the reading order is obvious.
4. Only one warm accent focus, and it marks the thing the marker is about.
5. The figure does not reveal the answer to an exercise the lesson poses.

## 7. Report

Report in under 120 words: the files written per lesson, the checker result, and any marker you could not draw
faithfully (with the reason, such as a marker that disagrees with the lesson).
