SelectableTile is a large button the learner turns on or off, with a name, a short line below it, and an optional tag. Use it for exams and for study days.

## When to use
- Use it to choose from two to eight options that need a name and a line of detail, such as an exam.
- Use the day tile for the seven days of the week.
- Don't use it for a long list (use Select). Don't use it for a setting that applies at once (use Switch).

## Anatomy
- Exam tile: minimum height 64px (`size-opt-min`), radius 14 (`radius-lg`), padding 12px 14px 12px 16px (CHANGE: 11 to 12, 2px grid, R2-O08), gap 2px. `surface-card`.
- Name 16/600. Sub line 13/400 `text-secondary`. Content starts at the top of the tile (`justify-content: flex-start`), so tiles in a row start their text on one line whatever their height (D182). An optional `.tag` sits on the tile's top edge, centered on it and 16px from the left (G17), as the plan tile does. It is in flow, in a header slot at the top of the tile (D190, amends D182): its negative margin cancels the tile's top padding plus half the tag, and the title starts at the larger of the tile padding and half the tag plus 2px. At default text the title starts at the padding as before; at 200% text the title stays below the tag. When any tile in a grid has a tag, the untagged tiles reserve the same slot (a `::before` spacer), so every title in a row starts on one line. The grid adds half the tag's height above itself.
- Rest: 1px `border-control` ring (`border-ring`; CHANGE D158, ruling 4: was transparent), so a tile shows on a card as well as on the page (3.4:1 on the card, 3.2:1 on the page). Hover: 1px `text-secondary` ring (the control hover rule; was 1.5px `divider-strong`).
- Selected: `accent-tint` fill and a 2px `accent` ring (`border-ring-selected`). The sub line becomes `text-on-tint-secondary`.
- Day tile: height 76px (`size-tile-day`), content centered. Weekday 12/600 `text-secondary` on top, then the count 20/700 tabular. Seven columns in weekday order, each at least 44px (`size-target-touch`). The gap is 10px and shrinks toward 4px before the row scrolls (D190); at a row narrower than about 320px the row scrolls sideways and the app scrolls the selected day into view (`scrollIntoView({ inline: 'nearest' })`, as WeekStrip does). At 358px each day is 44px wide with an 8.3px gap.
- Selected day tile: `accent-fill`, text `on-accent`, no ring.
- Disabled: `fill` background, `text-disabled`, no ring.
- CHANGE: the board drew the day tile with radius 16. It is folded to `radius-lg` (14).

## Variants and props
- `.choice-grid` (columns of at least `size-tile-min`, 10rem: 160px at default text, gap 10px) of `button.choice-tile`. In rem, so at large text the grid drops to one column instead of running off the screen (ruling 2).
- `.choice-grid--days` with `.choice-tile--day`: DOM order is `.choice-tile__sub` (weekday) then `.choice-tile__name` (count, such as "1h").
- Exam tile: `.choice-tile__name`, `.choice-tile__sub`, optional `.tag`.
- Multi select: each tile has `role="checkbox"` and `aria-checked`, inside `role="group"`.
- Single select: each tile has `role="radio"` and `aria-checked`, inside `role="radiogroup"`.
- The consumer provides the names, the lines, the group label and the selected tiles.
- Plan tile (usage gap 24, ST_ProPMA and ST_Paywall): `.choice-tile--plan` with `.choice-tile__name` (`web-link` 15/600), `.choice-tile__price` holding `.choice-tile__amount` (`web-h2` 26/700, tabular) and `.choice-tile__period` (`web-sub`; `text-on-tint-secondary` when selected), an optional per-month line (`.choice-tile__sub`), and an optional solid `.tag` on the top edge ("7 DAYS FREE"); a 1px `divider` edge at rest as drawn. `.choice-grid--plans`: three per row on wide screens, one per row on the phone; `.choice-tile--wide` (Season Pass) spans the row. Radius 14 (CHANGE D148: the board draws 16).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="choice-grid" role="radiogroup" aria-labelledby="ct-ex">
  <button type="button" class="choice-tile" role="radio" aria-checked="true" tabindex="0">
    <span class="choice-tile__name">UPCAT</span>
    <span class="choice-tile__sub">University of the Philippines</span>
    <span class="tag">Recommended</span>
  </button>
  <button type="button" class="choice-tile" role="radio" aria-checked="false" tabindex="-1">
    <span class="choice-tile__name">CSE Professional</span>
    <span class="choice-tile__sub">Civil Service Commission</span>
  </button>
  <!-- 1 more -->
  <button type="button" class="choice-tile" role="radio" aria-checked="false" tabindex="-1">
    <span class="choice-tile__name">ACET</span>
    <span class="choice-tile__sub">Ateneo de Manila University</span>
  </button>
