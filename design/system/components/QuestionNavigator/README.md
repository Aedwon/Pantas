QuestionNavigator is the grid of numbered chips that shows which questions are answered, flagged or locked, and opens any question. A side panel holds the grid in a mock exam.

## When to use
- Use it in mock exams and long quizzes where the learner may jump between questions.
- Don't use it for a single step count such as "4 of 10" (that is the FloatingBar counter, which opens this grid). Don't use it for lesson progress (use ProgressBar).

## Anatomy
- Grid `.qnav`: 6 columns of 36px chips (`size-qnav`), gap `space-8` (8).
- Chip `.qnav__q`: round, 13/600, tabular numbers. Blank: `surface-card` fill, 1.5px `border-control` ring (3.4:1 light, 5.1:1 dark), number in `text-secondary`. CHANGE (R2-O07): the ring was `divider-strong` (1.5:1), and blank versus answered is the main information in a timed mock.
- Answered: `divider` fill, no ring, number in `text-primary`. Ring present versus absent is the shape cue; the state is also in the name. Current: 2.5px (`border-ring-current`) `text-primary` ring, number `web-field-label` at 700.
- Locked: transparent, 1px `fill` ring, number in `text-disabled`.
- Flagged: an 11px (`size-flag-dot`) `accent` dot at the top right (offset -2px) with a 2px `surface-card` edge. It combines with any state.
- Panel `.qpanel`: 300 wide (`layout-qpanel`), padding 24 24 120, gap 16, `bg-page`, `z-sticky`. The heading "Questions" and an icon button sit on one row.
- Edge tab `.qpanel-tab`: 34 wide (40 on hover), 46 high (`size-btn-bar`), radius 0 12 12 0 (`radius-md`), `surface-card`, `elev-popover`.
- Content area `.qpanel-shift`: left padding 340 when the panel shows, 40 when hidden.
- Source: the mock exam boards `.q` chips and MK_NavMotion. The answered fill (#E3E3E8) is `divider`.

## Variants and props
- `.qnav__q` plus `.is-answered`, `.is-current` with `aria-current="step"`, `.is-flagged`, `.is-locked` with `disabled`.
- Order is fixed: `.qpanel`, then `.qpanel-tab`, then `.qpanel-shift`, which holds the FocusHeader, the stage and the floating bar dock. The sibling rules depend on it, and the header inside `.qpanel-shift` keeps Close and the clock clear of the panel (ruling 5).
- Tiers (ruling 5), same markup: wide (1024 and up) the panel pushes the content and the floating bar re-centers on the question column (usage gap 8); 600 to 1023 the panel is a left drawer under the header with a scrim that leaves the header clear, so Close and the clock stay visible (inert while the list is open, ruling 8); under 600 it is a bottom sheet that stops below the header (no edge tab; the counter opens it). The panel is open only with `.is-open` on every tier (R4-O17): the app adds it on first load at 1024 and up and mirrors `aria-expanded` of the toggles; a rotation or resize across 1024 keeps the state.
- Grid rows: `.qnav[role="grid"]` holds one `.qnav__row[role="row"]` per six chips, each row a six-column grid (not `display: contents`, so the row role survives in every WebView; R4-O18), each chip a `role="gridcell"` button (R3-O14).
- Toggle `.is-open` on `.qpanel`. Also set `inert` on the panel while it is closed.
- The consumer provides the question list, each state, and what Enter opens.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<aside class="qpanel is-open" id="qpanel" aria-label="Questions panel">
  <div class="qpanel__head">
    <h2 class="web-h3">Questions</h2>
    <button type="button" class="icon-btn icon-btn--md" aria-label="Hide questions" aria-expanded="true" aria-controls="qpanel">
      <svg aria-hidden="true">...</svg>
    </button>
  </div>
  <div class="qnav" role="grid" aria-label="Questions">
    <div class="qnav__row" role="row">
      <button role="gridcell" type="button" class="qnav__q is-answered" aria-label="Question 1, answered" tabindex="-1">1</button>
      <button role="gridcell" type="button" class="qnav__q is-answered" aria-label="Question 2, answered" tabindex="-1">2</button>
      <!-- 3 more -->
      <button role="gridcell" type="button" class="qnav__q is-answered" aria-label="Question 6, answered" tabindex="-1">6</button>
    </div>
    <div class="qnav__row" role="row">
      <button role="gridcell" type="button" class="qnav__q is-answered" aria-label="Question 7, answered" tabindex="-1">7</button>
      <button role="gridcell" type="button" class="qnav__q is-answered" aria-label="Question 8, answered" tabindex="-1">8</button>
      <!-- 3 more -->
      <button role="gridcell" type="button" class="qnav__q is-flagged" aria-label="Question 12, not answered, flagged" tabindex="-1">12</button>
    </div>
    <!-- 1 more -->
    <div class="qnav__row" role="row">
      <button role="gridcell" type="button" class="qnav__q" aria-label="Question 19, not answered" tabindex="-1">19</button>
      <button role="gridcell" type="button" class="qnav__q" aria-label="Question 20, not answered" tabindex="-1">20</button>
      <!-- 3 more -->
      <button role="gridcell" type="button" class="qnav__q is-locked" aria-label="Question 24, locked" tabindex="-1" disabled>24</button>
    </div>
  </div>
  <p class="web-small">
    Filled: answered. Ring: current. Dot: flagged...
  </p>
</aside>
```

Below 1024 the same panel is a modal dialog (ruling 8). The app sets the roles at the tier change and inserts the scrim when it opens the list:

```html
<div class="focus">
  <aside class="qpanel is-open" id="qpanel" role="dialog" aria-modal="true" aria-labelledby="qpanel-h">
    <div class="qpanel__head">
      <h2 class="web-h3" id="qpanel-h">Questions</h2>
      <button type="button" class="icon-btn icon-btn--md" aria-label="Hide questions" aria-expanded="true" aria-controls="qpanel">...</button>
    </div>
    <div class="qnav" role="grid" aria-label="Questions">...</div>
  </aside>
  <div class="scrim scrim--qpanel"></div>
  <button type="button" class="qpanel-tab" aria-label="Show questions" aria-expanded="true" aria-controls="qpanel">...</button>
  <div class="qpanel-shift" inert>
    <!-- FocusHeader, stage, floating bar: inert while the list is open; the header stays visible -->
  </div>
</div>
```

Behavior below 1024:
- Open (the counter or the edge tab): add `.is-open`, insert `.scrim.scrim--qpanel` after the panel, set `inert` on `.qpanel-shift`, move focus to the current chip, set `aria-expanded="true"` on both toggles.
- Tab and Shift+Tab stay inside the panel. Arrow keys move in the grid.
- Esc, the Hide button or a click on the scrim closes it: remove `.is-open`, add `.is-exiting` to the scrim and remove it after its fade (`dur-switch`), clear `inert`, return focus to the control that opened the list.
- Choosing a question closes the list and moves focus to the question stem.
- At 1024 and up: remove `role`, `aria-modal` and the scrim, give the `aside` an `aria-label`, and keep the open state.

## States
- Rest: blank chip. Hover (pointer only): scales to 1.08, no color change.
- Pressed: no extra change. Keyboard focus: 2px `accent` ring, offset 2px.
- Selected: the current chip, with the heavy `text-primary` ring.
- Disabled: locked chips, faded and not focusable.
- Panel hidden: the panel slides out, the tab slides in at the left edge.

## Keyboard
- Tab enters the grid once, on the current chip (roving tabindex). Tab again leaves the grid.
- Left and Right move one chip. Up and Down move one row (6). Home and End go to the first and last open chip.
- Enter or Space opens the focused question. Arrows skip locked chips.
- The panel button and the edge tab are normal buttons: Enter or Space toggles. Focus moves to the other button.

## Accessibility
- The chips form an APG grid: `role="grid"` named "Questions", `role="row"` per six chips, `role="gridcell"` buttons, so screen readers announce the 2D arrow keys (R3-O14).
- Mark the current chip with `aria-current="step"`. Never rely on the ring or the dot alone.
- Announce an opened question in a `role="status"` region.
- The panel toggle has `aria-expanded` and `aria-controls`. Name them "Hide questions" and "Show questions".
- Touch: every chip gets a 44px hit area on coarse pointers (the visible circle stays 36px). Desktop pointer targets are 36px.
- Each chip names its number and state, updated on change: "Question 12, blank, flagged" or "Question 3, answered". The current chip adds `aria-current="step"`.
- Modal on narrow tiers (ruling 8): below 1024 the question list and below 1134 the explanation drawer take `role="dialog"`, `aria-modal="true"` and a label (the app switches the roles at the tier change; on wide screens they are an `aside` and a region); the page behind is `inert` (the header stays visible but inert); focus moves into the panel and returns to the opener; Esc closes; the scrim is a real element the app inserts with the panel (`.scrim.scrim--qpanel`, starting under the header; `.scrim.scrim--xpl` over the window) that fades in over `dur-switch`, closes the panel on click and locks the page scroll. No spread-shadow scrim (R4-O03).

## Motion
- The panel moves 460ms (`dur-nav-panel`) with `motion-move`. Its content fades out over 160ms and in over 220ms after 120ms.
- The content area changes its left padding over the same 460ms and curve, so both move together.
- The edge tab springs in after `dur-wait` (300ms) with `motion-spring`.
- Reduced motion: the panel and content reach the end state at once.
- Narrow tiers (ruling 5): the tablet drawer slides in from the left and the phone sheet rises, both over `dur-nav-panel` with `motion-move`; the scrim fades with them.

## Flutter
- Build it from QuestionGridSheet (`new_design/`). The phone shows the same grid in a bottom sheet; the tablet in a left drawer (ruling 5).
- Reads `surface-card`, `border-control`, `divider`, `text-primary`, `text-secondary`, `text-disabled`, `fill`, `accent`, `border-ring-strong`, `border-ring-current`, `size-qnav`, `layout-qpanel`, `dur-nav-panel`, `motion-move` (R3-O14: `divider-strong` is no longer read).

## Do
- Give every chip a text name for its state.
- Keep the grid at 6 columns so numbers line up from one panel to the next.
- Hide the panel with `inert` so hidden chips are not focusable.

## Don't
- Don't color chips green or red for right and wrong during a quiz. The grid shows progress, not scores.
- Don't use the flag dot without the word "flagged" in the chip name.
- Don't give every chip a tab stop. Use one roving stop.

## Placement
In a mock exam, the left panel beside the question. In a quiz, it opens from the FloatingBar counter. On the phone it opens in a sheet.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.qpanel`: padding 120px (MK_NavMotion bottom reserve)
- `.focus:not(.focus--split) .qpanel`: padding 34px (MK_NavMotion bottom reserve)

## Tokens used
`border-focus`, `accent`, `space-8`, `size-qnav`, `radius-full`, `surface-card`, `border-ring-strong`, `border-control`, `text-secondary`, `type-web-field-label`, `tracking-web-field-label`, `dur-short-2`, `motion-fade`, `motion-move`, `divider`, `text-primary`, `border-ring-current`, `fill`, `text-disabled`, `layout-qpanel`, `space-24`, `space-16`, `bg-page`, `dur-nav-panel`, `z-sticky`, `space-40`, `size-btn-bar`, `radius-md`, `elev-popover`, `dur-nudge`, `dur-reveal`, `motion-spring`, `dur-wait`, `layout-focus-head`, `z-modal`, `elev-drawer`, `space-20`, `radius-lg`, `surface-modal`, `elev-sheet`, `layout-focus-head-phone`, `size-target-touch`, `size-flag-dot`

## Status
Draft (new in 2.0). Source: the MK boards (`.q` chips, 36px circle, 13/600, 2.5px current ring, 11px flag dot) and MK_NavMotion (460ms). The panel heading row has no class in `bundle.css`, so the preview lays it out with a plain flex row. Changed in 3.0: blank ring `border-control` (R2-O07); state in each chip name. Changed in 3.1: APG grid roles, one name rule, panel tiers, bar re-centering, stroke token (R3-O14, ruling 5, R3-O22). Changed in 3.2: one state `.is-open`, rows as grids, the modal contract and a real scrim below 1024 (ruling 8, R4-O17, R4-O18).

