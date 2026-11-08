FocusLayout is the page frame for a quiz, mock exam or assessment. It removes the sidebar and the tab bar so the learner sees only the question.

## When to use
- Use it for any screen where the learner answers questions in a row.
- Don't use it for normal pages (use AppShell). Don't use it for lessons (they keep the shell).

## Anatomy
- `.focus`: a flex column on `bg-page`, positioned so the bar can sit inside it. There is no sidebar.
- Header: FocusHeader, 64 high (`layout-focus-head`), padding 0 by 20.
- Stage `.stage`: centered, wraps, gap 40, padding 56 top, 40 sides, 140 bottom (`space-56`, `space-40`).
- Question column `.qcol`: 720 wide (`layout-qcol`), 600 while the explanation shows (`layout-qcol-narrow`). Gap between stem and options 28 (`space-28`).
- Explanation column: 440 (`layout-xpl`). With it, the stage gap is 14.
- Floating bar `.fbar-dock`: centered, 28 above the bottom edge (`layout-bar-bottom`). The bar is 64 high (`size-bar`), radius 32 (`radius-bar`), maximum 720 (`layout-bar-max`), 1080 on wide pages (`layout-bar-max-wide`).
- The bar holds the counter (`.cnt`), the hint (`.fbar__hint`, `role="status"`) and the main action, `btn--bar` with a `.kbd` key hint.
- Use `.fbar-dock--contained` only inside a framed preview. In the app the dock is fixed to the window.

## Variants and props
- Picking: the options are a radio group. The bar is neutral and the action is Check.
- Revealed: the options are read only, the bar is `is-right` or `is-wrong`, and the action is Next.
- Explanation open: add `.is-narrow` to the question column and add the `.xpl` column.
- The consumer provides the question, the options, the hint text and the action label.
- Passage items: `.stage--passage` with `.passage-col` (Passage) then `.qcol`. See Passage.
- Below 1134px (`bp-focus-split`) the explanation `.xpl` becomes a 440px drawer from the right, built in CSS (R2-O25).
- Set `--reader-scale` on `.focus` to apply the lesson text scale to the stem, options, explanation and passage (R2-O02).
- Below 1134px (R3-O03) the explanation is a modal drawer: a real scrim element over the page (`.scrim--xpl`, ruling 8), focus trapped, and its own footer `.xpl__foot` (the counter at the left, Next at the right, `btn--primary`); the floating bar's main action hides while it is open. Put `.xpl__foot` as the last child of `.xpl`; it shows only in drawer mode.
- Reserves (ruling 3): the stage bottom padding is `layout-reserve-bar` (8.75rem), so it grows with text.
- Mock (ruling 5): `.qpanel`, `.qpanel-tab`, `.qpanel-shift` (the header, the stage and the bar dock inside it). See QuestionNavigator for the panel tiers.
- Under 600 (R4-O08): `.focus` swaps the type below 1024 but keeps the wide geometry (stage sides, option padding, the explanation drawer). Phone screens use the phone variants (`.fbar-dock--phone`, `.opt--phone`, `.xpl-phone`) until the quiz migration adds the swaps; the FocusHeader already serves every width (ruling 7).
- Passage reserves (R4-O07): the passage column, the question and the explanation keep `layout-reserve-bar` plus the safe area above the floating bar, in rem, so it grows with text.

## Markup
The page root; see FocusHeader, FloatingBar and QuestionNavigator for their parts.

```html
<div class="focus focus--split">
  <header class="focus-head">
    <button type="button" class="icon-btn" aria-label="Close quiz">
      <!-- content -->
    </button>
    <div class="focus-head__title">Mathematics · 4 of 10</div>
    <button type="button" class="icon-btn" aria-label="Report a problem">
      <!-- content -->
    </button>
  </header>
  <div class="stage">
    <div class="qcol">
      <!-- content -->
    </div>
  </div>
  <div class="fbar-dock fbar-dock--contained">
    <div class="fbar">
      <!-- content -->
    </div>
  </div>
</div>
```

## States
- Bar states follow FloatingBar: neutral, right (`accent-bar`), wrong (`danger-bar`).
- Check is disabled until the learner picks an answer.
- The stage has no hover or pressed state of its own.

## Keyboard
- Tab order: Close, Report, the options (one stop), counter, action.
- Arrow keys move between options. Enter presses Check or Next, and the `.kbd` hint shows the key.

## Accessibility
- The question stem is the page `h1`.
- The hint is a `role="status"` region. It says "Correct" or "Not this one" so the result is not color alone.
- Keep the bar last in reading order. Leave 140px under the stage so it never covers an option.
- Below 1134px the explanation is a dialog Drawer: Esc closes it and focus returns to the bar action.
- The explanation drawer is modal below 1134px: labelled by its heading, focus trapped, Esc closes it and returns focus to the bar; Next in its footer is reachable inside the trap.
- Modal on narrow tiers (ruling 8): below 1024 the question list and below 1134 the explanation drawer take `role="dialog"`, `aria-modal="true"` and a label (the app switches the roles at the tier change; on wide screens they are an `aside` and a region); the page behind is `inert` (the header stays visible but inert); focus moves into the panel and returns to the opener; Esc closes; the scrim is a real element the app inserts with the panel (`.scrim.scrim--qpanel`, starting under the header; `.scrim.scrim--xpl` over the window) that fades in over `dur-switch`, closes the panel on click and locks the page scroll. No spread-shadow scrim (R4-O03).

## Motion
- None.

## Flutter
- Use WebBottomBar and FloatingBar for the bar, and WebQuizQuestion for the stage. Pages sit in PantasPage with WebLayoutTheme.
- Take 720, 600, 440, 140 and 28 from WebTokens.

## Do
- Keep the bar centered on the question column.
- Leave the bottom 140px of the stage free for the bar.
- Switch to the Drawer below 1134px.

## Don't
- Don't show the sidebar or tab bar in focus mode.
- Don't stretch the bar past 720 (1080 on wide pages).
- Don't make the bar full width on desktop.

## Placement
The whole page. FocusHeader at the top, the stage in the middle, the bar floating at the bottom.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.focus:not(.focus--split) .qpanel`: padding 34px (MK_NavMotion bottom reserve)

## Tokens used
`layout-bar-bottom`, `size-bar`, `space-12`, `layout-bar-bottom-phone`, `space-8`, `layout-reserve-bar-phone`, `z-nav`, `space-24`, `dur-nav-panel`, `motion-move`, `layout-gutter-phone`, `layout-qpanel`, `layout-focus-head`, `layout-reserve-bar`, `layout-qcol`, `layout-focus-head-phone`, `space-4`, `bg-page`, `space-40`, `space-56`, `space-28`, `dur-reveal`, `layout-qcol-narrow`, `space-14`, `z-modal`, `layout-drawer`, `space-20`, `elev-drawer`, `dur-long-1`, `motion-slide`, `border-hairline`, `divider`, `motion-fade`, `radius-lg`, `surface-modal`, `elev-sheet`

## Status
Draft (new in 2.0). Source: the focus-mode rules in the layout notes. The maximum bar width (`layout-bar-max`) has no class; the preview sets the width on the bar. Changed in 3.0: passage layout; the focus split is built in CSS; reader scale hook. Changed in 3.1: modal explanation drawer with a footer (R3-O03); rem reserve (ruling 3); mock panel markup (ruling 5). Changed in 3.2: modal contract with real scrims (ruling 8); passage reserves in rem (R4-O07); the one-markup scope (R4-O08).

