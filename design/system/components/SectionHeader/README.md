SectionHeader names a block of content and can offer one link to see more. A group label and a group note do the same job for a settings card.

## When to use
- Use `.sec-head` above a section that holds several cards or rows, on Home and other pages, when the block has a "see all" link. The title is the eyebrow.
- The first card of a column on Home is the other case (D184): its header sits inside the card, `.sec-head` with a `web-h3` title in an `h3`, and it uses the card's own 20px inset. Use the inside-card form only for that card, so both columns start on one line. Everything else keeps the eyebrow above (Columns README, patterns).
- Use `.group-label` above a card in Settings, and `.group-note` for a helper line under it.
- Don't use it as a page title (use PageHeader). On the phone, a grouped list takes its own header (`.group__head`).

## Anatomy
- `.sec-head`: flex row, space between, baseline aligned, wraps when narrow. Padding 0 4px 8px (`space-4`, `space-8`). CHANGE: 9 to 8 (2px grid, R2-O08).
- Title: `web-eyebrow` (13/600, +0.02em, uppercase, `text-secondary`) in an `h2`. Phone: `phone-section-header` (13/600).
- Inside a card (D184, D189): a `.sec-head` that is a direct child of `.card` or `.card--pad` has no side padding (CHANGE: title and link were 24px in, now on the 20px inset). Title: `web-h3` (20/700, `text-primary`) in an `h3`, not the eyebrow. Bottom padding stays 8px.
- Link: TextLink, 15/600 `accent`, with a 16px arrow (`link__arrow`), gap 6px.
- Phone: `.sec-head--phone`, padding 0 16px 7px (`layout-gutter-phone`).
- `.group-label`: padding 0 16px 8px, an eyebrow above a desktop card.
- `.group-note`: padding 8px 16px 0, 13/400, `text-secondary`, under a card.

## Variants and props
- `.sec-head` and `.sec-head--phone`. The link is optional.
- `.group-label` and `.group-note` are paddings. Put the type class (`web-eyebrow`) on the label.
- The consumer provides the title text, the link text and its target.
- Section action (Custom Quiz "Select All"): an action that changes the section itself is one small teal tertiary Button (`.btn--tertiary.btn--accent.btn--sm`) in the right slot; navigation stays a TextLink. Never both.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="sec-head">
  <h2 class="web-eyebrow">Today</h2>
  <a class="link" href="#">
    View Full Plan
    <svg class="link__arrow" aria-hidden="true">...</svg>
  </a>
</div>
```

## States
- Link rest: `accent`. Hover: `accent-hover`, arrow nudges 4px. Pressed: scale 0.97. Keyboard focus: 2px `accent` outline, offset 2px.
- The title and the note are text. They have no states.

## Keyboard
- Tab focuses the link. Enter opens it.

## Accessibility
- Use a real heading (`h2` or `h3`) for the title so a screen reader can jump between blocks.
- The link text must make sense alone: "View Full Plan", not "More".
- Keep one `h1` on the page.
- Mark the arrow `aria-hidden`.
- The link keeps a 44px touch target on touch screens.

## Motion
- The link arrow nudges 4px right on hover over 200ms (`dur-nudge`, `motion-move`). Reduced motion: no nudge.

## Flutter
- Build SectionHeader as a Row of an eyebrow Text (PantasType eyebrow style, uppercase) and a PantasTextLink.
- Reads `text-secondary` [`secondaryLabel`] and `accent`.
- Group label and note are Padding around a Text.

## Do
- Write the title in sentence case in the source and let the style uppercase it.
- Keep the link text in Title Case: "View Full Plan".

## Don't
- Don't add a second link or an icon button to the header.
- Don't use a color other than `text-secondary` for the eyebrow.
- Don't put an eyebrow in a capsule, border or tint, and don't add a dot or icon to it (D188).

## Placement
Directly above the card or list it names, 8px above on desktop and 7px on the phone (the phone board value, a listed internal). The group note sits 8px under its card.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.sec-head--phone`: padding 7px (phone board (x241))

## Tokens used
`space-4`, `space-16`, `space-8`, `type-web-eyebrow`, `tracking-web-eyebrow`, `type-web-h3`, `tracking-web-h3`, `type-phone-section-header`, `tracking-phone-section-header`, `type-web-small`, `tracking-web-small`, `text-secondary`, `text-primary`

## Status
Draft (new in 2.0). Source: Home "TODAY ... View full plan" and Settings "BACKUP" label with the note "This is safe to share publicly.". Changed in 3.2: a section action button (usage gap 11). Changed in 3.3: the first card of a Home column holds its header inside the card (D184). Changed in 3.3.2: an eyebrow is never in a capsule (D188). Changed in 3.4.0: the inside-card form drops its side padding; the boundary between the two forms is stated (D189).

