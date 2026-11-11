SegmentedControl switches between 2 to 4 views, or sorts and filters a list, with a thumb that slides to the chosen segment.

## When to use
- Use it for a view switch (Day, Week, Month) or a sort or filter (Weakest, Strongest, A to Z).
- Don't use it to move between pages (use SidebarNav or TabBar). Don't use more than four segments.

## Anatomy
- Track `fill`, radius `radius-sm` (8), padding 2. CHANGE: the radius was 10.
- Segments: min height 34 (phone 32), radius `radius-sm`, label `web-label` 14, padding 6 12, never wrapping. The track is an inline grid of equal columns as wide as the widest label ("6 Months" stays on one line); `.seg--fill` stretches it to its container. When equal columns do not fit the container, the columns share it by label width before the track scrolls (D193). Selected: thumb `surface-segment-on` with `elev-segment`, label 600; unselected labels 500 (R3-O20, CHANGE D133).
- Unselected labels use `text-on-fill`. CHANGE: they were `text-secondary` (4.3:1 on `fill`).
- No inline `--n` or `--i` (ruling 6): the thumb reads the count and the selected segment from the markup through `:has()` (2 to 5 segments). Without `:has()`, or with more than 5, the thumb hides and the selected segment draws the thumb color itself (no slide).
- Track `.seg__track` (R4-O10): the thumb and the buttons sit in it, inside `.seg`, which scrolls when the track overflows (320, or 200% text with "6 Months"); the thumb is sized from the track, so it stays on its segment while the track scrolls. Markup without the track still works, but its thumb drifts when it scrolls. The track carries `role="none"`, so the tabs stay owned by the tablist.

## Variants and props
- View switch: `role="tablist"`, buttons `role="tab"` with `aria-selected` and `aria-controls`, panels `role="tabpanel"`. Roving tabindex.
- Sort or filter: `role="radiogroup"`, buttons `role="radio"` with `aria-checked`. Roving tabindex.
- `seg--phone` makes the segments 32px. The consumer provides the labels, the panels and the handler.
- `.seg--fill`: full width of its container (phone sheets, filters on the phone). On a narrow screen a track wider than its container scrolls inside itself; focus rings sit inside the segment.

## Markup
With the track (R4-O10).

```html
<div class="seg" role="tablist" aria-label="View">
  <div class="seg__track" role="none">
    <span class="seg__thumb" aria-hidden="true"></span>
    <button type="button" class="seg__btn" role="tab" id="vw-t0" aria-selected="false" aria-controls="vw-p0" tabindex="-1">Day</button>
    <button type="button" class="seg__btn" role="tab" id="vw-t1" aria-selected="true" aria-controls="vw-p1" tabindex="0">Week</button>
    <button type="button" class="seg__btn" role="tab" id="vw-t2" aria-selected="false" aria-controls="vw-p2" tabindex="-1">Month</button>
  </div>
</div>
```

## States
- Hover: an `opacity-hover` `text-primary` wash and `text-primary` label. Selected: `text-primary` on the thumb.
- Disabled: `text-disabled`, skipped by the arrow keys. Keyboard focus: 2px `accent` outline.
- Touch (`pointer: coarse`): the buttons are 44px high, with a transparent block border so the drawn segment stays 34px (phone 32) inside the 38px well (phone 36), drawn by `.seg__track::before`. The hit area is real, not an overflowing pseudo-element, because the scrolling `.seg` would clip one (D190). Use the markup with `.seg__track`.

## Keyboard
- Tab reaches the selected segment only. Left and Right (or Up and Down) move and select the next enabled segment, wrapping.
- Home and End select the first and the last segment.
- One Tab stop (R4R-O02): only the selected tab has `tabindex="0"`; the others carry `tabindex="-1"`, and the arrow keys move between them (roving tabindex).

## Accessibility
- Name the group with `aria-label`. Use tabs only when each segment controls a panel.
- Selection shows by the thumb and by weight (600 against 500) as well as color.
- Segments are 44px targets on touch, inside the scroller (D190).

## Motion
- The thumb glides over 240ms (`dur-medium-1`, `motion-move`). Reduced motion: it jumps.

## Flutter
- Desktop: WebSegmentedControl (`web/web_components.dart`). Phone: SegmentedSwitch (`components/segmented_switch.dart`). Size every segment to the widest label (IntrinsicWidth), never wrap.
- Reads `fill`, `surface-segment-on` [`segmentOn`], `elev-segment` [`elev-segment`], `text-on-fill` [`onFillLabel`], `text-primary` [`label`], `text-disabled` and `web-label` (500 unselected, 600 selected).

## Do
- Keep labels to one or two words.
- Use the right role for the job: tabs for views, radios for sort and filter.

## Don't
- Don't use more than four segments.
- Don't use it for navigation between pages.

## Placement
Above the content it filters. Left-aligned on desktop, full width on the phone.

## Tokens used
`border-focus`, `accent`, `space-2`, `radius-sm`, `fill`, `surface-segment-on`, `elev-segment`, `dur-medium-1`, `motion-move`, `space-6`, `space-12`, `text-on-fill`, `type-web-label`, `tracking-web-label`, `dur-short-2`, `motion-fade`, `text-primary`, `opacity-hover`, `text-disabled`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: radius 10 to 8; unselected label `text-on-fill`; two ARIA recipes with keyboard script; touch hit area. Changed in 3.1: no inline `--n`/`--i`; equal natural-width segments; unselected 500 (ruling 6, R3-O20, R3-A10). Changed in 3.2: `.seg__track` keeps the thumb on its segment when the track scrolls (R4-O10). Changed in 3.4.0: real 44px touch buttons inside the scroller (D190). Changed in 4.0.2: columns share a too-narrow row by label width before scrolling (D193).
