Tag is a small round label that names a status: Up next, Recommended, Not started, Paused.

## When to use
- Use it to name the status of one item in a row or a title.
- Don't use it as a button or a filter chip. Don't use it for a Pro feature (use ProMark).

## Anatomy
- Text 12/600, padding 2px 8px, `radius-full`. A tag may be round because it is not a button.
- Tint (default): `accent-tint` and `accent-tint-text`. Solid: `accent-fill` and `on-accent`. Gray: `fill` and `text-on-fill`.
- Warning (`tag--warning`): `warning-tint` and `warning-tint-text` (orange, board `.tago`). Use it for caution, never for a wrong answer.
- In a row title, a tag gets a 6px gap and a 2px baseline lift automatically.

## Variants and props
- `.tag`, `.tag--solid`, `.tag--gray`, `.tag--warning`.
- The consumer provides the text and the status rule.

## States
- One state. A tag is not interactive: no hover, pressed, focus or disabled state.

## Keyboard
- A tag takes no keys and is not focusable.

## Accessibility
- The text names the status, so color is never the only cue.
- A tag in a row is read after the title. Keep the words short and in plain English.
- Contrast: every tone holds 4.5:1 in both themes.

## Motion
- None.

## Flutter
- No shared widget exists in the inventory. Build a Tag from a DecoratedBox with a Text (12px, weight 600).
- Reads `accent-tint`, `accent-tint-text`, `accent-fill`, `on-accent`, `fill`, `text-on-fill` [`onFillLabel`], plus the warning pair.

## Do
- Use two words at most, in Title Case.
- Use gray for neutral status and tint for "go here".

## Don't
- Don't use it as a button; it is not interactive.
- Don't add a red tag. Red is for wrong or destructive.
- Don't use a tag as an eyebrow, category or brand label above a heading (D188). A tag names the status of one item.

## Placement
Right end of a ListRow, or right after a row title. A tag is not a button, so the round shape is allowed.

## Tokens used
`space-6`, `space-2`, `space-8`, `radius-full`, `accent-tint`, `accent-tint-text`, `type-web-tag`, `tracking-web-tag`, `accent-fill`, `on-accent`, `fill`, `text-on-fill`, `warning-tint`, `warning-tint-text`, `space-4`, `space-10`, `space-16`

## Status
Approved (from the boards); changed in 2.0: added `tag--warning`; inline title spacing. Changed in 3.3.2: the pill shape is confirmed for status tags (D188).
