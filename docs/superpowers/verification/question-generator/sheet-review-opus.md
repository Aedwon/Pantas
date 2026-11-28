# Sheet review (Opus, independent)

Format: `<sheet file> | <type> #<index> | severity | what | evidence`

## figure-series (light and dark): 12 samples per sheet

- figure-series-dark.png | series-binary-fill #0 | Blocker | Dark theme draws the stem and the choices with opposite color conventions. The stem sits on a white card with literal black and white circles; the choices sit on the dark page, where choice A "White circle" is a near-invisible dark outline and choice B "Black circle" is a dark gray disc with no outline. Half and quarter fills in C and D are drawn light, not black. A dark-mode student cannot match "white" in the stem to choice A. | Data: stem fills black/white/black, A fill white, B fill black, C 0.5, D 0.25. Crop of the dark sheet at the binary-fill row shows A and B almost invisible. Likely cause: the stem goes through the figure registry (which puts black/white series on a white card), while the sheet harness paints each choice item itself with a dark palette. Whether the app's choice path does the same is not verified from the sheet; check it before treating this as sheet-only.
- figure-series-light.png, figure-series-dark.png | series-fill-ray-dots #32 | Major | The key feature "line E" is nearly invisible. A 90-degree ray starts at the center, lies on the same horizontal as the dot row, and on 0.5 fill it also lies on the fill boundary. In stem items 1 and 3 and in choices A, B and D the ray reads as a short dash merged with the dots and the fill edge. The student must infer the ray alternation E/S mostly from the S items. | Data: items line 90/180/90/180 with fill 0.5/0.25; A fill 0.5 line 90 dots 5. Five dots also span almost the full star width at the center line, touching the inner vertices.
- figure-series-light.png, figure-series-dark.png | series-fill-ray-dots #0 | Minor | A rightward ray (line 90) overlaps the center dot row, so stem items 2 and 4 and choice C read as dots joined by a segment rather than a ray from the center. Still solvable because up rays are clear. | Data: items 2 and 4 line 90 with dots 2 and 4; C line 90 dots 5.
- figure-series-light.png | series-fill-ray-dots #0 vs #32, series-dots-size #0 vs #77 | Minor | Choice text style differs between samples of one type: index 0 uses "Three-quarter-filled square; line up" (no dot count) and "Large star with four dots"; later indexes use "50%-filled star; 5 dots; line E" and "Large square; 3 dots". Compass letters (line E, line S, line N) are used in some samples and plain words (line right, line up) in others. | Choice "text" fields in the variants files.
- No issue found: series-dots-size #0, #77; series-four-tracks #0, #28; series-interleaved-count #0, #53; series-size-corner-ray #0; series-transfer-count #0; series-binary-fill #0 (light); series-ray-step #0. Each drawn figure matches its data and each key is the only defensible answer.

## shape-row (light and dark): 12 samples per sheet

- shape-row-light.png, shape-row-dark.png | group-polygon-replacement #0, #32, #91 | Major | Every choice figure shows two copies of the shape (two hexagons, two rectangles, two pentagons, two circles, two blobs, two dotted circles), but each choice's data is one shape. The sheet harness wraps the item in a two-shape row and means to clip to the first; the clip does not take effect. The sheet therefore does not show what a student would see, and "A circle with two dots" next to two dotted circles can be misread as a count. | Data: A figure {"form":"hexagon"} (single). test/tool/generator/figure_sheets_test.dart builds 'shapes': [item, item] with widthFactor 0.5.
- shape-row-light.png | group-boundary #0 and group-polygon-replacement #0 | Minor | Same stem figures (square, triangle, rectangle, circle) on one sheet. Stems ask different things (odd one out vs replacement), so allowed, reported per rule 5. group-polygon-replacement #91 is near-identical (parallelogram instead of square). | figureSpec shapes of both index-0 samples are equal.
- shape-row-light.png | group-boundary #35, #18; group-dot-count #28; group-dot-parity #53; group-side-double-dots #33 | Minor | Answers are "Figure 1..5" but the shape row draws no position numbers, so the student must count left to right. The contract has no labels for shape-row. | Stem images show no numbering.
- shape-row-light.png | group-dot-parity #53 | Minor | Figure 3 has zero dots; the key relies on the student treating zero as even. Correct, but a weaker student may pick Figure 3 as "not even". | shapes dots 1,2,0,4; key Figure 1.
- No issue found in figure data or keys: group-boundary #0, #35, #18; group-dot-count #0, #28; group-dot-parity #0; group-side-double-dots #0, #33. Dark sheet matches light; no contrast or clipping issues.

## cube-net (light and dark): 12 samples per sheet

Each net was folded by computing opposite-face pairs from the drawn cells; three faces meet at a corner exactly when no two are opposite. All 12 keys are the only valid set, all drawn nets match their cells and labels, and every net is a valid cube net.

- cube-net-light.png, cube-net-dark.png | net-three-at-corner #61, #14, #62 | Minor | Three samples on one sheet show the identical net (A B / C / D E / F). Keys differ (A,B,F; B,C,E; A,B,C), so rule 5 is not broken, but #61 and #62 even share distractors A,B,D and A,B,E. A student meeting both in one session sees the same picture with "B, F, C" wrong in one and "B, C, F" wrong in the other. | cells [[0,0],[0,1],[1,1],[2,1],[2,2],[3,1]] in all three.
- cube-net-light.png, cube-net-dark.png | net-three-at-corner #35 and #48 | Minor | Same net drawn twice on one sheet; keys differ (A,B,C vs B,D,F). | cells [[0,0],[0,1],[1,1],[1,2],[2,1],[3,1]] in both.
- cube-net-light.png | net-three-at-corner #11 | Minor | The five-row net is drawn at a smaller cell size than the others, so its labels are smaller; still readable. | Visual.
- No issue found in figure data or keys: #0, #11, #60, #48, #17, #61, #22, #15, #35, #14, #28, #62. Dark sheet matches light.

