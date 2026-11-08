# Motion

Motion in Pantas explains a change in place. It is quick, it settles, and it never loops unless a board marks it continuous. The phone canvas and the phone code are the reference: where the phone animates, the wide web animates too. Approved motion is never removed without approval.

Generic motion uses the curve and duration tokens, never a literal. A named choreography (below) may keep its board's own sub-timings and curves; each is listed with its numbers. Effects with a class name are built in `bundle.css`; the choreographies and the roll counter, confetti, reader focus bar and pull to advance are specified here and built in the app (each says "Not built in CSS"). Every value has its Flutter form (R2-O19).

## Curves

| Token | CSS | Flutter | Use |
|---|---|---|---|
| `motion-enter` | `cubic-bezier(.2,.9,.3,1)` | `Cubic(.2,.9,.3,1)` (`riseIn`) | Things arriving: rise, fade-in, push, slide-in panel, list reveal, bar fills. Desktop default. |
| `motion-house` | `cubic-bezier(.3,.9,.3,1)` | `Cubic(.3,.9,.3,1)` (`houseOut`) | Dialog open and close, toast, notice collapse, ring fills. The phone's default ease-out. |
| `motion-move` | `cubic-bezier(.32,.72,0,1)` | `Cubic(.32,.72,0,1)` (`shared`) | Spatial moves of something already on screen: sliding markers, segmented thumb, nav panel, arrow nudge, page and lesson open, reveal phases. The handoff "shared ease". |
| `motion-slide` | `cubic-bezier(.2,1,.35,1)` | `Cubic(.2,1,.35,1)` (`slideC`) | Drawer and sheet open and close. |
| `motion-spring` | `cubic-bezier(.34,1.56,.64,1)` | `Cubic(.34,1.56,.64,1)` (`popC`) | Overshoot in a transition: switch thumb, edge tab. Never on keyframes that already overshoot (pops use `motion-enter`, R2-O13). |
| `motion-pop-b` | `cubic-bezier(.3,1.5,.5,1)` | `Cubic(.3,1.5,.5,1)` (`popB`) | Badge and letter pops, the exam-switch check. |
| `motion-fade` | `cubic-bezier(.25,.1,.25,1)` | `Cubic(.25,.1,.25,1)` (`ease`) | Color and opacity only: hover tints, crossfades, state flips. |
| `motion-draw` | `cubic-bezier(.6,0,.3,1)` | `Cubic(.6,0,.3,1)` (`checkDraw`) | Strokes drawing: check marks, ring arcs. |
| `motion-gauge` | `cubic-bezier(.2,.8,.25,1)` | `Cubic(.2,.8,.25,1)` (`slideB`) | Half gauge fill, roll counter. |
| `motion-scroll` | `cubic-bezier(.22,1,.36,1)` | `Cubic(.22,1,.36,1)` (`slideA`) | Shapes scroll-linked motion: reader bar, pull to advance. |
| `motion-liquid` | `cubic-bezier(.45,0,.25,1)` | `Cubic(.45,0,.25,1)` (`liquid`) | Liquid fills: the exam switch. |
| `motion-burst` | `cubic-bezier(.15,.7,.35,1)` | `Cubic(.15,.7,.35,1)` (`burst`) | Confetti only. |
| `motion-linear` | `linear` | `Curves.linear` | Spinners and scroll-linked motion only. |

The boards drew 45 distinct curves. They fold into these roles; the folds are listed in the README (D34, D77). Do not fold another curve without a Decisions line.

## Durations

### Scale (generic motion picks only from these)
| Token | ms | Flutter | Use |
|---|---|---|---|
| `dur-short-1` | 120 | 120 (`tap`) | Press down |
| `dur-short-2` | 150 | 150 (code `quick` is 160, D93) | Hover color and tint; late reveal delay |
| `dur-short-3` | 180 | 180 (`release`) | Press release; answer ring and fill |
| `dur-medium-1` | 240 | 240 (`base`) | Moves, swaps, sliding markers, thumbs, popovers, pane change |
| `dur-medium-2` | 320 | 320 (`page`) | Page and lesson open, dialog close |
| `dur-medium-3` | 420 | 420 | Pop, dialog open |
| `dur-long-1` | 450 | 450 | Rise-in of a block, drawer and sheet open |
| `dur-long-2` | 600 | 600 | Bars filling |
| `dur-long-3` | 900 | 900 | Rings filling, spinner turn |

