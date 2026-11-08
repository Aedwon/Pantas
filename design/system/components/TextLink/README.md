TextLink is secondary navigation: teal text with an arrow, never a box.

## When to use
- Use it to go to another place: "See all questions", "View full plan".
- Don't use it for an action that changes data. Use Button.
- Don't box, tint or outline it. A boxed route is a Button.

## Anatomy
- Label 15/600 (`.9375rem`), color `accent`. Gap to the arrow `space-6`.
- Arrow: 16px, stroke 2.2, `link__arrow`. The link has no underline at rest.
- The focus shape is `radius-xs` 5, so the ring hugs the text.
- Phone uses the same size, 15/600.

## Variants and props
- `a.link` with a trailing `.link__arrow` svg. The consumer provides the label and the destination.
- A `<button class="link">` is allowed for an in-page route that is not a real URL, such as opening a drawer.
- The consumer may place it right-aligned in a section header (see SectionHeader).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<a class="link" href="#">
  See all questions
  <svg class="link__arrow" aria-hidden="true">...</svg>
</a>
```

## States
- Rest: `accent`. Hover: color `accent-hover` (150ms) and the arrow moves 4px right (200ms, `motion-move`).
- Pressed: scale 0.97 (120ms down, 180ms up).
- Keyboard focus: 2px `accent` outline, 2px offset.
- Disabled: `aria-disabled="true"`, color `text-disabled`, no arrow motion, no pointer events.

## Keyboard
- Tab focuses the link. Enter activates it. Space does not (it is a link).

## Accessibility
- Make the label say where the link goes. Avoid "Click here" and a bare "More".
- Teal on `surface-card` and on `bg-page` holds 4.5:1 in light and dark.
- On touch the link gets a padded 44px hit area (`pointer: coarse`).
- The arrow is decorative (`aria-hidden`). The label carries the meaning.

## Motion
- The arrow nudges 4px over `dur-nudge` (200ms, `motion-move`).
- Reduced motion: the arrow does not move. The color change stays.

## Flutter
- Reuse PantasTextLink (a Text.rich with an inline arrow icon). Wrap it in an InkWell with `radius-xs` for the focus and press shapes.
- Reads `accent` and `text-disabled` [`disabledActionLabel`]. Derive the hover color from `accent`.

## Do
- Put it inside the card it belongs to, under the rows.
- Keep the label to two to four words.

## Don't
- Don't wrap it in a box, tint or border.
- Don't use it for an action that changes data.
- Don't put two links side by side with arrows. Use one.

## Placement
Left-aligned under the content it extends, or at the right end of a section header. Phone: the same, 15/600.

## Tokens used
`border-focus`, `accent`, `space-6`, `type-web-link`, `tracking-web-link`, `radius-xs`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `dur-nudge`, `accent-hover`, `dur-short-1`, `text-disabled`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: token renames (`radius-xs`, `dur-nudge`), disabled uses `aria-disabled`, coarse-pointer hit area.
