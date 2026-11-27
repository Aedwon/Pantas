# Figure pipeline notes (P0, read-only)

Written Nov 27 about 11:15 PM Manila. Read from `origin/main` (app code, tools, docs) and this branch (lessons). Evidence is `path:line` where I read a line number, otherwise the function or constant name. Nothing was run except `git show`, `git grep`, `date`, `ls`.

## Main finding

There are two ways a lesson picture ships. The plan only found the first.

1. Code figure: `<!-- FIGURE: {json} -->`, drawn by a Flutter painter. Needs an existing kind, or new app code.
2. Drawn SVG file: keep a `<!-- ILLUSTRATION: description -->` marker and add `content/illustrations/<subject>/<topic>/<lesson>/NN-slug.svg`. No app code, no figure kind. This is how `table-values-and-totals` is drawn today (Q5). It is the path that fits the bar and the triangle.

The inventory audit (`check_lesson_illustrations.py`) is a frozen 279-row contract that already fails on shipped content, so it is not the gate for path 2.

## 1. Marker forms

| Marker | Export and app | Evidence |
|---|---|---|
| `<!-- FIGURE: {json} -->` | Parsed as JSON. Invalid JSON or a non-object throws. App draws it through the registry; an unknown kind returns null (nothing drawn). | `tools/content/markdown_portable_text.dart:96,142-157`; `lib/core/content/remote/lesson_markdown.dart:66,125-140`; `lib/core/ui/figures/figure_registry.dart` `build` (the `_ => null` case) |
| `<!-- ILLUSTRATION: desc -->` | Needs a drawn file. With an asset map configured, a marker with no SVG or PNG in its numeric slot throws `Missing asset-map entry for "<lesson>#N"`. With a file, it becomes an `IMAGE` marker with a credit. The web path without an asset map drops it. | `tools/content/markdown_portable_text.dart:~176-215` (error text at 194); `lib/core/content/remote/lesson_markdown.dart:11-13` |
| `<!-- FIGURE WANTED: ... -->` | Ignored comment. Matches neither regex, so nothing is exported or shown. This branch has 82 of them; main has none. | regexes above; `docs/content/verification/walkthrough-state.md:59` (lead ruling, Nov 27) |

Placement rule: any `FIGURE`, `ILLUSTRATION` or `IMAGE` marker inside a `:::` walk-through block throws "figure or illustration marker inside :::<kind> block" (`lib/core/content/walkthrough_markdown.dart:145`, used in `planWalkthrough`). Put the figure between blocks, as the line 23 and the post-formula positions are (verify the triangle spot is outside any fence).

Export root: `build_content_export.dart:633` reads `content/illustrations/assets.json` (absent on this branch and in prod) plus figure files and `content/illustrations/sources/*.yaml` credits. `:710` `assertNoOrphanFigures` fails on a figure folder with no lesson file.

## 2. Which kind can draw the two figures

Kinds the checker knows: `KNOWN_FIGURE_KINDS` in `tools/audit/check_lesson_illustrations.py` (gear-train, spring-scale, lever-balance, pulley-system, fluid-vessel, stability-shape, shape-row, coordinate-graph, geometry-diagram, chart, concept-diagram, figure-matrix, figure-series, cube-net, paper-fold, venn-diagram, reading-diagram, biology/chemistry/earth-science/physics-mechanics/physics-energy diagrams). The registry (`figure_registry.dart`) builds all of these except `venn-diagram`.

(a) Horizontal bar split into two labeled segments: none fits.
- `chart` types are only `bar`, `line`, `number-line`, `pie`, `scatter` (`chart_figure.dart:31`). `bar` is vertical bars of `labels` and `values` (1 to 12 labels, labels at most 32 chars, `pie` needs values above 0). It cannot make one bar with a shaded part and a remainder.
- `chart/pie` with `labels ["Part = 60 (Rate = 30%)", "140 (70%)"]`, `values [60, 140]` would draw a pie, not a bar. It would be a different picture from the plan.
- `concept-diagram` types (`concept_diagram_figure.dart:58-77`): sequence, flow, hierarchy, venn, nested-boxes, conic-sections, tree, inference, main-idea, free-body, and physics types. None is a split bar.
- `shape-row`, `figure-series`, `figure-matrix`, `grid-polygon`: shape-puzzle kinds, not read in depth (not found to fit).