### Approved one-off values (each has a single owner; never used for generic motion)
| Token | ms | Owner |
|---|---|---|
| `dur-nudge` | 200 | Arrow and chevron nudge |
| `dur-fade` | 250 | Switch track, toast in, floating bar back to neutral |
| `dur-flip` | 300 | State flips, toast out, floating bar to a result, dialog scrim |
| `dur-switch` | 350 | Switch thumb, drawer and sheet scrim, collapse |
| `dur-slide` | 380 | Push from the side, check mark draw |
| `dur-drawer-close` | 400 | Drawer and sheet close |
| `dur-nav-panel` | 460 | Mock question list toggle |
| `dur-reveal` | 500 | Explanation slide-in |
| `dur-gauge` | 1400 | Half gauge fill |
| `dur-wait` | 300 | Delay before a ring fill, a skeleton or the edge tab (a delay) |
| `dur-stagger` | 80 | Step between staggered siblings (a delay) |
| `dur-pulse` | 1300 | Skeleton pulse cycle |
| `dur-toast` | 4000 | Toast without an action |
| `dur-toast-action` | 8000 | Toast with an action (Undo) |

`dur-instant` (100, "press-dip out") is removed in 3.0.0: nothing used it (R2-O23).

Tiers: micro 100 to 180 (press, hover), small 200 to 300 (markers, thumbs, state), medium 320 to 480 (pages, sheets, dialogs), large 500 to 1400 (fills, counters), choreographed 1.5s and longer (timelines below).

## Effects

### Press
`transform: scale(.97)` on `:active` (options and tiles `.98`, checkbox and radio `.94`, tab items `.96`). `dur-short-1` down, `dur-short-3` up, `motion-move`. Every tappable. No shadow lift. Dragging past the touch slop releases. Flutter: `PressScale`.

### Hover (fine pointer)
Background or color fades over `dur-short-2` with `motion-fade`. Filled: one step darker. Ghost: label color at 8%. Rows: `surface-hover`, the chevron fades in. Arrow link: the arrow moves `translateX(4px)` over `dur-nudge` with `motion-move`. Hover-only cues follow the input (`hover: hover` and `pointer: fine`), not the width.

### Rise (`.rise`, `.stagger > *`, `pn-rise`)
```css
@keyframes pn-rise { from { opacity: 0; transform: translateY(14px) } to { opacity: 1; transform: none } }
animation: pn-rise var(--dur-long-1) var(--motion-enter) both;
animation-delay: calc(var(--i, 0) * var(--dur-stagger));
```
Set `--i` to the sibling index (0, 1, 2) on each child, or on each `.rise`. Smaller rises: 8px for panes and popovers, 24px for the reader and dialogs.

### Pop (`.pop`, `pn-pop`)
One definition for checks, dots, badges and chips: scale .4 to 1.08 at 60% to 1, opacity 0 to 1, `dur-medium-3`. The overshoot lives in the keyframes, so each segment eases without overshoot: 0 to 60% on `motion-enter`, 60 to 100% on `motion-fade` (set inside `pn-pop`). The drawn peak is the ruled 1.08 (R2-O13, D113; with `motion-spring` it drew about 1.15). Rule: a keyframed overshoot never also takes an overshooting curve. Flutter: `TweenSequence([TweenSequenceItem(tween: Tween(begin: .4, end: 1.08).chain(CurveTween(curve: Cubic(.2,.9,.3,1))), weight: 60), TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Cubic(.25,.1,.25,1))), weight: 40)])`. The answer reveal uses its own stronger pop (below).

### Push (`.push`) and slide-in (`.slide-in`)
Push: new screen or value from the right, `translateX(40px)` and fade, `dur-slide`, `motion-enter`. Slide-in: the explanation column, `translateX(28px)` and fade, `dur-reveal`, `motion-enter`.

