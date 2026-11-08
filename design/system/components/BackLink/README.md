BackLink returns to the parent page. It is a teal chevron and label above the page title, with a rounded highlight that reaches into the margin.

## When to use
- Use it on every page that has a parent, directly above the page title.
- Don't use it on a root page.
- Don't use it for a step inside a flow that has its own Back button (use Button).

## Anatomy
- Chevron 20px, stroke 2.2, then a 17/400 label in `accent`, 2px apart (`space-2`). Minimum height 40 (`size-back`).
- The highlight (hover and pressed) uses `radius-back` 11. It starts 14px left of the page edge.
- The chevron starts 6px left of the page edge. The gap to the title is 6px.
- Phone (`back--phone`): 44px high, no negative margin, padding 0 8px 0 4px, letter spacing -0.012em.
- `radius-back` is a single token for this control. Variant A is locked by Aedwon, so the radius does not follow the 8/12/14 rule.

## Variants and props
- `a.back` with a chevron svg and a label. Add `back--phone` for the nav bar.
- The consumer provides the parent name ("Study") or "Back" if the parent changes.

## States
- Hover: `accent` at `opacity-hover` (0.08), label turns `accent-hover`, chevron nudges 2px left.
- Pressed: scale 0.97. Keyboard focus: 2px `accent` outline, 2px offset.
- No disabled state. Remove the link if there is no parent.

## Keyboard
- Tab focuses the link. Enter activates it. Alt+Left (browser back) is not overridden.

## Accessibility
- The link text names the destination. Use `aria-label="Back to Study"` if the visible label is only "Back".
- The chevron is decorative (`aria-hidden`).
- On touch the link gets a padded 44px hit area (`pointer: coarse`).

## Motion
- The chevron nudges 2px left over `dur-nudge` (200ms, `motion-move`). The highlight fades over `dur-short-2`.
- Reduced motion: no nudge, no scale. The highlight color stays.

## Flutter
- Reuse BackChevron (`core/ui/components/back_chevron.dart`) for the glyph and wrap it in an InkWell with `radius-back`.
- Reads `accent`. Derive the hover color from it.

## Do
- Put it directly above the page title (6px gap) on every page that has a parent.
- Name the parent ("Study").

## Don't
- Don't draw a box or border around it at rest.
- Don't add it on a root page.
- Don't change `radius-back` to match other controls.

## Placement
Above the title in PageHeader. Phone: in the 44px nav bar at the left (`back--phone`).

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.back`: margin-left -14px, padding 10px, padding 8px (back link A (locked))

## Tokens used
`border-focus`, `accent`, `space-2`, `size-back`, `radius-back`, `type-web-row-title`, `tracking-web-row-title`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `dur-nudge`, `opacity-hover`, `accent-hover`, `dur-short-1`, `size-btn`, `space-8`, `space-4`, `type-phone-body`, `tracking-phone-body`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: `radius-back` token, coarse-pointer hit area. Variant A remains locked. Changed in 3.2: hover wash from `opacity-hover` (R4-O05).

