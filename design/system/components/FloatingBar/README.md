FloatingBar is the bar at the bottom of a question: the counter, a flag, a hint and the action.

## When to use
- Use it on the quiz and mock question screens, desktop and phone.
- Don't use it for a general page action bar. Use PhoneFrame's bottom action or a Card footer.

## Anatomy
- Min height 64 (`size-bar`), radius `radius-bar` (32), `surface-card`, 1px `edge-bar` ring plus `elev-bar`.
- Counter: 46px high (`size-btn-bar`), radius `radius-full`, "3 of 10" 15/600 tabular, never wraps, opens the question list. It is a pill, as the approved boards draw it (D187).
- Flag IconButton: 44px (`size-icon-btn`). CHANGE: it was 46.
- Hint: 13px `text-secondary`, centered (`text-primary` in a result). Action: `btn--bar`, 46px, pill (`radius-full`, D187). A key hint follows the label on desktop only.
- Right: `accent-bar` fill and an `accent` ring at `opacity-bar-ring` (0.26). Wrong: `danger-bar` fill and a `danger` ring at `opacity-bar-ring` (R4R-O03).

## Variants and props
- `fbar--fill`: width 100%, max 720px (`layout-bar-max`). `fbar--wide`: max 1080px. `fbar--phone`: full width.
- `.fbar-dock` places the bar: desktop 28px from the bottom (`layout-bar-bottom`). `.fbar-dock--phone` sits at max(16px, safe area + 8px).
- On phones narrower than 400px the flag moves to the question header (`.fbar__flag` is hidden). CHANGE, flagged for Aedwon: it follows the approved phone bar layout so "Not this one" fits on one line.
- Copy: right "Correct", wrong "Not this one". The explanation carries the "Correct answer" label.
- The consumer provides the counter, the hint text, the action and the state.
- Stacked (ruling 5): at 1.5x text and above, or in a dock narrower than 17.5em, the hint takes its own line above the actions; the actions stay right-aligned with the main action last; the bar becomes a rounded rectangle (`radius-xl`). Automatic inside `.fbar-dock` (a container query); `.fbar--stack` forces it (Flutter: `textScaler` above 1.5). No icon-only buttons.
- Flag under 400px: `.fbar__flag` hides and `.fbar__flag-alt` shows at the right end of the question header (`.page-head--question .page-head__trail`), not in FocusHeader (ruling 9, D71).
- Hint copy by state: before a pick "Pick one answer"; after a pick, before Check: "Check when you are ready" (usage gap 14); right "Correct"; wrong "Not this one".
- Mock bar (R3-O04, usage gap 11): the counter, the hint and the main action only; the flag lives in the question header at every width. After an answer is picked (no reveal in a mock) the hint reads "Saved on this device" and the action is Next.
- In a mock with the question list open the bar re-centers on the question column (the dock moves with the panel over `dur-nav-panel`, MK_NavMotion; usage gap 8).
- Size: buttons and the counter use `size-btn-bar` (46).
- Phone (ruling 3): `.fbar-dock--phone` is sticky at the end of the phone screen, so the stacked bar at large text takes its own height and never covers the last option.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="fbar fbar--fill">
  <button type="button" class="cnt" aria-label="Question 3 of 10, open the question list">
    3 of 10
    <svg aria-hidden="true">...</svg>
  </button>
  <button type="button" class="icon-btn fbar__flag" aria-label="Flag this question" aria-pressed="false">
    <svg aria-hidden="true">...</svg>
  </button>
  <span class="fbar__hint" role="status">Pick one answer</span>
  <button type="button" class="btn btn--bar btn--primary" disabled>
    Check
    <span class="kbd">Enter</span>
  </button>
</div>
```

## States
- Neutral, right, wrong. Check is disabled until an answer is picked.
- Counter hover: an `opacity-hover` wash. Pressed: scale 0.97. Keyboard focus: 2px `accent` outline.

## Keyboard
- Enter runs the main action (Check, then Next). The hint shows the key on desktop.
- Tab reaches the counter, the flag and the action in that order.

## Accessibility
- The hint is `role="status"`, so "Correct" or "Not this one" is announced once. AnswerOption does not announce the result.
- The result also shows as a word, a tint and a ring: never color alone.
- The flag has `aria-label` and `aria-pressed`; when on it turns `accent` and its glyph fills (outline to filled, `.glyph-fill-on`, D190). The counter's name says what it opens.
- The counter, flag and action are at least 44px high.

## Motion
- Color fades 250ms (`dur-fade`) back to neutral and 300ms (`dur-flip`) to a result. Reduced motion: instant.

## Flutter
- Desktop: WebBottomBar with WebBarState (`web/web_components.dart`). Phone: FloatingBar (`components/floating_bar.dart`).
- Reads `surface-card` [`surface`], `accent-bar` [`floatingRight`], `danger-bar` [`floatingWrong`], `accent`, `danger` [`destructive`], `text-primary` [`label`] and `text-secondary` [`secondaryLabel`].
- Move the phone flag to the question header under 400 logical pixels.

## Do
- Disable Check until an answer is picked; show the key hint on desktop.
- Say "Correct" or "Not this one" in the hint, not only by color.

## Don't
- Don't stretch the bar beyond 720px (1080px on wide pages).
- Don't wrap the counter.

## Placement
Centered, 28px above the bottom edge, in focus mode. Phone: 16px inset, above the safe area.

## Tokens used
`border-focus`, `accent`, `layout-bar-bottom`, `size-bar`, `space-12`, `layout-bar-bottom-phone`, `space-8`, `layout-reserve-bar-phone`, `space-6`, `radius-bar`, `surface-card`, `edge-bar`, `elev-bar`, `dur-fade`, `motion-fade`, `z-nav`, `accent-bar`, `opacity-bar-ring`, `dur-flip`, `danger-bar`, `danger`, `space-4`, `type-web-small`, `tracking-web-small`, `text-secondary`, `text-primary`, `size-btn-bar`, `space-16`, `radius-lg`, `radius-full`, `type-web-link`, `tracking-web-link`, `dur-short-2`, `dur-short-3`, `motion-move`, `opacity-hover`, `dur-short-1`, `layout-bar-max`, `layout-bar-max-wide`, `radius-xl`, `space-24`, `dur-nav-panel`, `layout-gutter-phone`, `layout-qpanel`, `space-10`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: flag 44px; status hint; counter never wraps; flag in header under 400px; phone dock. Changed in 3.0: stacked variant for large text and narrow docks (ruling 5); flag slot in the question header; hint copy per state. Changed in 3.1: mock bar recipe without the flag (R3-O04); re-centers with the question list. Changed in 3.2: stale size name fixed (R3-O19). Changed in 3.3.1: the counter and the action are pills again (D187).

