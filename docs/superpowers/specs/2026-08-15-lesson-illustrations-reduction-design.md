# Lesson Illustrations Reduction and Production Pipeline Design

**Date:** 15 August 2026  
**Status:** Approved by Aedwon  
**Supersedes:** Parts of `docs/content/illustrations/README.md` (which assumed all 279 were hand-drawn). Sits alongside `specs/2026-08-13-drawn-figures-design.md`.

---

## 1. The Problem

The initial lesson illustration queue contains **279 placeholders across 111 lessons**. Drawing all 279 by hand in Canva or Illustrator is an enormous, unnecessary burden for a solo founder. 

Furthermore, flat raster PNGs for diagrams suffer from drawbacks:
- They do not adapt to light and dark theme switching.
- They require network downloads and image decoding on budget mobile devices.
- They consume unnecessary CDN bandwidth.

A full audit of the 279 placeholders shows that **only 3 images actually require bespoke manual illustration**. The remaining 276 items can be solved with code painters, open educational resources, and native text formatting.

---

## 2. Inventory Breakdown by Strategy

| Strategy | Count | Percentage | Description |
|---|---|---|---|
| **Code Painters (`CustomPainter`)** | **189** | 67.7% | Geometric diagrams, graphs, trig unit circles, mechanical setups, and abstract puzzles rendered on the canvas in Flutter. |
| **Open-Source Standard Assets** | **56** | 20.1% | High-quality educational vectors/diagrams from OpenStax (CC-BY 4.0), USGS, NASA, and NOAA (Public Domain). |
| **Markdown & LaTeX Tables** | **23** | 8.2% | Truth tables, Punnett squares, and chemical equations converted into native text and tables. |
| **Cut Decorative Metaphors** | **8** | 2.9% | Unneeded decorative icon clusters and analogies where the lesson text is already complete. |
| **Bespoke Founder Drawings** | **3** | 1.1% | Three visual literacy stimuli for Reading Comprehension (2 editorial cartoons, 1 comic strip). |
| **Total** | **279** | **100%** | |

---

## 3. Architecture & Data Flow

### 3.1 Code Figures in Lessons

For the 189 code-drawn figures, lessons carry a structured `figureSpec` block instead of an image placeholder:

```markdown
<!-- FIGURE: {"kind": "coordinate-graph", "type": "parabola", "formula": "y = x^2 - 4", "points": [[1, -3], [2, 0]]} -->
```

1. **Parser:** The lesson importer parses `<!-- FIGURE: ... -->` into a portable-text block with `_type: 'figureSpec'`.
2. **Reader Widget:** `PortableTextRenderer` dispatches `_type: 'figureSpec'` to `LessonFigureWidget`, which reuses the exact same Flutter `CustomPainter` suite used by `QuestionFigure`.
3. **Themes:** Colors follow `AppTheme.of(context)` dynamically (ink, paper, rule faint, and board green). Zero hardcoded black or white.

### 3.2 Open-Source Standard Assets (56 Items)

The 56 standard diagrams for Biology, Earth Science, Chemistry, and Physics apparatus are obtained via a batch download script:
- Sourced from OpenStax textbooks (Rice University), USGS, NASA JPL, NOAA, and Wikimedia Commons.
- Formatted as 1600px PNGs with solid light neutral backgrounds (#FAFAF7).
- Placed into `content/illustrations/<subject>/<topic>/<lesson-slug>/NN-<slug>.png`.
- Attributed with standard CC-BY credit lines in the repo attribution log.

### 3.3 Native Markdown & LaTeX (23 Items)

These 23 placeholders are replaced in-place in markdown files:
- **Truth tables:** Converted to Markdown tables (`| P | Q | P and Q |`).
- **Punnett squares:** Converted to 2x2 Markdown tables with parent allele headers.
- **Reaction formulas:** Converted to display LaTeX equations (`$$A + B \rightarrow AB$$`).
- **SI Base Units:** Converted to a clean Markdown table of 7 base SI quantities.
- **Taxonomy:** Converted to an indented hierarchy list.

### 3.4 Decorative Cuts (8 Items)

The 8 decorative markers (e.g. balance scale for mole concept, 7 icons for characteristics of life, document icons) are simply deleted from lesson markdown. The text stands alone without visual gaps.

---

## 4. Painter Families (189 Figures)

### Family 1: Reused Question Painters (50 figures)
- `gear-train` (meshing gear rows and spoke gears)
- `spring-scale` (hanging weights on springs, series springs)
- `lever-balance` (levers on fulcrums with weight balances)
- `pulley-system` (fixed and movable pulleys)
- `fluid-vessel` (U-tubes, manometer levels, narrowing pipes)
- `stability-shape` (standing shapes with centers of gravity)
- `shape-row` (odd-one-out geometric shapes)

### Family 2: Coordinate Graph Painter (35 figures)
- `coordinate-axes` with labeled ticks and gridlines
- `linear-inequality` (dashed/solid lines with shaded half-planes)
- `systems-intersection` (two lines or line-parabola intersections)
- `function-gallery` (parabolas, rational curves, asymptotes)
- `integral-area` (shaded area under curve between $x=a$ and $x=b$)
- `conic-sections` (ellipses with foci, hyperbolas with asymptotes)

### Family 3: Geometry & Trigonometry Painter (80 figures)
- `angles-transversal` (parallel lines cut by transversal with labeled angle pairs)
- `triangle-geometry` (interior/exterior angles, similar triangles with shadow ratios)
- `circle-geometry` (radius, diameter, chords, tangent lines, inscribed angles)
- `quadrilateral-polygon` (regular polygons, triangulations, parallelograms)
- `unit-circle` (terminal rays, quadrant signs, reference angles)
- `right-triangle-trig` (hypotenuse/opposite/adjacent, elevation and depression angles)

### Family 4: Abstract Grids & Nets (24 figures)
- `figure-matrix` (2x2 and 3x3 shape pattern matrices)
- `figure-series` (4-step rotational and growth sequences)
- `cube-net` (cross-shaped folding nets and projections)
- `paper-fold` (folded squares with symmetric notch cutouts)

---

## 5. The 3 Founder-Drawn Assets

Only these 3 images are created manually in Canva, Figma, or Illustrator:

1. `content/illustrations/reading-comprehension/text-types/visual-media/01-editorial-cartoon-example-large.png`: A large boulder labeled "TAXES" rolling toward a worried small figure labeled "CITIZENS".
2. `content/illustrations/reading-comprehension/text-types/visual-media/02-panel-comic-strip-panel.png`: 3-panel comic strip (building sandcastle, finished castle, wave washing it away).
3. `content/illustrations/reading-comprehension/text-types/visual-media/03-editorial-cartoon-large-boulder.png`: Editorial cartoon variation of taxes rolling downhill.

---

## 6. Verification and Gates

1. **Content Audits:** Run `python3 tools/audit/run_all.py` to ensure zero broken markers and zero missing figure files.
2. **Analyzer & Formatter:** Run `flutter analyze` and `dart format` to ensure clean code.
3. **Widget Tests:** Unit and widget tests verify that `LessonFigureWidget` renders all figure kinds without throwing exceptions on invalid specs.
4. **Theme Verification:** Visual check in both light and dark mode ensuring clean hairline rendering.
