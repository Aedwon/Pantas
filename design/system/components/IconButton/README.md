IconButton is a square, icon-only button with a rounded-rectangle highlight. Use it for close, menu and toolbar actions.

## When to use
- Use it where the icon is known by everyone: close, search, menu, flag.
- Don't use it when the action needs a word. Use Button.
- Don't use it for an action that is the main task of a page.

## Anatomy
- Icon 20px (18px at 32), stroke 1.8, color `text-secondary`. The teal variant uses `accent`.
- Sizes: 44 default (`size-icon-btn`), 40 `icon-btn--md` (`size-icon-btn-md`), 32 `icon-btn--sm` (`size-icon-btn-sm`).
- Radius follows the rule: 44 and 40 use `radius-md` 12. 32 uses `radius-sm` 8.
- CHANGE: the 32px button moved from radius 12 to 8, so it follows the rule.
- The highlight is a rounded rectangle, never a circle.

## Variants and props
- `icon-btn` with the size classes above. `icon-btn--accent` for a teal icon.
- `aria-pressed` makes it a toggle. A pressed toggle is teal, and its glyph changes too (D190): the flag is the outline glyph when off and the filled glyph when on. Put `.glyph-fill-on` on the flag `svg` (`[aria-pressed="true"] .glyph-fill-on` fills it with `currentColor`); color is never the only cue (WCAG 1.4.1).
- The consumer provides the icon and a required `aria-label`.

## States
- Hover: an `opacity-hover` (0.08) overlay of the icon color as a rounded rectangle; the icon turns `text-primary`. Teal turns `accent-hover`.
- Pressed: scale 0.97. Keyboard focus: 2px `accent` outline, 2px offset.
- Disabled: `text-disabled`, no hover, no press.
- Toggle on: icon color `accent` and, for the flag, the filled glyph (D190); `aria-pressed="true"`.

## Keyboard
- Tab focuses the button. Enter and Space activate it.

## Accessibility
- Give every icon button an `aria-label` that names the action ("Close lessons"). Update the label if the action changes.
- A toggle uses `aria-pressed`. Do not change the label when it toggles. The on state shows by a second cue besides color: the flag changes from outline to filled (D190).
- The 44 and 40px buttons reach a 44px target on touch. The 32px button adds a padded hit area of 44px.
- On pointer-only desktop bars, 32px is the preferred size and 24px is the minimum.
- With a fine pointer, an icon-only button shows a Tooltip with its name and shortcut (R3-O10).

## Motion
- Press scales 0.97 over `dur-short-1` and releases over `dur-short-3`. The hover fill fades over `dur-short-2` (`motion-fade`).
- Reduced motion: no scale. The fill fades stay at 150ms.

## Flutter
- Build it on IconButton with `constraints` of 44, 40 or 32 and a RoundedRectangleBorder from `radius-md` or `radius-sm`.
- Reads `text-secondary`, `text-primary`, `accent` and `text-disabled`. The flag toggle swaps the outline glyph for the filled glyph when on (Phosphor `flag` regular to `flag` fill), plus `accent`.

## Do
- Always give it an `aria-label`.
- Use it in notice headers (close) and drawer headers.

## Don't
- Don't make it round or a pill.
- Don't put it on a tinted tile inside a card.
- Don't use it for red destructive actions without a confirm Dialog.

## Placement
Right end of a header or toolbar. Phone: 44x44 targets, back at the left, Done or Edit as a text button at the right.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.icon-btn--sm::after`: inset -6px (touch hit area)

## Tokens used
`border-focus`, `accent`, `size-icon-btn`, `radius-md`, `text-secondary`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `size-icon-btn-md`, `size-icon-btn-sm`, `radius-sm`, `opacity-hover`, `text-primary`, `accent-hover`, `dur-short-1`, `text-disabled`, `figure-on-viewer`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: 32px radius 8 (was 12), `text-secondary` token, coarse-pointer hit area, toggle state. Changed in 3.1: Tooltip pairing (R3-O10). Changed in 3.2: hover wash from `opacity-hover` (R4-O05). Changed in 3.4.0: the flag toggle fills when on (D190).

