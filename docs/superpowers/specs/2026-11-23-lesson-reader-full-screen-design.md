# Lesson reader, full screen on wide web ("4 Held"): build spec

Date: November 23, 2026. Owner of the design: UX design lead (operations manager brief, Aedwon away with decisions delegated). Owner of the build: CSE release lead. Status: council-approved (Gemini 4 Neon High and Claude Fable 5.2 high, four rounds). Ruling: `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, section "Nov 23, lesson reader full screen".

## Plain-language summary

On wide screens (1280 px and up) the lesson page drops the "In this lesson" outline on the left. The text keeps its comfortable width (640 px, about 70 characters a line) and the space on the right becomes a column for the lesson's figures. Each figure starts level with the paragraph that introduces it and stays in view while that text is on screen, then the end of the passage pushes it away. Words that name a part of the figure carry a dotted underline; pointing at one makes that part stand out. Sections move into the thin line under the top bar. Phones do not change. A lesson with no figures keeps one centered column.

Why: Aedwon asked to hide the left panel, use the full width and put figures beside the line they explain (Nov 23). Words near their graphic is the best-supported layout rule in multimedia learning (Mayer, spatial contiguity). The margin layout also makes the Circles lesson 30% shorter to scroll at 1440 px.

## Boards (the visual source of truth; build 1:1)

Canvas "Lesson Reader Full Screen": https://claude.ai/artifact/Sb3f8m64ZpouMDBKjTE14K

- `W4_Held` (council-approved, marked on the canvas): the whole lesson at rest, 1440 wide, light.
- `V4`: reading a worked solution, the figure held beside the steps, bar hidden.
- `V4b`: the end of the example card pushes the figure up and away.
- `H4`: pointing at a linked word ("hypotenuse"): its part thickens, the rest dims.
- `K1`: dark, top of the lesson. Figure plates stay light (approved).
- `M1100`: 1100 wide (600 text, 300 figures).
- `P_Light`, `P_Dark`: phone, unchanged from the approved phone reader.
- `MO`: motion, four looping scenes: hold and hand-off, Show solution, linked words, the section line.
- `R` is the shared component; `fs.css` and `reader.css` hold every value below.

Unchanged and still binding: Lesson Reader Polish option C (type, spacing, example cards, Show solution, tips and traps; no section eyebrows; 104 px before a major section on wide, 72 px on phone), the top bar and its scroll motion (RD_FocusMotion: the title fades in over the first 90 px, the bar hides after 120 px more and returns on the first scroll up), the wide page transition (Nov 4, option C), and the figure full-screen view (RD_Figure).

## Layout

- Width 1280 px and up: page 1,096 px centered; text column 640 px; gap 56 px; figure column 400 px.
- 1024 to 1279 px: text up to 600 px, gap 48 px, figure column 300 px, the block centered with side margins of at least 40 px.
- Under 1024 px: the phone layout (figures inline, one column).
- No figures in the lesson: the single centered 680 px column of the approved reader, at any width.
- The left outline is gone at every width.
- Figure plate in the figure column: background #FAFAF7 (light and dark), radius 14, padding 14 px top and bottom, 20 px sides, the approved expand button (34 px, radius 8, top right, 10 px inset). No caption or credit (Nov 5).

## Placing figures (the rules, in order)

1. Anchor. A figure's anchor is the block just before it in the lesson source. If that block is a list, the anchor is the list plus the sentence that introduces it, when that sentence ends with a colon. The plate's top aligns with the anchor's top plus 6 px (the first line's cap height).
2. Examples. A figure in an example's problem aligns with the example card's top. A closed card is at least as tall as its plate. A figure in the solution that redraws the problem figure replaces it in the same place when the solution opens (see Motion).
3. Passage. A figure's passage runs from its anchor to the first of: the next heading (## or ###), the next tip or trap block, the next figure's anchor, or the end of the example card. A figure never extends past its passage end: if it would, it moves up until its bottom meets the passage end. It may rise above its anchor, within its block: up to the start of its subsection, section or trap item (the heading's top), or 18 px below the previous plate, whichever is lower. Only if the plate is still taller than the space from there to the passage end does the passage get a minimum height (white space below the text).
4. Collision. If a prose figure's top would be closer than 18 px to the previous figure's bottom, it moves down to 18 px below it and joins that figure's stacked group. A figure at its own anchor starts a new group. Example figures never move (the card's minimum height clears them).
5. Stack cap. A stacked group may be at most the window height minus 32 px. The figure that would break the cap goes inline in the text column after its anchor instead, at the full text width, as on the phone.
5a. Stress result (run 5, seven lessons, solutions open and closed): no overlap, no overflow, no figure beside the wrong passage, no inline fallback, one 18 px push. Raising plates within their block (rule 3) moved three figures up by 83 to 176 px and cut the added white space under short passages to at most 59 px (Earth's Motions). The rest of the added height is closed example cards at their plate's height.
6. Wide art. A figure whose painted size is wider than 1.8 times its height goes inline at the full text width, not in the figure column. In today's corpus this covers at least the angle gallery (basic geometric concepts), the Earth's motions triptych and the three orbitals (quantum numbers); take the ratio from the painter's natural size, not from a list.
7. Remeasure. Positions are recomputed after fonts load, after math renders, when a solution opens or closes, when an image loads, and on window resize. A recompute never animates the text; figures settle without a visible jump (place before paint).

## Held figures (the "4 Held" behavior)

- While its passage is on screen, a figure stays in view: its top never goes above the sticky line. The sticky line is 92 px from the window top while the top bar shows, 32 px while it is hidden. When the bar slides away or returns, the sticky line moves with it, in the bar's own timing.
- The end of the passage pushes the figure up and away at the speed of the scroll. No fade, no easing: it moves with the page.
- Flutter web has no CSS sticky. Drive the hold in layout or paint from the scroll offset in the same frame (for example a custom scroll layout or a `Flow` delegate reading the scroll position), never from a scroll listener that rebuilds a frame later. If the hold cannot be made smooth on a mid-range laptop at 60 fps, ship the figures at rest only (direction 1, "Margin") and report it; do not fall back to the pinned stage (direction 2).

## Linked words

- Source: the figure's own labels in the lesson's FIGURE spec (`labels`). A label's core is the text before " = " or ":", without "Center " or "Point ". No new content.
- Match: within the figure's passage only. Labels of two letters or fewer match only inside math ($...$); longer labels match bold words in prose, whole word, ignoring case. Link the first mention per paragraph only. If the figure went inline, there are no links for it.
- Coverage in today's corpus: 70 of 241 lesson figures have at least one linkable label in their passage (160 of 453 labels). Everywhere else the text stays plain.
- Look: dotted underline 1.5 px, offset 4 px, color secondary text (#8A8A8E light).
- Pointer over, keyboard focus on, or a tap on (touch at wide widths) a linked word: the word's underline turns solid in the text color; in the figure, the named part keeps its own color and thickens to 4 px, its label goes bold, and every other part of that figure dims to 35% opacity. 150 ms. Pointing at a label in the figure does the same and underlines its words. Leaving restores in 150 ms. A tap elsewhere clears a tapped highlight.
- The figure painter must draw each labeled part as a separately styleable element tied to its label. A label the painter cannot tie to a part still gets the bold and the dim on the rest.
- Phone and widths under 1024 px: no underline, no link.

## Section line

- The 2 px progress line under the top bar is split into one segment per ## section, sized by the section's length, 3 px gaps. The current one fills as you read (scroll-linked).
- Each segment is a button: a 16 px tall hit area; on hover or focus it thickens to 4 px (100 ms) and its name shows in a small dark label below (100 ms delay). Click or Enter scrolls to the section over 400 ms with the shared ease. Tab order: after the lesson list button.

## Motion values

Shared ease `cubic-bezier(.32,.72,0,1)`.

| Moment | What moves | Duration | Easing |
|---|---|---|---|
| Hold and push-off | figure, scroll-linked | none (scroll) | none |
| Sticky line follows the bar | figure top 92 to 32 px | the bar's own timing (RD_FocusMotion) | the bar's |
| Show solution | card opens | 320 ms | shared |
| Problem figure gives way | opacity 1 to 0 | 180 ms | shared |
| Solution figure arrives, same place | opacity 0 to 1 | 240 ms | shared |
| New mark draws in (e.g. the right angle) | stroke draws | 240 ms, after the figure | shared |
| Linked word on and off | underline, stroke width, dim | 150 ms | ease-out |
| Section segment hover | 2 to 4 px, label | 100 ms | ease-out |
| Section click | page scroll | 400 ms | shared |
| Figure open full screen | as approved (RD_Figure) | as approved | as approved |

Reduced motion (prefers-reduced-motion): the hold still works (it is scroll position, not animation); Show solution and the figure swap become a 150 ms fade with no draw-in; the section click jumps.

## Acceptance checks

1. Side by side with the boards at 1440 and 1100 wide, light and dark, and with the phone boards at 390: no difference in layout, spacing, type or color. Differences are classed per the Nov 23 process entry (worse: fix; better: keep and update the canvas; unsure: council).
2. Motion recorded at 1440 and compared with `MO` for timing and easing.
3. Real-content run at windows 1440x650, 1440x720 and 1440x900, solutions open and closed, on: triangles, basic geometric concepts, circles, Earth's motions, truth tables, systems of equations, quantum numbers. For each: no plate overlaps another plate; no plate beside a different passage by more than 40 px; no element wider than its column (tables and math scroll inside their own box with `tabindex=0` if they ever do); every inline fallback is listed and explained by rule 5 or 6.
4. Scrolling a held figure at 60 fps on a mid-range laptop in Chrome and Safari, no shake against the text.
5. Linked words: in circles, "Tangent" lights the tangent line and dims the rest. In Example 4 with the solution open, `$AB$` in the first solution line ("... and $AB$ is the hypotenuse.") lights side AB, makes its label "AB = 10" bold and dims the rest. With the solution closed, `$BC$` in the problem lights side BC (label "BC = ?"). Keyboard: Tab reaches each linked word and each section segment, with the focus ring.
6. A lesson with no figures renders the centered 680 px column.
7. Phone unchanged: the approved phone boards match.

## Standards applied

- Long-form reading (`~/Documents/Projects/agent-standards/long-form-reading.md`): READ-MEASURE, READ-MEASURE-WCAG, READ-MARGIN, READ-MARGIN-ALIGN, READ-MARGIN-NARROW, READ-FIG-NEAR, READ-FIG-SIZE, READ-FOCUS, READ-FOCUS-KEYS, READ-WIDE, READ-REFLOW.
- Instructional design (`instructional-design.md`): ID-SPATIAL, ID-SIGNAL, ID-COHERE, ID-WORKED, ID-TRY.
- Web interface design (`web-interface-design.md`): WEB-T3, WEB-M1 to WEB-M6, WEB-M8, WEB-M9, WEB-M11, WEB-M13, WEB-I4, WEB-I10, WEB-A1.
- Typography and UX writing: TYP-HEAD, UXW-CONCISE (no new words on screen).

## Rejected directions (from the council)

- 1 Margin (his idea as stated): the figure scrolls away while the solution steps still refer to it. Held keeps it as the at-rest layout and fixes this.
- 2 Pinned stage: keeps stale figures beside unrelated sections and adds a timed swap the reader did not ask for.
- 3 Column: leaves about 760 px empty, 44% longer pages, ignores his guidance. Kept only for lessons with no figures.