## figure-matrix (light and dark): 12 samples per sheet

- figure-matrix-dark.png | matrix-fill-union #0, matrix-binary-fill-row #0, matrix-size-fill #0 | Blocker | Same dark-theme fault as series-binary-fill #0. The stem grid sits on a white card with literal black/white fills; the choices sit on the dark page with a different palette. Black and white choices (fill-union A and B; binary-fill-row A, B, D; size-fill A, B, C, D) are near-invisible dark shapes. Half fills invert: fill-union C "Bottom-half-filled" shows a white bottom, while the stem's bottom halves are black. In size-fill all four choices are almost invisible, so the item cannot be answered in dark mode. | Data: size-fill choices fill white/black/white/white; fill-union C fill 0.5. Visible on the dark sheet. Same likely cause (harness choice painter vs registry stem); app path unverified.
- figure-matrix-light.png, figure-matrix-dark.png | matrix-size-dots #0 | Major | Dot count is the column rule, but in small and medium triangles the dots are tiny, crowded onto the base, and their radius changes from cell to cell (one dot is large, three dots are pin-pricks). Row 1 column 3 (small triangle, 3 dots) is hard to count at sheet scale; varying dot size also suggests a false size feature. | Data: row 1 dots 1/2/3 at size small. 2x crop of the stem shows dot radius roughly halves between the 1-dot and 3-dot cells.
- figure-matrix-light.png | matrix-dot-sum #0 | Minor | Row 2 column 3 (4 dots in a small circle) puts the outer dots almost on the outline. Countable. | dots 4 in a matrix cell circle.
- figure-matrix-light.png | matrix-ray-union #0, matrix-ray-intersection #0 | Minor | Choice text "both diagonal rays" and "all three diagonal rays" assume the student knows which diagonals; a square has four. Text is "the two/three shown" in effect; clearer would name directions. | Choice text fields.
- figure-matrix-light.png | matrix-sized-ray-union #0, matrix-size-latin #0 | Minor | Stem size steps are small in absolute terms (about 22/30/36 px), and choice figures are drawn at a different scale from stem cells, so "Medium" vs "Large" relies on relative comparison within the choices. Key remains unique. | Visual measurement.
- No issue found in figure data or keys: matrix-dot-sum, fill-union, ray-union, sized-ray-union, ray-intersection, binary-fill-row, form-ray, outline-latin, size-dots, size-fill, size-latin, size-transfer (all #0). Every key is the only defensible answer; size-transfer edge lines are not clipped.

## figure-matrix-2 (light and dark): 12 samples per sheet

Eight samples repeat figure-matrix sheet 1 exactly (dot-sum, fill-union, ray-union, sized-ray-union, ray-intersection, binary-fill-row, form-ray, outline-latin, all #0); findings above apply to them here too, including the dark-theme Blocker for fill-union #0 and binary-fill-row #0 on figure-matrix-dark-2.png. New samples: arrow-column #0, corner-reflection #0, growing-turn #0, ray-turn #0.

- figure-matrix-dark-2.png | matrix-fill-union #0, matrix-binary-fill-row #0 | Blocker | Same as on figure-matrix-dark.png: black/white choices near-invisible and half fills inverted against the white-card stem. | Visible on the dark sheet.
- figure-matrix-light-2.png | matrix-ray-turn #0, matrix-form-ray #0 | Minor | In a triangle, an up ray (line 0) runs from the centroid to the apex and reads as a line hanging down from the apex. A student could read the first cell as "down" and the turn as counterclockwise. Squares and pentagons do not have this problem. | ray-turn row 1 col 1 triangle line 0; 2.5x crop.
- figure-matrix-light-2.png | matrix-corner-reflection #0 | Minor | The shown cells also fit a clockwise corner step (TL to TR, BR to BL), so two rules give the same key. Not a second answer, noted for the record. | cells TL, TR / BR, blank; key BL.
- figure-matrix-light-2.png | sheet | Minor | Two thirds of this sheet duplicates sheet 1, so only 4 of 12 slots add coverage. | Sample captions.
- No issue found in figure data or keys: arrow-column #0, corner-reflection #0, growing-turn #0 (row steps 45/90/135, answer 270), ray-turn #0.

## Counts

- figure-series-light: 12 checked, findings 3 (0 Blocker, 1 Major, 2 Minor)
- figure-series-dark: 12 checked, findings 3 (1 Blocker, 1 Major, 1 Minor)
- shape-row-light: 12 checked, findings 4 (0 Blocker, 1 Major, 3 Minor)
- shape-row-dark: 12 checked, findings 1 (0 Blocker, 1 Major)
- cube-net-light: 12 checked, findings 3 (all Minor)
- cube-net-dark: 12 checked, findings 2 (all Minor)
- figure-matrix-light: 12 checked, findings 4 (0 Blocker, 1 Major, 3 Minor)
- figure-matrix-dark: 12 checked, findings 2 (1 Blocker covering 3 samples, 1 Major)
- figure-matrix-light-2: 12 checked, findings 3 Minor (plus repeated sheet-1 findings for the 8 shared samples)
- figure-matrix-dark-2: 12 checked, findings 1 Blocker covering 2 samples (plus repeated sheet-1 findings)

Unique samples: 52 (matrix-2 repeats 8 from matrix sheet 1).

SAMPLES CHECKED: 120
