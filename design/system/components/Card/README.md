Card is the base surface: a flat block on the page background that holds rows, content or a call to action.

## When to use
- Use it to group related content on `bg-page`: a list of rows, a stat, a call to action.
- Don't put a card inside a card. Use `.divider` or a `surface-inset` band.
- Don't make the whole card a click target when it holds other controls.

## Anatomy
- Surface `surface-card`, radius `radius-xl` 18, clipped overflow. No shadow in light. Dark adds a 1px inner edge (`edge-card`) on top of the content.
- Padding comes from the content: `card--pad` gives 20px (`space-20`), `card--pad-lg` gives 24px (`space-24`). A card of rows has none.
- `.cta-card`: padding 20 (`space-20`), gap 8, so Home cards share one 20px inset with `card--pad`, the card footer and the stat list. CHANGE: padding 24 to 20 (D183); earlier, top padding 26 to 24 (R2-O08). Title `web-h3-lg` (22/700), body `web-body` in `.text-secondary`, actions in `.btn-row` at the right end with a 16px top margin.
- `.divider`: a 0.5px `divider` hairline between sections of one card. Use `<hr class="divider">`.
- `.card__clip` clips flush content (rows) so focus rings of inner controls are not cut. Without it, keep 4px clearance.
- Heading block `.card__head` (Custom Quiz "Your Quiz"): a title (`web-h3`) and one line under it (`web-sub`, `text-secondary`), 4px apart.
- Promo card text (R4-O04, CHANGE D167): inside `.card--promo`, secondary text and fine print take `text-on-tint-secondary` (4.6:1 on the tint end, 5.4:1 on the card end), because the gradient ends in `accent-tint` where the CTA and its fine print sit.

## Variants and props
- `card--selected`: `accent-tint` fill and a 2px `accent` ring. Supporting text inside it (`web-sub`, `web-small`, `web-lead`, `web-caption`, `web-eyebrow`, `.text-secondary`, row subtitles and values, the card footer text) uses `text-on-tint-secondary`, because `text-secondary` is 4.4:1 on `accent-tint` (D190, CHANGE). Primary text stays `text-primary`.
- `card--link`: for a card that is one link. Use `a.card.card--link`. It has no underline and takes the focus ring.
- `card--floating`: `elev-bar` and a 1px `edge-bar` edge, for a card over other content.
- `card--open`: overflow visible, for a card that hosts a popover.
- The consumer provides the content and, for a link card, the destination.
- Gradient cards (ruling 10): `.card--promo` (wide Pro card, `surface-card` into `accent-tint` at 135deg, ST_ProPMA and ST_Paywall); `.card--hero` (phone Pro hero: `hero-start`, `hero-mid` 40%, `hero-end` at 160deg, `on-hero` text, radius 22, padding 26 by 22, with `.hero-list` feature rows 15/500 and 21px `on-hero-secondary` icons); `.card--topic-done` (RD_TopicDone) and `.card--share` (deferred). Titles may sit anywhere on a teal gradient (large text, 3:1); body text keeps to its lower 60% (5.3:1 and up).
- Card footer caption `.card__foot-text` takes a 12rem basis, so a short caption and its button share a 435px column (usage gap 17).

## Markup
A call-to-action card; a plain card is `section.card` with its content.

```html
<section class="card cta-card">
  <h3 class="web-h3-lg">Set Your Exam Date</h3>
  <p class="web-body text-secondary">Add the date and Pantas shapes your plan arou...</p>
  <div class="btn-row">
    <button type="button" class="btn btn--neutral">Not Now</button>
    <button type="button" class="btn btn--primary">Add Exam Date</button>
  </div>
</section>
```

## States
- Rest: `surface-card`. Hover (link card): `surface-hover` over 150ms. Selected: `accent-tint` and the ring.
- Keyboard focus (link card): 2px `accent` outline, 2px offset. A selected card takes a `text-primary` focus ring, because the selected ring is already accent.
- A card with secondary controls is not a link. It uses one primary link inside, and the other controls keep their own targets.
- Disabled: not a card state. Disable the controls inside.

## Keyboard
- A link card takes Tab and Enter. A plain card takes no focus; the controls inside take focus in reading order.

## Accessibility
- A link card is one `<a>`. Its text is the accessible name, so keep it short.
- Do not nest links or buttons inside a link card.
- A selected card in a choice group is a radio or a toggle (see SelectableTile). Do not rely on the tint alone.
- Give a card of rows a heading above it or an `aria-label` on a `<section>`.

## Motion
- Hover and selected fills fade over 150ms (`dur-short-2`, `motion-fade`).
- Reduced motion: the fade stays at 150ms.

## Flutter
- Build the surface as a Material with the shape from `radius-xl` and the edge as a foreground border.
- Reads `surface-card` [`surface`], `edge-card` [`cardEdge`], `accent-tint`, `accent` and `fill`.

## Do
- Put rows directly in a card with no extra padding.
- Keep one radius (18) for every card.
- Right-align the actions of a call-to-action card.

## Don't
- Don't put a card inside a card.
- Don't draw an icon on a tinted tile inside a card. Icons sit in their own color.
- Don't make the whole card a click target when it holds a button.

## Placement
On `bg-page`, 28px apart in one column (`layout-section-gap`) or in columns (the same `layout-section-gap`).
- A pair in a `.cta-card` stacks with the main action on top below 1024 (ruling 9, the reverse stack of `.btn-row`).

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.card--hero`: padding 26px, padding 22px (ST_ProPMA phone hero padding 26px 22px)

## Tokens used
`border-hairline`, `divider`, `border-focus`, `accent`, `text-primary`, `surface-card`, `radius-xl`, `edge-card`, `space-20`, `space-24`, `accent-tint`, `dur-short-2`, `motion-fade`, `border-ring-selected`, `edge-bar`, `elev-bar`, `surface-hover`, `space-8`, `space-16`, `radius-2xl`, `hero-start`, `hero-mid`, `hero-end`, `on-hero`, `topic-done-end`, `share-end`, `space-10`, `type-phone-subhead`, `tracking-phone-subhead`, `on-hero-secondary`, `space-12`, `text-on-tint-secondary`

## Status
Approved (from the boards); changed in 2.0: `card--pad-lg`, `.cta-card`, link card renders as a link with the focus ring, `.divider`, `.card__clip`, selected focus ring `text-primary`. Changed in 3.0: call-to-action card top padding 24 (R2-O08). Changed in 3.1: gradient cards from stop tokens (ruling 10); footer caption basis 12rem. Changed in 3.2: `.card__head`; promo text on the tint (R4-O04); pairs reverse-stack below 1024 (ruling 9). Changed in 3.3: `.cta-card` padding 24 to 20 (CHANGE D183, board G23). Changed in 3.4.0: supporting text on the selected card (D190).