(b) Labeled triangle with three corner labels and a divider: none fits.
- `geometry-diagram` takes only `type` (a fixed list, `geometry_diagram_figure.dart:25-70`, including `triangle`, `right-triangle`) and `labels` (1 to 16 strings, each up to 64 chars; `:76-90`). The painter places labels by its own rules per type; a type cannot be given corner positions or a divider. Real example in a lesson: `{"kind": "geometry-diagram", "type": "triangle", "labels": ["Side a = 5", "Side b = 9", "Side c = ?", "4 < c < 14"], "semanticsLabel": "..."}`.
- `concept-diagram/flow` or `hierarchy` can show three labeled boxes joined by edges, not a covered-corner triangle.

So with a `FIGURE` marker a new kind would be app code (painter file, registry case, `KNOWN_FIGURE_KINDS`, `figure_classes.dart` entry, tests, UI board). The plan says that stops at the manager. Path 2 (SVG) avoids all of it.

Real examples of the kinds that do exist (main, `content/lessons/mathematics/...`): Venn `{"kind":"concept-diagram","type":"venn","sets":["Chemistry","Physics"],"regions":{...},"semanticsLabel":"..."}`; bar `{"kind":"chart","type":"bar","labels":["Factory A","Factory B"],"values":[450,320],"yAxis":{"label":"Units produced","min":0,"max":500,"step":100},"semanticsLabel":"..."}`; pie in `statistics-and-probability/data-analysis-graphs.md:22`.

## 3. What must change for a new figure to pass