### Overlays (Dialog, Drawer, Sheet, Popover, Toast)
Each overlay has four states: entering (mounted with the open animation), open, exiting (`.is-exiting` plays the exit), closed (unmounted when the exit ends). Reduced motion settles at once.

| Overlay | Open | Close | Curve | Scrim | Offset |
|---|---|---|---|---|---|
| Dialog | `dur-medium-3` 420 | `dur-medium-2` 320 | `motion-house` | 300 linear | rise 24 and fade |
| Drawer | `dur-long-1` 450 | `dur-drawer-close` 400 | `motion-slide` | 350 `motion-fade` | slide 105% of its width |
| Sheet | `dur-long-1` 450 | `dur-drawer-close` 400 | `motion-slide` | 350 `motion-fade` | slide 105% of its height; the page behind may scale to .985 and shift 10px for tall sheets |
| Popover | `dur-medium-1` 240 | 240 | `motion-move` | none | rise 8 and fade |
| Toast | `dur-fade` 250 | `dur-flip` 300 | `motion-house` | none | rise 16 in, sink 8 out |

These are the phone code's numbers (`WebOverlayMotion`, `PantasSheet`). Flutter: the same presets.

### Toast timing
4s without an action (`dur-toast`), 8s with an action (`dur-toast-action`). Pause while hovered, while focused, and while a screen reader is inside. Never auto-dismiss when the action is the only way to recover; use a Notice. One toast at a time: a new one replaces the current one after the current one has shown for 2s; the rest queue.

### View swap (`.swap-out`, `.swap-in`) and pane change (`.pane-out`, `.pane-in`)
View swap (240ms clock): the old block fades out over 0 to 100ms (`motion-fade`) drifting 12px away; the new block fades in over 60 to 240ms (`motion-move`) drifting 12px in. Set `--dir` to 1 or -1 by index order. A near-full-screen block slides 24px with no fade. Pane change: outgoing opacity 1 to 0 over 0 to 90ms; incoming 0 to 1 over 70 to 240ms rising 8px. Page and lesson open (`.page-in`): `dur-medium-2`, `motion-move`, rise 8. Flutter: `ViewSwap`, `PaneMotion`.

### Sliding marker (`.tabbar__marker`, `.sidebar__marker`, `.seg__thumb`)
The TabBar active item, the sidebar active item and the segmented thumb are real elements that glide to the new item; `transform` animates over `dur-medium-1` with `motion-move`. The TabBar and the segmented thumb read the count and the selected item from the markup through `:has()` (no inline `--n` or `--i`, ruling 6). The sidebar marker is placed from the measured current item (`--active-top`, `--active-height`; R3-A14), so it stays on its item at large text. Flutter: `SlidingMarker` from measured item bounds, never `index * 44`.

### Switch
Track color `dur-fade` (`motion-fade`). Thumb `translateX(20px)` over `dur-switch` with `motion-spring`.

### Ring fill (`.ring__value`) and gauge fill (`.gauge__value`)
```css
@keyframes pn-ring { from { stroke-dasharray: 0 100 } }   /* pathLength="100" */
.ring__value  { animation: pn-ring var(--dur-long-3) var(--motion-house) var(--dur-wait) both }
.gauge__value { animation: pn-ring var(--dur-gauge) var(--motion-gauge) var(--dur-wait) both }
```
Numbers count up with a cubic ease-out over the same length and land exactly. Rings 900 after 300 (ruled, D38); gauges 1400 (D79).

