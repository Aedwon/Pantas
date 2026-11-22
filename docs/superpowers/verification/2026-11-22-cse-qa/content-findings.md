# Content Audit Findings: Checklist Rows C3 and C4

- **Date:** 2026-11-22
- **Policy revision:** `origin/main` `78a7d90a6` (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/process-improvement.md`; confirmed descendant of `ecfeaf0d1`)
- **Worktree HEAD:** `67ed1b52b` (read-only audit; no tracked files edited)
- **Prod content root audited:** `build/audit/prodtree/content` (`content/cet-bite-r1` `d97de9415`), plus main's three prod-overlay files (`content/mock/acet.yaml`, `content/exams/custom_subject_tiers.json`, `content/illustrations/sources/pantas.yaml`)

---

## Checklist Row C3: Content Audit Sweep (`tools/audit/run_all.py`)

### C3-1. `tools/audit/run_all.py` aborts on sweep 3 with 618 stale-strategy illustration errors on prod content, masking sweeps 4 to 11

- **Severity:** major (tooling/CI gate broken; 0 broken visuals reach CSE students)
- **Evidence:**
  - `tools/audit/run_all.py:18-45` (hardcodes `OUT = <repo>/docs/content/audit/sweep-results.tsv` and accepts no `--root` argument or environment variable; must be run from an isolated scratch tree under `build/audit/`).
  - `tools/audit/sweep_illustrations.py:37-49` -> `tools/audit/check_lesson_illustrations.py:22-24,180-325` compares every `.md` file under `content/lessons/` against `docs/content/illustrations/strategy.tsv` (frozen at 279 rows on `main` before the bite-sized splits and new SVG pipeline).
  - Running `python3 build/audit/scratch_prod/tools/audit/run_all.py` against `build/audit/prodtree/content` exits `1` inside `sweep_illustrations` with **618 stderr error lines** (up from 182 on Nov 17 `88f38e698` prior to the Nov 20 CET bite-sized release `d97de9415`), leaving stdout empty, writing no `sweep-results.tsv`, and never running sweeps 4 through 11 (`sweep_formulas`, `sweep_ai_tells`, `sweep_questions`, `sweep_tier_boundary`, `sweep_note_b`, `sweep_near_duplicates`, `sweep_padded_choices`, `sweep_answer_key`).
  - Classification of all 618 stderr lines (by script):
    - **By error type:**
      - `2` global count mismatches: `expected 241 valid FIGURE markers, found 387`; `expected 7 remaining ILLUSTRATION markers, found 442`
      - `442` per-lesson `unexpected illustration marker`
      - `167` per-lesson `expected X code FIGURE markers, found Y`
      - `7` per-lesson `missing planned open/founder illustration marker`
      - `0` invalid `FIGURE` JSON, `0` unrecognized `FIGURE` kind, `0` `native/cut` remaining
    - **By subject (616 per-lesson lines):** `mathematics` 229, `science` 208, `reasoning` 125, `reading-comprehension` 32, `general-information` 22
    - **By lesson status (616 per-lesson lines):** `active` 447, `retired` 169
    - **By CSE reachability (616 per-lesson lines):**
      - `55` in **active CSE-reachable lessons** (`52` `unexpected illustration marker` across 31 active lessons + `3` `FIGURE count mismatch` across 3 active lessons)
      - `59` in **retired CSE parent lessons** (`52` `unexpected illustration marker` + `7` `FIGURE count mismatch`; unreachable because `content_repository.dart:174` lists only `status = 'active'` and retired ids alias to active parts)
      - `57` in **active non-CSE lessons inside shared CSE topics** (e.g. CET-only Algebra parts; unreachable by CSE students because `content_repository.dart:171-189` requires an active question tagged for the student's exam)
      - `445` in **non-CSE subjects/topics** (CET/Science/Geometry/etc.)
  - **Independent verification of the 8 masked sweeps (running sweeps 1, 2, and 4-11 without `sweep_illustrations` on prod root):** produces `19,571` TSV rows (`58` blocker, `11,016` important, `8,497` polish). All 58 reported blockers are sweep parser/heuristic false positives: 38 `QSTRUCT` + 4 `QANSWER` + 1 `NOTEB` come from `sweep_questions.py`'s regex YAML parser failing when `approved: true` precedes `lesson:` or choices use 4-space indentation (verified on `corruption-and-its-effects.yaml:375-460`), and the 2 CSE `QKEY` hits (`prime-factorization-gcf-lcm.yaml:306` `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0014`, `more-figure-rules.yaml:217` `q-spatial-abstract-reasoning-more-figure-rules-0007`) are word-vs-numeral matching false positives ("two trips" vs `$2$`; "Four dots" vs `"Two dots"`).
  - **Render-path trace for lesson illustrations and figures:**
    1. **Upload time (`tools/upload_content/upload_content.mjs:82-112`, `tools/upload_content/lesson_illustrations.mjs:48-118`):** loads local `NN-slug.svg`/`.png` files under `content/illustrations/<subject>/<topic>/<lesson>/` and `assets.json` (absent in prod) plus source credits from `content/illustrations/sources/*.yaml` (defaulting credit to `"Pantas"` for new original SVGs). If `entries.size > 0`, every `<!-- ILLUSTRATION: ... -->` is replaced in order with `<!-- IMAGE: {"asset":{"url":"data:image/svg+xml;base64,...","credit":"..."},"alt":"..."} -->` and checked against `MAX_RESOLVED_LESSON_BYTES = 900,000`. If `entries.size === 0`, `lesson_illustrations.mjs:99` returns `body` unchanged (leaving raw `<!-- ILLUSTRATION: ... -->`).
    2. **Client parse (`lib/core/content/remote/content_mirror.dart:521-552`, `lib/core/content/remote/lesson_markdown.dart:61-132`):**
       - `<!-- IMAGE: {...} -->` -> `{_type: 'image', asset: {url, credit}, alt}`. Invalid JSON or missing `asset.url`/`alt` throws `FormatException`, which `content_mirror.dart:349-354` catches and rolls back, leaving the lesson unready so `lesson_page.dart:462,591` shows `"Lesson not found."`.
       - `<!-- FIGURE: {...} -->` -> `{_type: 'figureSpec', spec, semanticsLabel}`. Invalid JSON throws `FormatException` (same `"Lesson not found."` outcome).
       - Unresolved `<!-- ILLUSTRATION: ... -->` -> silently dropped (`lesson_markdown.dart:121-125`), so the student sees **blank / nothing** where the diagram should be.
    3. **Client render (`lib/core/ui/components/content_renderer.dart:219-231,769-800,2067-2261`, `lib/core/ui/components/lesson_svg.dart:10-145`, `lib/core/ui/figures/figure_registry.dart:27-56`, `lib/core/ui/figures/question_figure.dart:18-79`):**
       - `image` block: empty URL -> `SizedBox.shrink()` in reader (`content_renderer.dart:786-788`); bad `data:` URL or SVG/PNG decode failure -> `_ImageFailure` box reading `"This illustration didn’t load."` with `"Try Again"` (`content_renderer.dart:2086-2260`); valid SVG/PNG data URL -> rendered in `_FigureFrame` with credit and tap-to-zoom.
       - `figureSpec` block: `FigureRegistry.build(spec) == null` (unknown `kind` or rejected spec fields) -> `fallback(context)` box reading `"Content unavailable. Update the app."` in reader (`content_renderer.dart:219-231,774`).
       - Question `figureSpecJson`: malformed JSON or unknown/invalid spec -> `_MissingFigure` box reading `"This question needs a diagram that has not been drawn yet."` (`question_figure.dart:33-46,72-75`).
  - **CSE reachability and runtime verification on prod (`build/audit/prodtree/content`):**
    - All **442 / 442** `<!-- ILLUSTRATION: ... -->` markers across all 1,271 prod lessons (including all **52 / 52** in active CSE lessons) resolve cleanly via `resolveLessonIllustrations` to local `.svg` or `.png` files with valid credits (`0` unresolved, `0` upload errors with or without main's `pantas.yaml`, `0` multiline or inline markers).
    - All **436** `.svg` files pass `python3 tools/check_lesson_svgs.py build/audit/prodtree/content/illustrations --validate-only` (`436 files, 0 failures`). Max estimated resolved CSE lesson size is `28,549` bytes (`reasoning/spatial-abstract-reasoning/folded-layers-and-separate-holes.md`), well under the `900,000`-byte limit.
    - All **6 / 6** `<!-- FIGURE: ... -->` markers in active CSE lessons have valid JSON, registered kinds (`concept-diagram` `nested-boxes`, `cube-net`, `geometry-diagram` `cylinder-shadow-above`/`cylinder-shadow-side`), and valid parameters matching their `fromSpec` validators.
    - All **94** CSE questions carrying `figureSpec` use registered kinds (`shape-row`: 14, `figure-series`: 26, `figure-matrix`: 20, `cube-net`: 14, `paper-fold`: 20); `0` CSE questions have pending figures held back.
  - **Complete list of CSE-reachable flagged markers (55 errors across 33 active CSE lessons: 52 `ILLUSTRATION` markers + 3 `FIGURE count mismatch` lessons holding 6 `FIGURE` markers):**
    - *All 52 `ILLUSTRATION` markers flagged as `unexpected illustration marker` (all resolve to valid SVGs; student sees the rendered SVG illustration, not an error or blank):*
      1. `content/lessons/general-information/code-of-conduct-ra-6713/corruption-social-economic-political-effects.md:29` (`cse-pro`, `cse-sub`) -> `01-center-corruption-with-arms-social.svg` — student sees rendered SVG
      2. `content/lessons/general-information/code-of-conduct-ra-6713/corruption-social-economic-political-effects.md:54` (`cse-pro`, `cse-sub`) -> `02-linked-boxes-inflated-project-cost.svg` — student sees rendered SVG
      3. `content/lessons/general-information/code-of-conduct-ra-6713/corruption-state-response.md:29` (`cse-pro`, `cse-sub`) -> `01-complaint-points-to-ombudsman-acts.svg` — student sees rendered SVG
      4. `content/lessons/general-information/philippine-constitution/branches-and-checks.md:25` (`cse-pro`, `cse-sub`) -> `01-columns-legislative-congress-makes-laws.svg` — student sees rendered SVG
      5. `content/lessons/general-information/philippine-constitution/branches-and-checks.md:35` (`cse-pro`, `cse-sub`) -> `02-congress-president-courts-connected-by.svg` — student sees rendered SVG
      6. `content/lessons/general-information/philippine-constitution/domestic-voting-qualifications.md:33` (`cse-pro`, `cse-sub`) -> `01-domestic-voter-checklist-with-four.svg` — student sees rendered SVG
      7. `content/lessons/general-information/philippine-constitution/elected-office-qualifications.md:27` (`cse-pro`, `cse-sub`) -> `01-minimum-age-ladder-25-representative.svg` — student sees rendered SVG
      8. `content/lessons/general-information/philippine-constitution/natural-born-and-naturalized-citizens.md:31` (`cse-pro`, `cse-sub`) -> `01-citizenship-flow-for-status-at.svg` — student sees rendered SVG
      9. `content/lessons/general-information/philippine-constitution/president-emergency-powers.md:29` (`cse-pro`, `cse-sub`) -> `01-timeline-day-0-proclamation-or.svg` — student sees rendered SVG
      10. `content/lessons/general-information/philippine-constitution/ratification-and-plebiscites.md:27` (`cse-pro`, `cse-sub`) -> `01-three-proposal-routes-labeled-congress.svg` — student sees rendered SVG
      11. `content/lessons/general-information/philippine-constitution/ratification-and-plebiscites.md:40` (`cse-pro`, `cse-sub`) -> `02-timeline-labeled-january-1-2026.svg` — student sees rendered SVG
      12. `content/lessons/mathematics/data-interpretation/averages-and-pie-chart-shares.md:40` (`cse-pro`) -> `01-table-titled-monthly-revenue-with.svg` — student sees rendered SVG
      13. `content/lessons/mathematics/data-interpretation/averages-and-pie-chart-shares.md:58` (`cse-pro`) -> `02-pie-chart-titled-training-budget.svg` — student sees rendered SVG
      14. `content/lessons/mathematics/data-interpretation/chart-scales-and-differences.md:30` (`cse-pro`) -> `01-bar-chart-titled-factory-output.svg` — student sees rendered SVG
      15. `content/lessons/mathematics/data-interpretation/table-values-and-totals.md:36` (`cse-pro`) -> `01-table-titled-quarterly-office-expenses.svg` — student sees rendered SVG
      16. `content/lessons/mathematics/data-interpretation/table-values-and-totals.md:52` (`cse-pro`) -> `02-table-titled-quarterly-office-expenses.svg` — student sees rendered SVG
      17. `content/lessons/reading-comprehension/comprehension-skills/main-idea-scope.md:18` (`cse-pro`, `cse-sub`) -> `01-a-box-labeled-main-idea.svg` — student sees rendered SVG
      18. `content/lessons/reading-comprehension/comprehension-skills/visual-data-conclusions.md:39` (`cse-pro`, `cse-sub`) -> `01-horizontal-bar-graph-titled-help.svg` — student sees rendered SVG
      19. `content/lessons/reading-comprehension/comprehension-skills/visual-data-conclusions.md:71` (`cse-pro`, `cse-sub`) -> `02-horizontal-bar-graph-titled-help.svg` — student sees rendered SVG
      20. `content/lessons/reasoning/logical-verbal-reasoning/deductive-group-arguments.md:40` (`cse-pro`) -> `01-nested-circles-with-mammals-inside.svg` — student sees rendered SVG
      21. `content/lessons/reasoning/logical-verbal-reasoning/deductive-group-arguments.md:51` (`cse-pro`) -> `02-a-circle-labeled-birds-inside.svg` — student sees rendered SVG
      22. `content/lessons/reasoning/logical-verbal-reasoning/invalid-conditional-forms.md:33` (`cse-pro`) -> `01-a-circle-labeled-students-who.svg` — student sees rendered SVG
      23. `content/lessons/reasoning/logical-verbal-reasoning/valid-conditional-forms.md:55` (`cse-pro`) -> `01-a-circle-labeled-alarms-working.svg` — student sees rendered SVG
      24. `content/lessons/reasoning/logical-verbal-reasoning/valid-conditional-forms.md:65` (`cse-pro`) -> `02-two-overlapping-circles-labeled-cabinet.svg` — student sees rendered SVG
      25. `content/lessons/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns.md:34` (`cse-pro`) -> `01-small-black-triangle-medium-white.svg` — student sees rendered SVG
      26. `content/lessons/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns.md:46` (`cse-pro`) -> `02-eight-labeled-positions-in-reading.svg` — student sees rendered SVG
      27. `content/lessons/reasoning/spatial-abstract-reasoning/cuts-at-two-fold-lines.md:26` (`cse-pro`) -> `01-square-folded-left-onto-right.svg` — student sees rendered SVG
      28. `content/lessons/reasoning/spatial-abstract-reasoning/figure-counts-and-fills.md:39` (`cse-pro`) -> `01-a-triangle-a-square-and.svg` — student sees rendered SVG
      29. `content/lessons/reasoning/spatial-abstract-reasoning/figure-counts-and-fills.md:50` (`cse-pro`) -> `02-a-black-circle-a-white.svg` — student sees rendered SVG
      30. `content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md:19` (`cse-pro`) -> `01-four-equal-square-frames-with.svg` — student sees rendered SVG
      31. `content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md:29` (`cse-pro`) -> `02-four-equal-frames-containing-arrows.svg` — student sees rendered SVG
      32. `content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md:40` (`cse-pro`) -> `03-five-equal-square-frames-dots.svg` — student sees rendered SVG
      33. `content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md:51` (`cse-pro`) -> `04-arrows-pointing-up-upper-right.svg` — student sees rendered SVG
      34. `content/lessons/reasoning/spatial-abstract-reasoning/folded-layers-and-separate-holes.md:22` (`cse-pro`) -> `01-square-folded-left-half-onto.svg` — student sees rendered SVG
      35. `content/lessons/reasoning/spatial-abstract-reasoning/folded-layers-and-separate-holes.md:30` (`cse-pro`) -> `02-square-folded-left-onto-right.svg` — student sees rendered SVG
      36. `content/lessons/reasoning/spatial-abstract-reasoning/folded-layers-and-separate-holes.md:42` (`cse-pro`) -> `03-rectangle-folded-left-onto-right.svg` — student sees rendered SVG
      37. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:33` (`cse-pro`) -> `01-four-figures-in-one-row.svg` — student sees rendered SVG
      38. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:45` (`cse-pro`) -> `02-four-figures-in-one-row.svg` — student sees rendered SVG
      39. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:57` (`cse-pro`) -> `03-four-figures-in-one-row.svg` — student sees rendered SVG
      40. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details.md:17` (`cse-pro`) -> `01-one-row-containing-a-square.svg` — student sees rendered SVG
      41. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details.md:29` (`cse-pro`) -> `02-four-circles-in-one-row.svg` — student sees rendered SVG
      42. `content/lessons/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details.md:45` (`cse-pro`) -> `03-five-figures-in-one-row.svg` — student sees rendered SVG
      43. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features.md:28` (`cse-pro`) -> `01-a-3-by-3-grid.svg` — student sees rendered SVG
      44. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features.md:34` (`cse-pro`) -> `01-a-3-by-3-grid.svg` — student sees rendered SVG
      45. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules.md:18` (`cse-pro`) -> `01-a-3-by-3-grid.svg` — student sees rendered SVG
      46. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules.md:32` (`cse-pro`) -> `02-a-3-by-3-grid.svg` — student sees rendered SVG
      47. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts.md:29` (`cse-pro`) -> `01-a-2-by-2-grid.svg` — student sees rendered SVG
      48. `content/lessons/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts.md:45` (`cse-pro`) -> `02-a-3-by-3-grid.svg` — student sees rendered SVG
      49. `content/lessons/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule.md:32` (`cse-pro`) -> `01-five-labeled-figures-in-one.svg` — student sees rendered SVG
      50. `content/lessons/reasoning/spatial-abstract-reasoning/turning-solids-without-mirror-flips.md:36` (`cse-pro`) -> `01-original-3d-joint-with-long.svg` — student sees rendered SVG
      51. `content/lessons/reasoning/spatial-abstract-reasoning/uneven-folds-and-cut-layers.md:26` (`cse-pro`) -> `01-rectangle-12-cm-wide-and.svg` — student sees rendered SVG
      52. `content/lessons/reasoning/spatial-abstract-reasoning/unfolding-cuts-across-a-fold.md:32` (`cse-pro`) -> `01-square-folded-left-half-onto.svg` — student sees rendered SVG
    - *All 3 active CSE lessons flagged with `expected 0 code FIGURE markers, found N` (6 `FIGURE` markers total; all parse cleanly in `FigureRegistry` and render their code-drawn diagram):*
      1. `content/lessons/mathematics/arithmetic-number-sense/real-number-sets.md:31` (`cse-pro`, `cse-sub`) -> `concept-diagram` (`nested-boxes`) — student sees rendered diagram
      2. `content/lessons/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets.md:30,45,55` (`cse-pro`) -> 3 `cube-net` figures — student sees rendered diagrams
      3. `content/lessons/reasoning/spatial-abstract-reasoning/parallel-light-and-solid-shadows.md:34,44` (`cse-pro`) -> 2 `geometry-diagram` figures (`cylinder-shadow-above`, `cylinder-shadow-side`) — student sees rendered diagrams
- **What the student sees:** On CSE screens, **nothing is broken, raw, or blank**. Every one of the 52 active CSE `ILLUSTRATION` markers embeds and renders a preflight-clean local SVG, and all 6 active CSE `FIGURE` markers render their code-drawn diagrams. The 618 errors exist solely because `check_lesson_illustrations.py` checks prod's bite-sized lessons against `main`'s pre-split 279-row `strategy.tsv` manifest instead of verifying marker-to-asset resolution (which `lesson_illustrations.mjs` and `LessonAssetMap` already do).
- **Fix idea:** Replace `sweep_illustrations.py`'s stale `strategy.tsv` count assertion with a check that validates every `ILLUSTRATION` marker resolves 1:1 to a local asset with a credit (matching `lesson_illustrations.mjs` and `LessonAssetMap`) and every `FIGURE` marker is valid JSON with a kind in `FigureRegistry` (note `check_lesson_illustrations.py:51-74` also drifts from `FigureRegistry`, missing `grid-polygon` and listing non-existent `venn-diagram`). Add a `--root` option to `run_all.py` so it can audit any content tree without mutating tracked `docs/content/audit/sweep-results.tsv`, and catch per-sweep errors instead of aborting sweeps 4-11.

### C3-2. `tools/audit/run_all.py` crashes with `IndexError` on `main` (backlog C10) and `ModuleNotFoundError` under `python3 -I`

- **Severity:** minor (tooling crash; zero student impact)
- **Evidence:**
  - **Exact `IndexError` crash (backlog C10):** Running `python3 build/audit/scratch_main/tools/audit/run_all.py` against `main`'s `content/` completes all 11 sweeps, writes `11,798` lines to `sweep-results.tsv`, and crashes at `tools/audit/run_all.py:44`:
    ```
    Traceback (most recent call last):
      File ".../tools/audit/run_all.py", line 48, in <module>
        main()
      File ".../tools/audit/run_all.py", line 44, in main
        print(f"  {sev}: {sum(1 for l in lines if l.split(chr(9))[1] == sev)}")
      File ".../tools/audit/run_all.py", line 44, in <genexpr>
        print(f"  {sev}: {sum(1 for l in lines if l.split(chr(9))[1] == sev)}")
    IndexError: list index out of range
    ```
  - **Exact cause of `IndexError`:** `tools/audit/check_lesson_illustrations.py:173-176` (`check_inventory()`) prints a space-separated status line to stdout:
    `total=279 code=241 open=4 native=23 cut=8 founder=3`
    `run_all.py:36` redirects all sweep stdout into `buf` and writes it to `sweep-results.tsv` (line `205` is the only non-tabbed line out of `11,798`). Then `l.split(chr(9))[1]` raises `IndexError` on that single-column line.
  - **Exact `python3 -I` crash:** Running literally `python3 -I tools/audit/run_all.py` fails immediately at `tools/audit/run_all.py:6`:
    `ModuleNotFoundError: No module named 'sweep_structure'`
    because Python's `-I` isolated mode implies `-P` (safe path), omitting the script's own directory (`tools/audit/`) from `sys.path`, while `run_all.py` uses top-level sibling imports (`import sweep_structure`).
- **What the student sees:** Nothing; this is an offline audit script crash only.
- **Fix idea:** Print the `check_inventory()` summary line to `sys.stderr` (matching `QTOTAL` in `sweep_questions.py:205`) or silence it when called from `sweep_illustrations.py`, guard `run_all.py:44` against malformed/non-tabbed lines, and insert `Path(__file__).resolve().parent` onto `sys.path` (or use package-relative imports) if `python3 -I` invocation is required.

---

## Checklist Row C4: Question Approval Gate and Prod Public Corpus

### C4-1. Zero unapproved CSE questions exist in prod today (1,795 of 1,795 CSE questions approved; 4,427 of 4,427 total prod questions approved)

- **Severity:** minor (verification pass; backlog entry "968 unapproved questions still exported" is stale for prod, though the gate still allows legacy unapproved items on any future unsplit topic)
- **Evidence:**
  - **How approval is defined:** Per `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md` (B6, lines 391-420), `tool/checks/content_approval_check.dart:11-14`, `tool/content/content_gate.dart:19-91`, `tool/content/question_hash.dart:29-58`, and `tool/content/approve.dart:10-89`:
    - YAML `approved: true` is display-only and grants no shipping authority.
    - A question is **approved** only when its canonical SHA-256 `questionHash` (over `stem`, `explanation`, `passage`, `figure`, `figureSpec`, `choices` text/correct/rationale, sorted `meta.exams`, and resolved `lesson`) matches `content/question-ledger/approved.json[id].hash`.
    - A question is allowed to ship unapproved **only** if its hash matches pinned `content/question-ledger/legacy.json[id].hash` (SHA-256 `b28eb7bc7c6f975160338faa133c8c88e12ada289674161e7aca96747a5219e2`, matching `pinnedLegacyLedgers` in `content_gate.dart:25`) **and** its topic (`subject/topic`) is not in `splitTopics` (no lesson file in that topic has frontmatter `part:`).
  - **Gate enforcement in exporter and uploader:**
    - `tools/build_content_export/build_content_export.dart:115-122` runs `runContentGate('$root/content')` and exits `1` on any finding.
    - `tools/upload_content/upload_content.mjs:54-63` runs `dart run tool/content/content_gate.dart --root <root>` before constructing any document in every mode (`--dry-run`, `--live`, `--out-dir`, emulator) and exits `1` on failure; `--skip-invalid` does **not** bypass it.
    - `dart run tool/content/content_gate.dart --root build/audit/prodtree/content` exited `0` (0 findings).
    - `historical_v1.json` (merged by `build_content_export.dart:186-320` for native seeds only, not uploaded by `upload_content.mjs`) retains 2 legacy `exam_cse_pro` questions, both `isActive: false` (never served).
  - **Prod root counts (`build/audit/prodtree/content`, `d97de9415`):**
    - Total questions in prod: **4,427** — **4,427 approved** (`approved.json` hash match), **0 legacy unapproved**, **0 other**.
    - CSE-tagged questions (`meta.exams` includes `cse-pro` or `cse-sub`): **1,795** total (`cse-pro`: **1,751**, `cse-sub`: **1,523**; matches Nov 22 prod summary counts in `2026-10-19-pwa-launch-log.md:4099`).
    - Approved CSE-tagged: **1,795** (100% hash-verified in `approved.json` with verification evidence files dated `2026-11-14` to `2026-11-20`, and 100% `approved: true` in YAML).
    - Unapproved CSE-tagged: **0** (`build/audit/c4-unapproved-cse.txt` written with 0 IDs).
    - Per-subject breakdown (all 15 CSE topics are split with `part:` lessons):

| Subject | CSE-tagged | CSE Pro | CSE Sub | Approved | Unapproved | Unapproved exported/served? |
|---|---:|---:|---:|---:|---:|---|
| `general-information` | 570 | 570 | 570 | 570 | 0 | No (0 exist) |
| `language-proficiency` | 468 | 468 | 468 | 468 | 0 | No (0 exist) |
| `mathematics` | 284 | 284 | 232 | 284 | 0 | No (0 exist) |
| `reading-comprehension` | 189 | 189 | 189 | 189 | 0 | No (0 exist) |
| `reasoning` | 284 | 240 | 64 | 284 | 0 | No (0 exist) |
| **Total CSE** | **1,795** | **1,751** | **1,523** | **1,795** | **0** | **No (0 exist)** |

  - **Origin of the stale "968" figure:** `docs/superpowers/backlog.md:170` cites `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2398` (Nov 2, before the Nov 14-20 bite-sized split and re-approval passes). By contrast, `main`'s unmerged `content/` tree (which prod does not serve) still has `3,163` questions on `legacy.json` (`1,100` CSE-tagged, `0` in `approved.json`).
  - **One minor gate-vs-spec nuance:** Spec B6 (`docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md:413`) requires that a *subject* with any lesson carrying `part:` have no legacy-status question, whereas `tool/content/content_gate.dart:61,74` enforces this at the *topic* level (`subject/topic`). In prod today this causes no leak because every topic in the 4,427-question prod corpus is split and 100% approved.
- **What the student sees:** Every CSE question served on prod (`1,751` CSE Pro, `1,523` CSE Sub, `1,795` unique) is hash-approved in `approved.json`. No unapproved question is exported or served to public CSE students.
- **Fix idea:** Retire the stale "968 unapproved questions" backlog line (`docs/superpowers/backlog.md:170`). Now that 100% of prod (`4,427 / 4,427`) is approved, remove the `legacy.json` fallback from `tool/content/content_gate.dart` (or tighten `splitTopics` to `splitSubjects` if any unsplit legacy tree still uses the gate) so unapproved questions can never be exported or uploaded again.

---

## Summary

- **C3 (`tools/audit/run_all.py`):** **FAIL (tooling, not student-facing).** Running with `python3 -I` fails immediately with `ModuleNotFoundError: No module named 'sweep_structure'`. Running without `-I` against prod content (`build/audit/prodtree/content`) stops in sweep 3 (`sweep_illustrations`) with `618` stale-strategy stderr errors (not 182; grown after the Nov 20 CET split) and never runs sweeps 4-11; on `main`, `run_all.py:44` crashes with `IndexError` on the non-tabbed summary line printed by `check_lesson_illustrations.py:173-176`. However, tracing the upload and app render pipeline proves **0 of the 55 CSE-active flagged errors reach a student as broken, raw, or blank visuals**: all 52 CSE-active `ILLUSTRATION` markers embed preflight-clean SVGs and all 6 CSE-active `FIGURE` markers render registered painters.
- **C4 (Unapproved questions):** **PASS on prod.** All `1,795` CSE-tagged questions (`1,751` CSE Pro, `1,523` CSE Sub) and all `4,427` prod questions are 100% hash-approved in `question-ledger/approved.json` (`0` unapproved; `build/audit/c4-unapproved-cse.txt` has 0 IDs). Both `build_content_export.dart` and `upload_content.mjs` enforce `content_gate.dart` unconditionally (even with `--skip-invalid`); the legacy bypass only affects unsplit topics, and zero unsplit topics remain in prod.

STAGE-DONE
