LinkTile is a large tappable tile with an icon, a title and a chevron. It opens a related page.

## When to use
- Use it for a short set of two to four links to related pages, such as "More about you" on Home.
- Don't use it for a long list (use ListRow in a GroupedList). Don't use it for an action that changes data (use Button).

## Anatomy
- Card-like tile: `surface-card`, radius 18 (`radius-xl`), minimum height 60px, padding 18px 20px, gap 16px.
- Icon 20px, stroke 1.8, `accent`, bare (no tinted tile behind it).
- Title 17/400, `text-primary`, takes the free width and wraps.
- Chevron 16px, stroke 2.2, `icon-chevron`.
- 1px `edge-card` edge: transparent in light, visible in dark.
- CHANGE: the board drew radius 16. The system uses `radius-xl` (18) so tiles match cards.

## Variants and props
- `.link-tiles` is a grid: columns of at least 240px, gap 14px. Two tiles sit side by side on wide screens and stack on the phone.
- `a.link-tile` with `.link-tile__icon`, `.link-tile__t`, `.link-tile__cv`.
- The consumer provides the icon, the title and the target.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<a class="link-tile" href="#">
  <svg class="link-tile__icon" aria-hidden="true">...</svg>
  <span class="link-tile__t">How You Study</span>
  <svg class="link-tile__cv" aria-hidden="true">...</svg>
</a>
```

## States
- Rest: `surface-card`. Hover: `surface-hover`. Pressed: scale 0.98.
- Keyboard focus: 2px `accent` outline, offset 2px.
- There is no selected or disabled state. A tile you cannot open should not appear.

## Keyboard
- Tab moves between tiles. Enter opens the link.

## Accessibility
- Use a real link (`a` with `href`). The title is the accessible name.
- Mark icon and chevron `aria-hidden`.
- The tile is at least 60px high, which clears the 44px target.
- The hover fill is not the only cue: the chevron and the cursor show it is a link.

## Motion
- Hover color fades in 150ms (`dur-short-2`, `motion-fade`). Press scales in 180ms (`dur-short-3`).
- Reduced motion: no scale. Color fades may stay.

## Flutter
- Build LinkTile on a Material and InkWell with the card shape from `radius-xl`.
- Reads `surface-card` [`surface`], `edge-card` [`cardEdge`], `accent`, `icon-chevron` [`chevron`] and `text-primary` [`label`].

## Do
- Keep titles to two or three words.
- Use the same icon weight as the rest of the page (stroke 1.8).

## Don't
- Don't put the icon on a tinted tile.
- Don't add a subtitle or a tag. If the link needs more text, use ListRow.

## Placement
Under a SectionHeader on Home, full content width, two per row. On the phone, one per row with the 16px gutter.

## Tokens used
`border-focus`, `accent`, `space-14`, `space-16`, `space-18`, `space-20`, `radius-xl`, `surface-card`, `text-primary`, `type-web-row-title`, `tracking-web-row-title`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `edge-card`, `icon-chevron`, `surface-hover`

## Status
Draft (new in 2.0). Source: the Home "More about you" tiles. CHANGE: radius 16 to `radius-xl` 18.
