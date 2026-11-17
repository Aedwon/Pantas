# Independent figure sheet review

Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885 (descendant of 1295c1866). Workstream: 867d39e6c2b2eabad25f092248e23838a354af4e. Review only; this file is the sole writable output under the specific assignment. No fixes, staging, commits, or acceptance of the combined build.

figure-series-dark.png | series-binary-fill #0 | Major | The keyed white-circle choice and black-circle distractor are nearly invisible against the dark sheet. | A has a dark outline on the dark background; B is dark-filled with no contrasting boundary. The stem uses a white panel and is readable, but its choices do not. Data specifies A fill=white and B fill=black.
shape-row-dark.png | group-polygon-replacement #0 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
shape-row-dark.png | group-polygon-replacement #32 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
shape-row-dark.png | group-polygon-replacement #91 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
shape-row-light.png | group-polygon-replacement #0 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
shape-row-light.png | group-polygon-replacement #32 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
shape-row-light.png | group-polygon-replacement #91 | Major | Every choice draws two copies of its replacement figure instead of the single figure in its data and text. | Each choice.figure is one object with form (and dots for D); the sheet shows paired outlines under A, B, C, and D. Choice D consequently displays two circles with two dots each.
figure-matrix-dark.png | matrix-fill-union #0 | Major | The fully black and fully white choice squares are nearly invisible in dark mode. | A is dark-filled against the dark sheet; B has a dark outline. The stem has a white panel, but A and B do not. Their data are fill=black and fill=white respectively.
figure-matrix-dark.png | matrix-binary-fill-row #0 | Major | The black-star key and white-star and black-circle distractors are nearly invisible in dark mode. | A and D use dark solid fills and B uses a dark outline on the dark sheet. The stem is readable on a white panel; its choices lack that panel.
figure-matrix-dark-2.png | matrix-fill-union #0 | Major | The fully black and fully white choice squares are nearly invisible in dark mode. | A is dark-filled against the dark sheet; B has a dark outline. The stem has a white panel, but A and B do not. Their data are fill=black and fill=white respectively.
figure-matrix-dark-2.png | matrix-binary-fill-row #0 | Major | The black-star key and white-star and black-circle distractors are nearly invisible in dark mode. | A and D use dark solid fills and B uses a dark outline on the dark sheet. The stem is readable on a white panel; its choices lack that panel.
figure-matrix-dark.png | matrix-size-fill #0 | Major | All four choice figures lack enough contrast to read their sizes and fills reliably. | A, C, and D are dark square outlines against the dark sheet; B is a dark solid square. These are the large white, large black, medium white, and small white choices in the data.
shape-row-dark.png | group-boundary #0 | Minor | The stem figures are repeated verbatim in group-polygon-replacement #0 on the same sheet. | Both show square, triangle, rectangle, circle in that order. Their stems ask different tasks (identify the curved outline versus replace it), so this is an allowed cross-type lookalike, reported as requested. Their correct answers differ.
shape-row-light.png | group-boundary #0 | Minor | The stem figures are repeated verbatim in group-polygon-replacement #0 on the same sheet. | Both show square, triangle, rectangle, circle in that order. Their stems ask different tasks (identify the curved outline versus replace it), so this is an allowed cross-type lookalike, reported as requested. Their correct answers differ.

## Needs the lead

Both required Dart checks are blocked by the SDK cache permission boundary. Each exits 1 before executing its check: `/opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted`, followed by `engine.realm: Operation not permitted` from `update_engine_version.sh` lines 71 and 78. No permission escalation is available. This does not block inspection of the supplied images and variant data. No fix or UI change was attempted.

## Coverage and solving record

Checked every captioned sample against its own variant record and resolved type stem: 52 unique data samples, appearing in 120 sheet placements. Compared stem figures and every illustrated choice for form, relative size, fill, rays/directions, dots, edge lines, and net cells/labels. Compared every choice description with its illustrated features. Checked clipping, overlap, and readability in both supplied themes. No source, test, widget, or screen was changed.

Independent solves support A for each sampled instance. Series: alternating sizes plus increasing dots; alternating fill/ray plus increasing dots; alternating outlines/sizes plus turning ray and increasing edge lines; interleaved counts; clockwise corner movement; edge-to-dot transfer; binary fill alternation; 45-degree ray progression. Grouping: curved boundary; straight-sided replacement; unequal dot count; odd/even dot count; twice-the-dot-count side rule. Matrices: matching arrows by row; left/right corner reflection; increasing row turn; quarter-turn by row; dot addition; fill union; ray union; size plus ray union; shared-ray intersection; fill alternation; row outline plus column ray; outline cycle; row size plus column dots; row size plus column fill; size cycle; size plus dot/edge transfer. No wrong key or concrete second offered answer was established for these particular samples. This does not clear any held type or unsampled index.

Cube-net opposite pairs, independently obtained by propagating face orientations across shared edges: #0 AF/BD/CE; #11 AC/BE/DF; #60 AD/BF/CE; #48 AD/BE/CF; #17 AD/BE/CF; #61 AE/BD/CF; #22 AE/BD/CF; #15 AC/BE/DF; #35 AD/BE/CF; #14 AE/BD/CF; #28 AF/BD/CE; #62 AE/BD/CF. In each sample, only A selects one face from each opposite pair.

No within-sheet sample pair repeats both the same prompt figure data and the same correct answer. The grouping cross-type prompt lookalike is reported above as requested. Cube #48/#35 share a net with different correct face triples; #61/#14/#62 also share a net with different correct triples. The two matrix sets repeat eight type/index pairs across separate sheets, not within one sheet.

## Verification

- `flutter test test/tool/generator`: NOT RUN, no generator or test edits; documentation-only review scope.
- `flutter analyze tool/generator test/tool/generator`: NOT RUN, no Dart edits.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: NOT RUN, no Dart edits.
- `dart run tool/checks/run_checks.dart`: BLOCKED/FAIL, exit 1 before checks. `engine.stamp.tmp.91128: Operation not permitted`; `engine.realm: Operation not permitted`.
- `dart run tool/check_no_ai_attribution.dart`: BLOCKED/FAIL, exit 1 before check. `engine.stamp.tmp.91129: Operation not permitted`; `engine.realm: Operation not permitted`.
- Read-only sample inventory and duplicate comparison: PASS, 52 unique samples, 120 placements, no exact prompt-plus-answer duplicate within a sheet.
- Report content check: PASS, all 14 finding records have five fields, no em dashes or trailing whitespace, all 10 sheet counts present.

## Counts per sheet

cube-net-dark.png: 12 samples checked; 0 findings.

cube-net-light.png: 12 samples checked; 0 findings.

figure-matrix-dark-2.png: 12 samples checked; 2 findings.

figure-matrix-dark.png: 12 samples checked; 3 findings.

figure-matrix-light-2.png: 12 samples checked; 0 findings.

figure-matrix-light.png: 12 samples checked; 0 findings.

figure-series-dark.png: 12 samples checked; 1 findings.

figure-series-light.png: 12 samples checked; 0 findings.

shape-row-dark.png: 12 samples checked; 4 findings.

shape-row-light.png: 12 samples checked; 4 findings.

Total: 12 Major findings and 2 Minor lookalike reports; 0 Blockers. Only this findings file was written. SDK checks remain for the lead in a permitted environment.

SAMPLES CHECKED: 120