Path 2, SVG (recommended):
- Marker: change `<!-- FIGURE WANTED:` to `<!-- ILLUSTRATION:` on the same line. Write the full meaning in the description (it becomes alt text unless the asset map gives one). `docs/content/lesson-svg-authoring.md` "Files and markers".
- File: `content/illustrations/mathematics/arithmetic-number-sense/percentage-base-and-fraction-division/NN-slug.svg`. Path regex `^([a-z0-9-]+)/([a-z0-9-]+)/([a-z0-9-]+)/([0-9]{2,})-[a-z0-9-]+\.(svg|png)$` (`tools/content/lesson_asset_map.dart`, `figurePathRule`). Files join to markers in numeric order (01 for the bar, 02 for the triangle). Sequence gaps are allowed, duplicates are not.
- Credit: a new original SVG in a slot with no asset-map entry needs no entry; its credit defaults to `Pantas`. (This branch also has `content/illustrations/sources/data-interpretation.yaml` listing `Pantas` for its tables; main's prod overlay has `sources/pantas.yaml`.) `lesson-svg-authoring.md` "Credits".
- Drawing rules: `viewBox` with matching `width`/`height`, about 360 wide, text 12 or larger; `font-family` only `Geist, sans-serif`, `KaTeX_Main, serif`, `KaTeX_Math, serif`; allowed elements only (svg g defs path rect circle ellipse line polygon polyline text tspan gradients stop clipPath use symbol title desc); no CSS, style, filters, masks, images, scripts. Theme colors: `#010101` ink, `#020202` secondary ink, `#030303` paper, `#040404` rule, `#050505` accent (these are replaced per theme; the table SVGs use them). `tools/check_lesson_svgs.py` lines 1-60.
- Size cap: lesson plus embedded figures at most 900,000 bytes (`lesson-svg-authoring.md`).
- No change to `strategy.tsv`, `worklist.tsv`, `review.json`, `figure_classes`, `KNOWN_FIGURE_KINDS`. Those belong to the code-figure route.

Path 1, a `FIGURE` marker (only if a kind fit, which none does here): each of these would change.
- `strategy.tsv` needs one `code` row per marker (columns subject, topic, lesson, seq, target_file, description, strategy, batch). `check_lesson_illustrations.py` `check_inventory` asserts exactly `EXPECTED_TOTALS = {code 241, open 4, native 23, cut 8, founder 3}`, total 279, and the lesson-marker check asserts 241 `FIGURE` markers and 7 `ILLUSTRATION` markers across all lessons. Any addition changes constants in the script and in `test/tools/check_lesson_illustrations_test.dart` (the plan `2026-08-22-original-lesson-code-figures.md` Task 1 did exactly that).
- `worklist.tsv` is generated: `python3 tools/audit/list_illustrations.py` (README says no manual editing; hand-added rows fail).
- `review-ready` needs 52 current two-theme code previews (`build/lesson_author/illustration_previews/manifest.json`, built by a lesson-author tool; whether it needs Flutter: not found, almost certainly yes since painters are Flutter). `review.json` stores a status, `reviewedDigest` and `reviewedAt` per key; `complete` needs every key `approved` with a digest equal to the current preview digest. The review catalog counts are also frozen (code 52, open 4, founder 3 = 59).
- `figure_classes.dart` (`lib/core/ui/figures/figure_classes.dart`): a new `kind/type` must be on `wideFigureTypes` or `marginFigureTypes`; `tool/checks/figure_classes.dart` fails on a type on neither.

Which checks gate shipping (Path 2):
- Main's content export must exit 0 with this worktree as root (rule from `docs/content/verification/walkthrough-state.md:59`): run `dart run tools/build_content_export/build_content_export.dart` from the main checkout with this worktree as the root (exact flag not read; take it from the state doc or the export's usage text).
- `python3 tools/check_lesson_svgs.py <root>` (validates and draws each SVG in both themes through Flutter; the docs say run it from the APP worktree with no other Flutter command running). Also `python3 tools/check_lesson_svgs.py tools/svg_fixtures/fail --validate-only` must exit 1 (fixtures check, not about your files). Plain `--validate-only` on your SVGs needs no Flutter (flag in `check_lesson_svgs.py` usage line 4); the in-memory draw does.
- `lesson_checks.dart --root` exit 0 (from the batch plan, unchanged).
- Not a gate: `tools/audit/check_lesson_illustrations.py`. `docs/superpowers/verification/2026-11-22-cse-qa/content-findings.md:12-30` records it already failing on prod content ("expected 241 valid FIGURE markers, found 387", "expected 7 remaining ILLUSTRATION markers, found 442", 618 errors) because the strategy is "frozen at 279 rows ... before the bite-sized splits and new SVG pipeline". This branch has 387 `FIGURE` markers. It is wired to no CI I found (only `tool/ci/test_timings.json` names its test).

## 4. Does a figure need a release lead, board or Aedwon?

- SVG path: no board and no code. Visual judgment is Aedwon's: `docs/superpowers/plans/pwa-launch/evidence/B9-lesson-svg.md` ("Aedwon owns visual ..."), `docs/content/lesson-svg-authoring.md` end ("They save no screenshots. Aedwon performs visual checks."), `SUBAGENTS.md:359` "Aedwon owns visual verification. Do not capture app/emulator screenshots". `WORKFLOW.md:296` "Aedwon performs visual checking." The batch plan already says he sees figures on staging with the batch. That is a look, not a gate on the export.
- review.json approval applies only to the code-figure route (`complete` phase) and is not part of the SVG path.
- New figure kind (code): the batch plan itself says "a new figure kind is a UI change, needs his visual check (rule 3 boards for UI), and goes to the UX lane". Also `docs/workflow/operations-manager.md:181` "Visual decisions need a visual companion (board or preview). Build what he picked, 1:1." Also CLAUDE.md "Check ... lib/core/ui/components/ before drawing anything". I did not find a release-lead sign-off rule for adding a lesson figure.
- Content rule that applies to both: AGENTS.md "Never invent a figure" (`AGENTS.md:164`). A picture's numbers must equal the lesson text beside it (200, 60, 30%, 140, 70%).

## 5. `table-values-and-totals.md` lines 95 and 111

