Tooltip is a short label that names an icon-only control or shows a cut title in full, with its keyboard shortcut.

## When to use
- Use it on icon-only controls with a fine pointer: FocusHeader Close and Report, the quiz bar flag IconButton, FigureViewer zoom, "Hide questions", the Ctrl K hint; and on a cut title (`WebRow` `tooltipWhenCut`) on Settings and Record.
- WeekStrip days (D186): the status of a day ("Done", "Partly done", "No study", "Planned", "Today"). It is a status the learner can also get from the dot shape and the day name, not something to read to act.
- Don't use it for anything a learner must read to act (use a visible label or a Notice). Don't put links or buttons in it.

## Anatomy
- `.tooltip` in a `.tooltip-anchor` (position relative): `toast-bg` with `toast-text`, `elev-toast`, `web-caption` (12/400), padding 4 by 8, radius 8 (`radius-sm`), at most 240 wide (`size-tooltip-max`), 8px from the anchor, centered, `z-tooltip`.
- An 8px invisible bridge between the tooltip and the anchor keeps it open while the pointer crosses.

## Variants and props
- Top (default), `.tooltip--bottom` when there is no room above.
- Outside a scroll container (D186): when the anchor sits in a clipping scroller (the WeekStrip days), the tooltip is a child of the nearest non-clipping ancestor and the consumer sets its position with the data property `--x` (unitless pixels from the left edge of that ancestor; `.tooltip[style*="--x"]` reads `calc(var(--x) * 1px)`; no inline `left`, D189).
- Text: the control's name plus its shortcut in brackets: "Flag (F)", "Close (Esc)".
- The consumer provides the text and shows or hides it (`hidden`).

## States
- Hidden, shown. No hover state of its own.

## Keyboard
- Focus on the anchor shows it at once; Esc hides it without moving focus; Tab away hides it.

## Accessibility
- `role="tooltip"`, referenced by the anchor's `aria-describedby`. The anchor keeps its `aria-label`; the tooltip supplements it.
- Exception (D186): when the anchor's accessible name already contains the tooltip text, the tooltip is `aria-hidden="true"` with no `role` and no `aria-describedby`, so a screen reader does not say it twice. The WeekStrip days work this way (each name ends with its status). The pointer and keyboard rules below still apply; the tooltip is for sighted users only.
- WCAG 1.4.13: dismissible (Esc), hoverable (the pointer may move onto it), persistent (it stays until the pointer or focus leaves).
- Forced colors (Windows high contrast): the shadow disappears, so the tooltip gets a 1px `CanvasText` border like the other floating surfaces (D189).
- Never on touch (`hover: none` hides it): touch users read the label in the control or the screen title.

## Motion
- Fades in over `dur-short-2` (`motion-fade`) after `dur-tooltip` (500ms) on hover; at once on focus. Hover and focus are tracked apart; the tooltip stays while either holds, and the hover zone covers the anchor, any padding between the anchor and the tooltip, and the tooltip itself (D190). Reduced motion: the same fade.

## Flutter
- `Tooltip` with `waitDuration` `dur-tooltip`, `decoration` `toast-bg` and radius `radius-sm`, `textStyle` `web-caption` in `toast-text`, `preferBelow: false`; `TooltipTriggerMode.manual` on touch platforms (no long-press tooltip).
- Reads `toast-bg`, `toast-text`, `elev-toast`, `web-caption`, `radius-sm`, `size-tooltip-max`, `z-tooltip`, `dur-tooltip`, `dur-short-2`.

## Do
- Keep it to a few words plus the shortcut.

## Don't
- Don't use it as the only name of a control. Don't show it on touch.

## Placement
Above the anchor, 8px away; below when there is no room.

## Tokens used
`space-8`, `z-tooltip`, `size-tooltip-max`, `space-4`, `radius-sm`, `toast-bg`, `toast-text`, `elev-toast`, `type-web-caption`, `tracking-web-caption`, `dur-short-2`, `motion-fade`

## Status
Draft (new in 3.1, R3-O10). Values chosen (no board draws a tooltip). New tokens: `size-tooltip-max`, `dur-tooltip`; `z-tooltip` existed with no consumer. Changed in 3.2: the mock flag is a labeled button (D138), so it is not listed (R4-O13). Changed in 3.3: a status use on the WeekStrip days with `aria-hidden` (D186). Changed in 3.4.0: placement by `--x`; forced-colors border (D189).