</div>
```

## States
- Rest, hover, pressed (scale 0.98), keyboard focus, selected, selected with focus, disabled.
- Keyboard focus: 2px outline, offset 2px. On a selected tile the outline is `text-primary`, so focus never looks like selection.
- Empty: nothing selected. Error: show a `.field__msg--error` line under the group, for example "Pick at least one day."

## Keyboard
- Multi select: Tab moves between tiles. Space or Enter turns a tile on or off.
- Single select: Tab enters the group once. Arrow keys move the choice and select it. Space selects the focused tile.

## Accessibility
- Name the group with a visible label (`aria-labelledby`).
- Use `aria-checked` on every tile. Don't rely on tint alone: the 2px ring and the state in the accessible name also show it.
- Give day tiles a full name: "Monday, 1 hour".
- Exam tiles are at least 64px high and as wide as a grid column (160px at default text); day tiles are at least 44px wide and 76px high. All pass the 44px target size (D190).

## Motion
- Ring and fill change in 150ms (`dur-short-2`, `motion-fade`). Press scales in 180ms.
- Reduced motion: no scale. Color fades may stay.

## Flutter
- Tag slot (D190): put the tag in the first row of the tile's `Column`, offset up by the tile's top padding plus half the tag's height with a `Transform.translate` and a `SizedBox` whose height is `max(0, tagHeight / 2 + 2 - padding)`, and give untagged tiles in the same row a `SizedBox` of the same height. `tagHeight` is the tag's measured height (`textScaler.scale(12) * 1.3 + 4`). Day row: a `SingleChildScrollView` (horizontal) of seven 44-wide-or-wider tiles with a gap of `clamp((width - 7 * 44) / 6, 4, 10)`; `Scrollable.ensureVisible` on the selected day.
- Build SelectableTile on a Material and InkWell with the shape from `radius-lg`. Use Semantics with `checked` and `inMutuallyExclusiveGroup` for single select.
- Reads `surface-card` [`surface`], `accent-tint`, `accent`, `accent-fill`, `on-accent`, `text-secondary` [`secondaryLabel`] and `divider` [`separator`].

## Do
- Keep the name to a few words and put the detail in the sub line.
- Preselect the most likely tile only when you are sure.

## Don't
- Don't use more than one tag in a tile.
- Don't use a tile for a destructive choice.

## Placement
Onboarding steps, under a label, in a grid of two columns on wide screens (480px column). Study days: one row of seven.
- On the page or inside a Card: the rest ring keeps a tile visible on either surface (ruling 4). For more than eight choices in groups use grouped checkboxes (Checkbox, ruling 5).

## Tokens used
`border-focus`, `accent`, `text-primary`, `size-tile-min`, `space-10`, `space-2`, `size-opt-min`, `space-12`, `space-14`, `space-16`, `radius-lg`, `surface-card`, `border-ring`, `border-control`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `text-secondary`, `accent-tint`, `border-ring-selected`, `type-web-title-sm`, `tracking-web-title-sm`, `type-web-small`, `tracking-web-small`, `text-on-tint-secondary`, `space-4`, `size-tile-day`, `space-8`, `type-web-tag`, `tracking-web-tag`, `type-web-h3`, `tracking-web-h3`, `accent-fill`, `on-accent`, `space-6`, `space-18`, `divider`, `type-web-link`, `tracking-web-link`, `type-web-h2`, `tracking-web-h2`, `type-web-sub`, `tracking-web-sub`, `fill`, `text-disabled`

## Status
Draft (new in 2.0). Source: the onboarding day tile (`.dy`, 76 high, radius 16 folded to 14) and exam tile (`.ex`, minimum 64, padding 11/14/11/16). Changed in 3.0: padding on the 2px grid; name style `web-title-sm`. Changed in 3.1: plan tile and plan grid (usage gap 24). Changed in 3.2: rest ring `border-control`, grid minimum in rem (rulings 2 and 4). Changed in 3.3: tiles top-align their content and the tag sits on the top edge (D182). Changed in 3.4.0: the tag is in flow in a header slot, so it never covers the title at large text; the day row keeps 44px columns and scrolls on narrow phones (D190).