Yes, both tables are drawn today, as SVG files (path 2), not as code figures:
- Lesson (this branch) lines 95 and 111: two `<!-- ILLUSTRATION: table titled "Quarterly Office Expenses, in thousands of pesos" ... -->` markers.
- Files: `content/illustrations/mathematics/data-interpretation/table-values-and-totals/01-table-titled-quarterly-office-expenses.svg` and `02-...svg`. 360 by 260, `<title>`, Geist text, theme color tokens `#010101` to `#050505`, rounded rect background `#030303`.
- Credit: `content/illustrations/sources/data-interpretation.yaml` keys `mathematics/data-interpretation/table-values-and-totals#1` and `#2`, credit `Pantas`.
- They arrived in `bec5a476e` "Bring the live CSE Algebra parts onto the CET math line, math paths only". Main has no SVGs under `content/illustrations` (0 found) and no `table-values-and-totals` lesson, so main's export run against this root is what exercises them.
- Side note: both markers carry an identical description for two different examples. It is allowed (joined by sequence), but the second example's alt text will not say which question it serves.

## Steps to add one figure (recommended: SVG, no app code)

1. Confirm the position is outside any `:::` block (`walkthrough_markdown.dart:145`). The bar sits at line 23 (Core Concept, outside a fence). The triangle goes right after the three formulas (lines 29 to 33): check it is outside a fence.
2. In the lesson, change `<!-- FIGURE WANTED:` to `<!-- ILLUSTRATION:` on that line (Edit tool, same line, no other change). For the triangle, add a new `<!-- ILLUSTRATION: ... -->` line on its own line after the formulas. Write the whole meaning in the description (corner labels, which formula each covered corner gives).
3. Number the markers in file order. If the bar is the only marker before the triangle, they are `#1` and `#2`. Any existing `ILLUSTRATION` marker earlier in the lesson shifts the numbers. Check with `grep -n "ILLUSTRATION:" <lesson>`.
4. Draw `01-<slug>.svg` and `02-<slug>.svg` in `content/illustrations/mathematics/arithmetic-number-sense/percentage-base-and-fraction-division/`, following the subset above. Use the table SVGs as a style template. Numbers and labels equal the lesson text: Base = 200 (100%), Part = 60 (Rate = 30%), 140 (70%); triangle Part on top, Rate and Base at the bottom, with Part = Rate x Base, Base = Part / Rate, Rate = Part / Base to match the three formulas.
5. Run `python3 tools/check_lesson_svgs.py <root> --validate-only` (no Flutter), fix every named rejection.
6. Run main's content export on this root: exit 0 (no `Missing asset-map entry`, no orphan folder, no credit error, lesson under 900,000 bytes).
7. Run `lesson_checks.dart --root` and the batch's own checks (word count, walk-through fences).
8. The figure's numbers go to the recompute worker; Aedwon looks at staging. Do not screenshot.
9. Do not touch `strategy.tsv`, `worklist.tsv`, `review.json`, `figure_classes`. Do not hand-edit `assets.json` (absent).

If the manager insists on a code figure: stop, a new kind is app code needing the UX lane; see the Path 1 list in section 3.

## Open questions

1. The exact command line of the export (`build_content_export.dart` arguments) was not read. Take it from the lead's earlier run.
2. Does `check_lesson_svgs.py` without `--validate-only` need Flutter on the machine (the lead said do not run Flutter)? The docs say it draws through the app parser in both themes. Only `--validate-only` is Flutter-free.
3. Is the SVG path acceptable under plan rule "code-drawn figures, style D with theme colors"? SVGs use the same theme tokens, but the plan text says code-drawn. The manager should confirm SVG is allowed. I did not read the Oct 25 and Oct 29 launch log entries (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`) in time.
4. How the two-theme preview for `review-ready` is built, and whether it needs Flutter: not found (tool path unread). Only relevant to the code-figure route.
5. Whether a user-facing figure caption or an inline `\text{}` fraction needs KaTeX fonts in SVG: allowed fonts exist, not tested.
6. This branch sits on a base with 387 `FIGURE` markers, main has 241. Because the branch is far behind, a lesson file here may differ from main's copy of the same lesson. Check before cherry-picking.