### Bar grow (`.bar5 > i`)
`width` from 0, `dur-long-2`, `motion-house` (the app's accuracy bar).

### Check draw (`.draw-check`)
Stroke `dashoffset 26` to `0`, `dur-slide`, `motion-draw`, 120ms delay.

### Roll counter (not built in CSS)
A digit column translates up: the old digit leaves (`translateY(-110%)` and fade), the new digit enters from below (`translateY(110%)` to rest) in `accent`. Short rolls 553ms on `motion-gauge`. Used for scores.

### Ripple (`.opt.is-right.is-ripple`)
The right-answer ring: `box-shadow` spreads 0 to 16px from `accent` at `opacity-ripple` (0.38) to 0, 700ms after 50ms, `ease-out`.

### Skeleton
Hidden for `dur-wait`, then opacity pulses 1 to .45 over `dur-pulse`, `ease-in-out`. Crossfade to content: the placeholder fades out over 200ms (`.skel-out`), the content fades in over 300ms starting 60ms later (`.skel-in`).

### Spinner
`rotate(360deg)` over `dur-long-3`, `motion-linear`, infinite. Under reduced motion: a static arc and a visible "Loading" label (`.spinner__label`).

### Collapse (`.notice.is-collapsing`)
`max-height` (set `--h` to the measured height, in px) and opacity to 0 over `dur-switch`, `motion-house`. Used by the Home notice.

### Tassel swing (`.tassel-swing`)
Rotate about the top of the cord: 0, 11, -8, 5, -2.5, 0 degrees at 0, 18, 38, 56, 74, 100% of 2200ms, after a 400ms wait, curve `(.36,.07,.19,.97)` (the app's `shake` curve). Waiting screen only.

### Confetti (not built in CSS)
Pieces 8 by 12px, radius 2, fly to `(--dx, --dy)` and rotate `--r` over 1100ms, `motion-burst`, staggered up to 80ms, scale .2 to 1 at 7%, fade out from 75%. Only for a new best mock score.

## Choreographed pieces

Each has its own timeline. Read the named board for exact keyframes; the numbers below are the approved ones. Each piece also states its lifecycle: what is committed and when, when input returns, what a second tap, a route change or backgrounding does, and how it settles. One shared "settle to end" operation jumps any choreography to its last frame; reduced motion, a route change and an interruption all use it. Results are announced once, after they are committed. Normal playback is unchanged.

### Mock question list toggle (460ms, MK_NavMotion)
Panel (`.qpanel`) `translateX(-100%)` over `dur-nav-panel` with `motion-move`. The content's left padding (`.qpanel-shift`) goes 340 to 40 and the bottom bar re-centers, both in sync. Panel children fade in after 120ms over 220ms and leave over 160ms. The edge tab (`.qpanel-tab`) arrives 300ms later over 500ms with `motion-spring` and widens from 34 to 40px on hover over `dur-nudge`.
Lifecycle: nothing is committed. Input stays live. A second tap reverses from the current position.

### Pause sequence (about 3.3s, MK_PauseMotion)
Warning dialog: scrim 220ms, dialog pop 320ms with `(.34,1.4,.64,1)`. The question layer dissolves (scale .965, blur 6px, opacity 0) over 550 to 800ms. The hourglass and time drop in big (scale 1.4, translateY -56, rotate -7deg) over 594ms, hold 1650ms, then glide home over 1056ms. The last grains fall at 1050ms (450ms). The hourglass settles with a small squash at 1520ms (450ms). "Paused" opens above the frozen time at 1550ms (500ms). Controls rise in, staggered. The frozen time blinks (1800ms loop, opacity 1 to .3). The hourglass tips now and then (6000ms loop from 3000ms). Resume reverses it: glide back 750ms, grains refill 400ms. The loops run only while paused.
Lifecycle: the pause is committed (the clock stops) at the tap, before the animation. Resume and Discard take input once the controls have risen in; a tap earlier settles to the end first. Backgrounding keeps the paused state. Reduced motion: the paused screen at once, no blink and no tip. Ruled: the blink stays (D83); under reduced motion it is static.

### Mock finale (11.35s; UPCAT 11.43s; MK_Finale, MK_FinaleUPCAT)
"Time is up." 0 to 920ms. The grid shrinks to the four-subject layout 820 to 1460ms. A scan line moves down 2150 to 2940ms turning right answers teal. Wrong and blank fade at 3220ms. Right answers gather into a ball 3668 to 4560ms. The ball winds up and shoots to the ring start at 4580ms with a burst, sparks and a small shake (4600 to 4770ms). The ring arc draws 4580 to 5200ms. The score rolls up from 5430ms. The "done" copy appears at 6450ms. The Today dot pops 7540 to 7910ms, the line draws 7990 to 8540ms, the dot pulses 8590 to 8990ms, the label fades in 8750 to 9050ms. UPCAT: wrong answers turn `danger-muted` at the scan and drop into a red ball; the red lobs over the ring tip, shakes the other way with a red burst, the teal snaps back from 68.4 to 61.2 and a red chunk drains into the tip; the score rolls 68.4 to 61.2, then "171 correct, minus 18 wrong". Curves: the finale boards' `(.3,0,.4,1)` and `(.3,0,.5,1)` in-out, `(.55,0,1,.45)` for the wind-up arcs, `motion-burst` for sparks. Confetti only for a new best.
Lifecycle: the score is computed and saved before the finale starts; the finale only shows it. A tap or Esc settles to the end; the results page is usable from the end frame. A route change or backgrounding settles to the end. The score is announced once ("Your score: 61.2%") when the ring lands.

### Exam switch (6.4s, ST_ExamSwitchCount; not built in CSS)
Press ripple on Count Them 8 to 16% (`ease`). Text drops away 11 to 16%. The vessels glide down 58px and scale 1.12 at 12 to 19% (`motion-house`). The tube fills 19.5 to 24.2% (300ms, `motion-liquid`). The liquid drains and fills 22.7 to 47.7% (1600ms, `motion-liquid`). The tube empties 47.7 to 52.3%. Labels swap color 51.6 to 56.3% (300ms). A check pops 52.3 to 57% (300ms, `motion-pop-b`). The new copy and Done fade in 57 to 65% rising 8px.
Lifecycle: the exam switch is saved at the press; the animation follows. Done takes input once it appears; a tap earlier settles to the end. Reduced motion shows the end state.

### Answer reveal (1840ms in the app, RV_Reveal)
Pick ring and fill change in `dur-short-3`. The check badge pops from .4 to 1.15 (1.1 for a wrong pick) over 320ms, then settles to 1 by 560ms (`.opt__mark`, `pn-pop-strong` and `pn-pop-wrong`). The question column slides left from 240 to 1200ms. The explanation pane slides in from 880 to 1840ms. All on `motion-move`. The right answer turns teal 150ms after a wrong pick (`.is-late`, `--reveal-delay`). No shake.
Lifecycle: the answer is saved at Check. Next takes input at once (it settles the reveal first). The result is announced once through the floating bar hint.

### Reader top bar (ReaderTopBar, scroll-linked, RD_FocusMotion; built as states, ruling 2)
The title fades in and rises 6px into the bar once the reader has scrolled `layout-reader-title-scroll` (90px): the app adds `.is-titled`, and the title moves over `dur-medium-1` with `motion-move`. After `layout-reader-hide-scroll` (120px) more the app adds `.is-hidden`: the bar slides up its own height over `dur-medium-2` while the 3px progress thread stays at the top edge. The first scroll up clears `.is-hidden`, so the bar returns already showing the title. The bar can hide only below that line, not near the top. The app may drive the same two properties from the scroll fraction (Flutter: `reader_bar.dart`, shaped with `motion-scroll`). Reduced motion: the states switch at once.

### Pull to advance (not built in CSS)
Gesture gap 150ms, drop back after 450ms (spring back 190ms), open after 280ms, rise 480ms, arrow pop 260ms, label fade 150ms, resistance .5, shaped with `motion-scroll`.

### Recipe values (R3-O21; generated into `PantasMotionRecipes`)
Literal values that live inside one named recipe. Flutter reads them from `PantasMotionRecipes`; nothing hard-codes them.

| Recipe | Selector | Duration | Delay | Curve | Flutter field |
|---|---|---|---|---|---|
| Reveal mark pop | `.opt.is-right .opt__mark`, `.opt.is-wrong .opt__mark` | 560ms | 0 | `motion-move` | `revealMark` |
| Right-answer ripple (`accent` at `opacity-ripple` 0.38 to 0) | `.opt.is-right.is-ripple::after` | 700ms | 50ms | ease-out `(0,0,.58,1)` | `ripple` |
| Question panel children in | `.qpanel > *` | 220ms | 120ms | `motion-fade` | `panelChildrenIn` |
| Question panel children out | `.qpanel:not(.is-open) > *` | 160ms | 0 | `motion-fade` | `panelChildrenOut` |
| Skeleton out | `.skel-out` | 200ms | 0 | `motion-fade` | `skeletonOut` |
| Skeleton in | `.skel-in` | 300ms | 60ms | `motion-fade` | `skeletonIn` |
| View swap out | `.swap-out` | 100ms | 0 | `motion-fade` | `swapOut` |
| View swap in | `.swap-in` | 180ms | 60ms | `motion-move` | `swapIn` |
| Pane out | `.pane-out` | 90ms | 0 | `motion-fade` | `paneOut` |
| Pane in | `.pane-in` | 170ms | 70ms | `motion-move` | `paneIn` |
| Check draw | `.draw-check` | `dur-slide` | 120ms | `motion-draw` | `checkDraw` |
| Tassel swing | `.tassel-swing` | 2200ms | 400ms | `(.36,.07,.19,.97)` | `tassel` |

### Tooltip and SearchOverlay (round 3)
Tooltip: fades in over `dur-short-2` (`motion-fade`) after `dur-tooltip` on hover, at once on focus. SearchOverlay: the scrim fades in over `dur-flip`; the panel rises like a dialog (`pn-dialog`, `dur-medium-3`, `motion-house`); on the phone it rises as a sheet (`dur-long-1`, `motion-slide`). Reduced motion: both fade in place.

### Question list on narrow tiers (ruling 5)
Tablet: the panel slides in from the left over `dur-nav-panel` with `motion-move`, and its scrim (a real element under the header, `.scrim--qpanel`) fades in over `dur-switch` with `motion-fade`; closing plays both in reverse (`.is-exiting` on the scrim). The explanation drawer below 1134 does the same with `.scrim--xpl` (ruling 8, R4-O03). Phone: the same panel rises from the bottom as a sheet over `dur-nav-panel`. Wide is unchanged (MK_NavMotion), and the floating bar re-centers on the question column in sync.

## Rules

1. The phone is the reference. Where the phone animates, the wide web animates.
2. Never remove approved motion. A sweep item or a performance finding is not approval. State which motion a change removes and quote the approval.
3. Map each curve one to one. Do not fold one curve into another without a Decisions line.
4. The screen at rest is the last frame. Nothing loops in the app unless a board marks it continuous.
5. Show state changes in place: rings fill, checks pop, rows fold. Never fade or reload a whole screen to show a change.
6. Animate only what the board animates. No extra page transitions, fades or hero moves.
7. Press feedback on every tappable. Hover feedback on every hoverable with a fine pointer.
8. No shake on an answer option or the floating bar after a wrong answer. The Mock finale's deduction shake is approved choreography and stays.
9. Counting numbers use a cubic ease-out over the same length as their ring or bar and land exactly.
10. Confetti only for a new best mock score.
11. Generic motion uses tokens. A literal is allowed only inside a named choreography or recipe above, which lists it.

## Reduced motion

With `prefers-reduced-motion: reduce` (Flutter: `MediaQuery.disableAnimationsOf(context)` returns `PantasDurations.reduced`):
- No spatial motion: every translate, scale and rotate goes. Sliding markers and thumbs jump. The switch thumb lands in its final position. The arrow nudge and the press scale are removed.
- Overlays (dialog, drawer, sheet, popover, toast) and entering blocks appear in place with a `dur-short-2` fade.
- Color and opacity changes stay, at `dur-short-2` or less. They are not spatial motion (Apple HIG: replace motion with dissolves).
- Fills (rings, gauges, bars, chart bars), pops and check draws show the end state at once. Exits fade out too (the FigureViewer and SearchOverlay included, R3-A05).
- Every loop stops: spinner, skeleton pulse, blink, hourglass tip, sand. Nothing strobes. The spinner shows a static arc and a visible "Loading" label, so a stopped spinner never looks hung.
- Choreographies settle to their end frame.
- State stays readable without motion: a busy button keeps its verb, the right answer keeps its check.
