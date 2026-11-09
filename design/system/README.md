Pantas is a study app for Philippine college entrance exams (UPCAT, ACET, DCAT and others) and the civil service exam. It runs on the web (wide screens, 1440px reference) and on the phone (390px reference). One family of rules covers both: the phone is the reference for motion and for touch, the wide web is the reference for layout density.

## How to use this system

- `tokens.json` is the single source. The design-system page generates `tokens.css` from it: color and shadow tokens per theme under `:root, [data-theme="light"]` and `[data-theme="dark"]`, every other token under `:root`, `--font-sans` and `--font-serif` from `type.families`, and one class per type style (`.web-h1`, `.phone-body`). Never edit `tokens.css`.
- Load `tokens.css` first, then `components/bundle.css`. The bundle starts with a base layer (box-sizing, body font and colors, margin reset on every type class, `.sr-only`, `.truncate`, `.tnum`). Set `data-theme="light"` or `data-theme="dark"` on `html` or any ancestor.
- Load fonts from Google Fonts: `Geist` 400, 500, 600, 700 and `Source Serif 4` (optical size 8 to 60, weights 400 and 600). The sources hold no font files; see Decisions D91.
- Use the type classes for text, the component classes for controls and `var(--token)` for everything else. Never write a hex value. Use role tokens, never primitives (`gray-*`, `teal-*`, `red-*`, `amber-*`, `gold-*`).
- Components take their type from the styles: the bundle's generated block defines `--type-<style>` (a `font` shorthand) and `--tracking-<style>` for every style in `tokens.json`, and every component font is `font:var(--type-<style>)`. The build script (`tools/build_css.py --write`, shipped with the system; `--check` writes nothing and fails when the bundle has drifted, for CI) rewrites that block from `tokens.json`, so a type change reaches every component; it fails on any raw font size, off-grid spacing, literal color, type-class name reused as a layout class, container width that is not a token value, or pixel bottom reserve above a pinned bar. The other checks ship beside it: `tools/contrast.py` (the contrast table and the ground checks), `tools/flutter_names.py` (Dart identifiers and README references) and `tools/validate.py` (token names, aliases and the primitive distance rule). Flutter handoff lists each slot and its style.
- Inline styles carry only data and state custom properties, never styling (R3-O12): `--value` (0 to 100, the number printed beside it, on bars, rings, gauges and chart columns), `--reader-scale` (the lesson text scale, 1 to 2), `--dir` (view swap direction), `--zoom`, `--pan-x`, `--pan-y` (FigureViewer), `--h` (collapse start height), `--p` (slider fill), `--active-top` and `--active-height` (SidebarNav marker, measured by the app), `--i` (stagger order on `.rise` and `.stagger` children), `--x` (unitless pixels from the left edge of the positioned parent: the WeekStrip tooltip, which the app places over the hovered day; the CSS reads it as `calc(var(--x) * 1px)`; D189). Nothing else. Counts and selected indexes come from the markup (SegmentedControl, TabBar read them through `:has()`).
- The lesson text scale: set `--reader-scale` on any element (`.reader`, `.focus`, a question region). The bundle redeclares every scaled style on every element, so every component inside follows it: notes, examples, passages, answer options, explanations and display math (ruling 4). UI overlays (Dialog, Sheet, Popover, Toast, Tooltip, SearchOverlay) reset it to 1. A Sheet that shows lesson content (`.sheet--reader`, the phone passage) keeps it, and a Drawer never resets it; the app copies `--reader-scale` onto the overlay, because overlays mount outside the page root (ruling 11, R4-O01).
- One markup serves every width for `.shell` pages (ruling 11): build the page once with the wide classes inside `.shell`. Below 1024px the root swaps each wide style for its phone style (`phoneScale` in `tokens.json`), AppShell switches the navigation and the column, and rows stack at large text by themselves (ruling 12). The FocusHeader also serves 320 to 1440 from one markup (ruling 7): 64px from 600 up, 44px on phones at default text, growing with text (R4R-O01). Focus and reader pages (`.focus`, `.reader`) swap their type below 1024 but keep the wide geometry (stage sides, option padding, the explanation drawer): under 600 build them with the phone variants (`.fbar-dock--phone`, `.opt--phone`, `.xpl-phone`, `.reader--phone`) until the quiz migration adds the swaps (R4-O08). Use the other `phone-*` classes only in phone-only screens.
- Themes: `data-theme="light"` or `"dark"`, or no attribute to follow the OS (System). The bundle sets `color-scheme`, so scrollbars, autofill and native controls follow the theme.
- Version 4.0.1 (semver in `tokens.json`). See `governance.md` for the changelog and the deprecation rule.
- Read `motion.md` before animating, `patterns.md` before placing a button, a notice, an overlay or a loading state, and `governance.md` before adding or changing anything.
- Previews show forced states with `.is-hover`, `.is-active`, `.is-focus`, `.is-disabled`, `.is-busy`. Real `:hover`, `:active`, `:focus-visible` and `:disabled` behave the same.

## Principles

1. Calm, flat and quick. Cards are flat. Only things that float have a shadow. Nothing decorates.
2. Teal is the only brand color. Red marks only a destructive action or something the learner got wrong or entered wrong. Gold marks Pro.
3. Text actions and ghost (tertiary) buttons highlight as rounded rectangles, never pills. The one exception is the floating bar counter (`.cnt`), a ghost button that hovers as the pill the boards draw. Filled buttons are rounded rectangles too, with radius following height, except where the approved boards draw a pill: the floating bar's counter and action, the phone dialog pair and the compact pill (`btn--pill-sm`; D187, D189, D190). Status tags (Tag) stay pill-shaped: they name a status inside a row or tile. Decorative pills are never used: no outlined or tinted capsule around an eyebrow, category or brand label above a heading, with or without a dot or icon (D188).
4. On wide screens (1024px and up) buttons are natural width. Only the phone and tablet portrait fill the width.
5. Simple English. Short sentences. Title Case buttons. Say only what the app measured.
6. Never color alone: right and wrong carry an icon, errors carry an icon and a sentence, state carries a shape or a word.
7. Motion explains a change in place. The phone is the reference: where the phone animates, the wide web animates. Approved motion is never removed.
8. Both themes are first class. Light is the default.

## Color

### Tiers
- Primitives hold every hex once: `gray-*`, `teal-*`, `red-*`, `amber-*`, `gold-*`. The step is 1000 minus 10 times the CIE lightness, so a higher step is darker (`gray-0` is white, `gray-1000` black). Primitives may be named by value; nothing outside `tokens.json` uses them.
- A new primitive must differ from every primitive of its family by at least 2.0 CIEDE2000, or the role aliases the existing one (validator rule, R2-O21). Round 2 folded five invisible pairs and renamed `teal-550` to `gray-550` (a gray with a green cast).
- Roles alias primitives per theme and are named by job (`bg-page`, `text-secondary`, `border-control`). Components use roles only.
- Component roles exist only where a component needs its own override: `accent-bar`, `danger-bar`, `surface-modal`, `surface-modal-hover`, `scrim-search`, `kbd-on-fill`, `toast-*`, `switch-*`, `chart-*`, `figure-*`, `reader-*`, `liquid-*`, `hero-*`, `on-hero*`, `topic-done-end`, `share-end`. Where two roles share a value on purpose, one aliases the other (`accent-bar` dark is `{accent-tint}`).
- Alpha values (`scrim`, `scrim-search`, `edge-card`, `edge-bar`, `figure-scrim`, `kbd-on-fill`, `toast-action-hover`, dark `surface-modal-hover`) stay literal.
- Equal by coincidence, not aliases: `switch-off` and `fill-skeleton` (each usage line says so; the validator skips them). `chart-5` aliases `accent` on purpose (R3-O13).

### Roles and usage
- Ground: `bg-page` is the page. `surface-card` holds cards, dialogs, fields, bars. `surface-inset` is a footer band inside a card, always under a `divider` rule. `surface-hover` is the hover well of a row. `surface-modal` is the dialog and sheet surface (the card in light, one step up in dark). `surface-modal-hover` is the hover and press well inside a Dialog, Sheet or the SearchOverlay: in dark `surface-hover` equals `surface-modal`, so the bundle swaps it in (R3-O02). `fill` is a track, a disabled fill, a gray tag or the neutral button. `fill-skeleton` is for skeleton blocks only. In dark, a card carries a 1px `edge-card`; a floating bar carries `edge-bar`.
- Text: `text-primary` for body and titles. `text-secondary` for supporting text, placeholders, hints, tab labels, past dates and dimmed content. `text-on-fill` on `fill`. `text-on-tint-secondary` for secondary text on `accent-tint`. `text-disabled` for disabled labels only. `text-muted` (3.0.0) and `text-past` (4.0.0) are removed: use `text-secondary`.
- Lines and boundaries: `border-control` for the boundary of every control a learner must find (fields, search, select, white button, unchecked checkbox and radio, switch off ring, answer letter badge, not-started task marker). `divider` and `divider-strong` are decorative only: hairlines, separators, key-hint rings, hover rings.
- Icons: `icon-muted` for inactive icons, `icon-chevron` for row chevrons.
- Teal: `accent` for text, links, selected rings and the focus ring. `accent-fill` for filled controls with `on-accent` text. `accent-fill-hover` for their hover. `accent-hover` for the hover of teal text. `accent-tint` and `accent-tint-hover` for tonal fills with `accent-tint-text`. `accent-bar` for the floating bar after a right answer.
- Red: `danger` for rings, `danger-text` for text, `danger-text-hover` for its hover (dark `#F0807A`, so the label keeps 4.5:1 over its 8% wash in a dialog, R3-A07), `danger-fill` with `on-danger` for the destructive button and the wrong badge, `danger-tint` for the wrong-answer wash, `danger-bar` for the floating bar after a wrong answer, `danger-muted` for wrong answers in the UPCAT finale.
- Orange: `warning-text` for a heads-up (timer under five minutes, Unread, warning notice icon), `warning-tint` with `warning-tint-text` for the orange tag.
- Other: `pro` with `on-pro` (Pro mark), `switch-off`, `switch-thumb`, `toast-bg`, `toast-text`, `toast-action`, `scrim`, `scrim-search` (SearchOverlay, lighter), `liquid-start`, `liquid-end`.
- Gradients (ruling 10) are built from stop tokens, never from hex: the phone Pro hero is `hero-start` to `hero-mid` (40%) to `hero-end` at 160deg with `on-hero` text and `on-hero-secondary` icons (`.card--hero`); the topic-done card is `hero-start` to `topic-done-end` at 160deg (`.card--topic-done`); the share card is `hero-start` to `share-end` at 165deg (`.card--share`, sharing is deferred); the wide Pro card fades `surface-card` into `accent-tint` at 135deg (`.card--promo`); the liquid gauge is `liquid-start` to `liquid-end`. Flutter: `LinearGradient` with the same stops and angle.
- Chart: `chart-1` to `chart-5`, one teal ramp for accuracy. Lighter (light) or dimmer (dark) means lower. No per-subject hues.
- Figures and reader: `figure-*` stay white or printed in both themes. `reader-*` colors lesson text, solution panels, note cards and the common-mistake card (`reader-mistake*`, the lesson's "Traps to Watch For").

### Both themes
Light: page `#F5F5F7`, card `#FFFFFF`, text `#1D1D1F` and `#6E6E73`, teal `#0B7A68` (hover `#086A5A`), tint `#E4F1EE`, red `#D70015`, control boundary `#8A8A8E`.
Dark: page `#151515`, card `#1F1F1F` with a 1px edge `#2C2C2C`, raised `#2A2A2A`, fill `#303033`, divider `#303030`, text `#F5F5F5` and `#A3A3A3`, teal fill `#0F8571`, accent `#4CC3AC`, tint `#18332D`, tint text `#7FD8C6`, red `#C44A46` (rings) and `#E0706B` (text), control boundary `#8E8E93`.

### Rules
- Set text only on the grounds its token note names. Never set `text-secondary` on `fill` (use `text-on-fill`) or on `accent-tint` (use `text-on-tint-secondary`). On `accent-tint`, icons and chevrons use `accent-tint-text` (R2-O05: a selected row's value and chevron).
- The contrast script also walks the bundle: every color a component sets inside a block whose background is `accent-tint`, `danger-tint` or `fill`, and inside that block's children, is tested on that ground. It caught the selected-row value and chevron; it passes now. Round 3 adds two checks: a hover or press well must differ from the ground it sits on (it caught the dark dialog well, R3-O02), and a state wash is composited before its label is measured (the red ghost hover in a dialog, R3-A07).
- Data marks use `accent`; controls use `accent-fill` (R3-O07). Progress fills, slider fills, week dots and chart bars are marks, so in dark they are `#4CC3AC` (6.1:1 on `fill`), not the button teal.
- A filled control uses `accent-fill` with `on-accent` text in both themes. Never use `accent` as a fill.
- Red marks (a) a destructive action and (b) something the learner got wrong or entered wrong and can fix: a wrong answer, an invalid field, the common-mistake lesson card. Red never marks a system failure, a warning, a status, a neutral action or a decoration. The "Your exam" icon is teal.
- Dim readable content with color (`text-secondary`), never with opacity. Opacity (`opacity-disabled`) is only for disabled compound controls.
- State washes are tokens (R4-O05): a hover or press wash is the label color (or `text-primary`) at `opacity-hover` (0.08) over its ground, written `color-mix(in srgb, currentColor calc(var(--opacity-hover) * 100%), transparent)`; the inline spinner track is `opacity-spinner-track` (0.3), the floating bar's right and wrong ring `opacity-bar-ring` (0.26), the right-answer ripple start `opacity-ripple` (0.38) and the display-math scroll edge `opacity-scroll-edge` (0.18). No component writes a percentage, and the contrast script reads the same token.
- Inside the wide promo card (`.card--promo`) secondary text and fine print use `text-on-tint-secondary`, because the card ends in `accent-tint` where the CTA and its fine print sit (R4-O04).
- Accuracy uses discrete steps on every platform: below 45% `chart-1`, 45 to 54% `chart-2`, 55 to 64% `chart-3`, 65 to 74% `chart-4`, 75% and up `chart-5`. Never interpolate. Always print the number beside the bar.

### Contrast
Computed with WCAG 2 relative luminance from the resolved tokens (alpha colors flattened on their ground). Text needs 4.5:1 (3:1 at 24px and up). Icons, control borders, focus rings and marks that carry meaning need 3:1. A Fail row is either exempt (column Exemption) or tracked in Decisions to review.

| Pair | Light | Dark | Needs | Result | Exemption | Decision |
|---|---|---|---|---|---|---|
| Primary text on page (`text-primary` on `bg-page`) | 15.46 | 16.75 | 4.5:1 | Pass |  |  |
| Primary text on card (`text-primary` on `surface-card`) | 16.83 | 15.12 | 4.5:1 | Pass |  |  |
| Primary text on dialog and sheet (`text-primary` on `surface-modal`) | 16.83 | 13.17 | 4.5:1 | Pass |  | D114 |
| Primary text on fill (neutral button) (`text-primary` on `fill`) | 14.40 | 12.07 | 4.5:1 | Pass |  |  |
| Selected text (::selection) (`text-primary` on `accent-tint`) | 14.52 | 12.42 | 4.5:1 | Pass |  | D116 |
| Secondary text on page (`text-secondary` on `bg-page`) | 4.66 | 7.24 | 4.5:1 | Pass |  |  |
| Secondary text on card (`text-secondary` on `surface-card`) | 5.07 | 6.53 | 4.5:1 | Pass |  | D47 |
| Secondary text on dialog and sheet (`text-secondary` on `surface-modal`) | 5.07 | 5.69 | 4.5:1 | Pass |  | D114 |
| Secondary text on card footer (`text-secondary` on `surface-inset`) | 4.90 | 6.53 | 4.5:1 | Pass |  |  |
| Secondary text on hover well (`text-secondary` on `surface-hover`) | 4.74 | 5.69 | 4.5:1 | Pass |  |  |
| Primary text on dialog hover well (`text-primary` on `surface-modal-hover over surface-modal`) | 15.73 | 10.92 | 4.5:1 | Pass |  | D121 |
| Secondary text on dialog hover well (`text-secondary` on `surface-modal-hover over surface-modal`) | 4.74 | 4.72 | 4.5:1 | Pass |  | D121 |
| Completed row title, selected (`text-on-tint-secondary` on `accent-tint`) | 4.63 | 5.37 | 4.5:1 | Pass |  | D122 |
| Text on fill: gray tag, segment labels (`text-on-fill` on `fill`) | 5.12 | 5.22 | 4.5:1 | Pass |  | D52 |
| Selected row subtitle and value (`text-on-tint-secondary` on `accent-tint`) | 4.63 | 5.37 | 4.5:1 | Pass |  | D53, D98 CHANGE |
| Supporting text on the selected card (`text-on-tint-secondary` on `accent-tint`) | 4.63 | 5.37 | 4.5:1 | Pass |  | D190 CHANGE (was text-secondary, 4.38:1) |
| Link on page (`accent` on `bg-page`) | 4.82 | 8.44 | 4.5:1 | Pass |  |  |
| Link on card (`accent` on `surface-card`) | 5.25 | 7.62 | 4.5:1 | Pass |  |  |
| Link on hover well (`accent` on `surface-hover`) | 4.91 | 6.64 | 4.5:1 | Pass |  |  |
| Link hover on card (`accent-hover` on `surface-card`) | 6.52 | 9.84 | 4.5:1 | Pass |  |  |
| Teal text on tint; active tab label (`accent-tint-text` on `accent-tint`) | 4.53 | 8.09 | 4.5:1 | Pass |  |  |
| Tonal hover label (`accent-hover` on `accent-tint-hover`) | 5.24 | 7.15 | 4.5:1 | Pass |  |  |
| Label on primary (`on-accent` on `accent-fill`) | 5.25 | 4.55 | 4.5:1 | Pass |  |  |
| Label on primary hover (`on-accent` on `accent-fill-hover`) | 6.52 | 5.25 | 4.5:1 | Pass |  |  |
| Key hint in a primary button (`on-accent` on `kbd-on-fill over accent-fill`) | 6.89 | 6.00 | 4.5:1 | Pass |  | D10 |
| Red text on card (`danger-text` on `surface-card`) | 5.38 | 5.26 | 4.5:1 | Pass |  |  |
| Red text on page (`danger-text` on `bg-page`) | 4.94 | 5.83 | 4.5:1 | Pass |  |  |
| Red text on wrong wash (`danger-text` on `danger-tint`) | 4.72 | 4.90 | 4.5:1 | Pass |  |  |
| Red ghost hover label on its wash, card (`danger-text-hover` on `danger-text-hover%opacity-hover over surface-card`) | 5.95 | 5.59 | 4.5:1 | Pass |  | D123 CHANGE |
| Red ghost hover label on its wash, dialog (`danger-text-hover` on `danger-text-hover%opacity-hover over surface-modal`) | 5.95 | 4.86 | 4.5:1 | Pass |  | D123 CHANGE |
| Neutral button hover label (text-primary at opacity-hover over fill) (`text-primary` on `text-primary%opacity-hover over fill`) | 12.30 | 9.48 | 4.5:1 | Pass |  | D168 |
| Tertiary hover label on its wash, card (`text-primary` on `text-primary%opacity-hover over surface-card`) | 14.38 | 12.11 | 4.5:1 | Pass |  | D168 |
| Teal tertiary hover label on its wash, card (`accent-hover` on `accent-hover%opacity-hover over surface-card`) | 5.79 | 8.29 | 4.5:1 | Pass |  | D168 |
| Promo secondary text on the card end (`text-on-tint-secondary` on `surface-card`) | 5.36 | 6.53 | 4.5:1 | Pass |  | D167 CHANGE |
| Promo secondary text on its tint end (`text-on-tint-secondary` on `accent-tint`) | 4.63 | 5.37 | 4.5:1 | Pass |  | D167 CHANGE |
| Promo primary text on its tint end (`text-primary` on `accent-tint`) | 14.52 | 12.42 | 4.5:1 | Pass |  | D167 |
| Red ghost label in a dialog (`danger-text` on `surface-modal`) | 5.38 | 4.58 | 4.5:1 | Pass |  |  |
| Label on danger fill (`on-danger` on `danger-fill`) | 5.38 | 5.61 | 4.5:1 | Pass |  |  |
| Label on danger hover (`on-danger` on `danger-fill-hover`) | 6.89 | 6.44 | 4.5:1 | Pass |  |  |
| Primary text on right bar (`text-primary` on `accent-bar`) | 15.46 | 12.42 | 4.5:1 | Pass |  |  |
| Primary text on wrong bar (`text-primary` on `danger-bar`) | 15.53 | 14.60 | 4.5:1 | Pass |  |  |
| Primary text on segment thumb (`text-primary` on `surface-segment-on`) | 16.83 | 8.13 | 4.5:1 | Pass |  |  |
| Pro mark text (`on-pro` on `pro`) | 7.42 | 7.42 | 4.5:1 | Pass |  |  |
| Warning text on card (`warning-text` on `surface-card`) | 5.20 | 7.92 | 4.5:1 | Pass |  | D54 |
| Warning text on page (`warning-text` on `bg-page`) | 4.77 | 8.78 | 4.5:1 | Pass |  |  |
| Warning tag text (`warning-tint-text` on `warning-tint`) | 4.69 | 8.75 | 4.5:1 | Pass |  | D54 |
| Toast message (`toast-text` on `toast-bg`) | 16.83 | 11.35 | 4.5:1 | Pass |  | D51 |
| Toast action (`toast-action` on `toast-bg`) | 10.05 | 6.78 | 4.5:1 | Pass |  |  |
| Toast action on its hover well (`toast-action` on `toast-action-hover over toast-bg`) | 7.42 | 4.96 | 4.5:1 | Pass |  |  |
| Reader body on card (`reader-body` on `surface-card`) | 10.94 | 9.98 | 4.5:1 | Pass |  |  |
| Reader strong on card (`reader-strong` on `surface-card`) | 18.85 | 16.48 | 4.5:1 | Pass |  |  |
| Reader note text on tint (`reader-note-text` on `accent-tint`) | 8.41 | 11.47 | 4.5:1 | Pass |  |  |
| Reader mistake text on its tint (`reader-mistake-text` on `reader-mistake-tint`) | 9.45 | 11.68 | 4.5:1 | Pass |  |  |
| Figure caption on figure scrim (`figure-caption` on `figure-scrim over bg-page`) | 9.80 | 12.92 | 4.5:1 | Pass |  |  |
| Chart and axis labels on card (`text-secondary` on `surface-card`) | 5.07 | 6.53 | 4.5:1 | Pass |  | D105 |
| Disabled label on fill (`text-disabled` on `fill`) | 1.89 | 2.47 | 4.5:1 | Fail | Exempt: disabled control |  |
| Focus ring on page (`accent` on `bg-page`) | 4.82 | 8.44 | 3:1 | Pass |  |  |
| Focus ring on card (`accent` on `surface-card`) | 5.25 | 7.62 | 3:1 | Pass |  |  |
| Field, search, select, white button ring on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  | D45 CHANGE |
| SelectableTile rest ring on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  | D158 CHANGE |
| SelectableTile rest ring on page (`border-control` on `bg-page`) | 3.16 | 5.60 | 3:1 | Pass |  | D158 CHANGE |
| Control ring on page (`border-control` on `bg-page`) | 3.16 | 5.60 | 3:1 | Pass |  |  |
| Control ring in a dialog (`border-control` on `surface-modal`) | 3.44 | 4.40 | 3:1 | Pass |  | D114 |
| Answer badge ring on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  | D45 CHANGE |
| Switch off ring on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  | D45 CHANGE |
| Not-started task marker on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  |  |
| Blank question chip ring on page (`border-control` on `bg-page`) | 3.16 | 5.60 | 3:1 | Pass |  | D97 CHANGE |
| Blank question chip ring on card (`border-control` on `surface-card`) | 3.44 | 5.06 | 3:1 | Pass |  | D97 CHANGE |
| Inactive nav icon on page (`icon-muted` on `bg-page`) | 3.16 | 6.02 | 3:1 | Pass |  |  |
| Inactive nav icon on card (`icon-muted` on `surface-card`) | 3.44 | 5.43 | 3:1 | Pass |  |  |
| Row chevron on card (`icon-chevron` on `surface-card`) | 3.26 | 5.43 | 3:1 | Pass |  |  |
| Row chevron on hover well (`icon-chevron` on `surface-hover`) | 3.05 | 4.73 | 3:1 | Pass |  |  |
| Selected row chevron on tint (`accent-tint-text` on `accent-tint`) | 4.53 | 8.09 | 3:1 | Pass |  | D98 CHANGE |
| Figure viewer controls on scrim (`figure-on-viewer` on `figure-scrim over bg-page`) | 14.91 | 19.66 | 3:1 | Pass |  |  |
| Wrong ring on wrong wash (`danger` on `danger-tint`) | 4.72 | 3.23 | 3:1 | Pass |  |  |
| Wrong ring on card (`danger` on `surface-card`) | 5.38 | 3.47 | 3:1 | Pass |  |  |
| Invalid field ring on card (`danger` on `surface-card`) | 5.38 | 3.47 | 3:1 | Pass |  |  |
| Chart bar and line on card (`accent` on `surface-card`) | 5.25 | 7.62 | 3:1 | Pass |  | D105, D124 CHANGE |
| Progress fill on its track (`accent` on `fill`) | 4.50 | 6.08 | 3:1 | Pass |  | D124 CHANGE |
| Slider progress on its track (`accent` on `fill`) | 4.50 | 6.08 | 3:1 | Pass |  | D124 CHANGE |
| Reader progress thread on its track (`accent` on `fill`) | 4.50 | 6.08 | 3:1 | Pass |  | D125 |
| Week done dot on card (`accent` on `surface-card`) | 5.25 | 7.62 | 3:1 | Pass |  | D124 CHANGE |
| Hero title on the gradient start (large text) (`on-hero` on `hero-start`) | 4.22 | 4.22 | 3:1 | Pass |  | D126 |
| Hero body text on the middle stop (`on-hero` on `hero-mid`) | 5.25 | 5.25 | 4.5:1 | Pass |  | D126 |
| Hero icons on the gradient start (`on-hero-secondary` on `hero-start`) | 3.38 | 3.38 | 3:1 | Pass |  | D126 |
| Topic-done text on its end (`on-hero` on `topic-done-end`) | 7.92 | 7.92 | 4.5:1 | Pass |  | D126 |
| Search match highlight (`accent-tint-text` on `accent-tint`) | 4.53 | 8.09 | 4.5:1 | Pass |  | D127 |
| Tooltip text (`toast-text` on `toast-bg`) | 16.83 | 11.35 | 4.5:1 | Pass |  | D128 |
| Focus ring in a dialog (`accent` on `surface-modal`) | 5.25 | 6.64 | 3:1 | Pass |  |  |
| Accuracy step 1 on its track (`chart-1` on `fill`) | 2.58 | 2.41 | 3:1 | Fail | Exempt: supplementary, the number is always printed (WCAG 1.4.11) | D46, D117 |
| Accuracy step 2 on its track (`chart-2` on `fill`) | 2.96 | 2.76 | 3:1 | Fail | Exempt: supplementary, the number is always printed (WCAG 1.4.11) | D117 |
| Accuracy step 3 on its track (`chart-3` on `fill`) | 3.40 | 3.65 | 3:1 | Pass | Exempt: supplementary, the number is always printed (WCAG 1.4.11) | D117 |
| Accuracy step 4 on its track (`chart-4` on `fill`) | 3.91 | 4.76 | 3:1 | Pass | Exempt: supplementary, the number is always printed (WCAG 1.4.11) | D117 |
| Accuracy step 5 on its track (`chart-5` on `fill`) | 4.50 | 6.08 | 3:1 | Pass | Exempt: supplementary, the number is always printed (WCAG 1.4.11) | D117 |
| Selected ring (accent) on card (`accent` on `surface-card`) | 5.25 | 7.62 | 3:1 | Pass |  |  |
| Divider on card (decorative) (`divider` on `surface-card`) | 1.28 | 1.25 | 3:1 | Fail | Decorative: never a control boundary |  |
| Strong divider on card (decorative) (`divider-strong` on `surface-card`) | 1.52 | 1.52 | 3:1 | Fail | Decorative: key-hint ring, hover ring |  |
| Progress ring track on card (`divider` on `surface-card`) | 1.28 | 1.25 | 3:1 | Fail | Decorative: the number or status text is printed |  |
| Skeleton on card (`fill-skeleton` on `surface-card`) | 1.28 | 1.52 | 3:1 | Fail | Decorative: a placeholder | D112 |
| Skeleton on hover well (`fill-skeleton` on `surface-hover`) | 1.20 | 1.32 | 3:1 | Fail | Decorative: a placeholder | D112 |
| Card on page (flat surface) (`surface-card` on `bg-page`) | 1.09 | 1.11 | 3:1 | Fail | Decorative: content identifies a card |  |
| Dialog on dimmed card (dark: surface-modal on card under the scrim) (`surface-modal` on `scrim over surface-card`) | 2.03 | 1.33 | 3:1 | Fail | Not required: a dialog is identified by its content and elevation | D114 |
| Toast on dark page (raised gray plus 1px edge) (`toast-bg` on `bg-page`) | 15.46 | 1.61 | 3:1 | Fail | Not required: the toast has a 1px #4A4A4A edge in dark | D51 |

## Type

One family: Geist (400, 500, 600, 700). Source Serif 4 is for math and figures only. Tabular figures on every number that changes or aligns (`.tnum`; display classes have it built in). Sizes are rem (1rem = 16px) so web text follows the browser text size; Flutter uses logical pixels (rem times 16).

### Desktop scale (wide web)
Base: `web-display` 48/700/1 -0.03em (hero numbers). `web-h1` 38/700/1.1 -0.024em. `web-h2` 26/700/1.2 -0.018em. `web-h3` 20/700/1.3 -0.012em. `web-h3-lg` 22/700/1.3 (call-to-action card title, sidebar wordmark). `web-title-sm` 16/600/1.3 (notice title, tile name; new). `web-lead` 17/400/1.45. `web-body` 16/400/1.45. `web-sub` 15/400/1.45 (secondary; also the date line above a root title). `web-small` 13/400/1.45 (also hints, help and footer lines). `web-field-label` 13/600/1.3 (field label; new). `web-label` 14/600/1.3 (sidebar account, segment labels) and `web-caption` 12/400 (sidebar account, chart labels). `web-eyebrow` 13/600/1.35 uppercase +0.02em. `web-big-numeral` 40/700/1.05 -0.03em. `web-stat-unit` 22/600 (unit after a hero number). `web-question` 27/600/1.38 -0.016em. `web-reader-body` 18/400/1.7. `web-reader-block` 16/400/1.6 (reader blocks; new). `web-explanation` 17/400/1.55 (explanation card; new).
Components (fixed sizes that mirror a base size): `web-nav` 15/500, `web-button` 16/600 and `web-button-lg` 17/600, `web-key-hint-sm` 11/600, `web-tag` 12/600 (also the in-button key hint), `web-pro` 11/700, `web-row-title` 17 (also the back link), `web-row-title-settings` 16, `web-row-sub` 14, `web-row-value` 15, `web-timer` 17/700 tabular (new), `web-option` 18/1.4, `web-link` 15/600, `web-stat-value` 16/600 (new), `web-chip-name` 13/700 (new), `web-glyph` 14/700/1 (avatar initial, calendar day; new), `web-search-input` 19/400 (SearchOverlay; new). Merged in 3.0.0 (R2-O22): `web-seg` into `web-label`, `web-back` into `web-row-title`, `web-key-hint` into `web-tag`.
Math: `.math` is the contract: Source Serif 4 at 1.12em of the surrounding text, with its weight and line height. There is no fixed-weight math style (R3-O09); Flutter uses `copyWith` on the parent style. `math-display` is 1.6em of the reader body (about 29px at 18px).
- Every component text slot maps to one style (table under Flutter handoff, "Type slots"). A state may change only the weight (selected, unselected, current, today, right answer, empty), and so may the two named emphasis modifiers (`.row__title--strong`, `.field__opt`) and `strong`. A rest weight is a style of its own (R3-O09: `phone-tab-label`, `phone-wheel`, `web-stat-value`, `web-chip-name`, `web-glyph`). A single-glyph box (badge letter, date number, question chip, chart axis label) may set line height 1. The build script fails on anything else. Two slots may change their size, and both are named exceptions: the TabBar label stops at 12px (`size-tab-label-max`, D181; the build script allows a `font-size` only on `.tabbar__item`), and the phone large title takes `phone-title-2` under `layout-title-narrow` (D180).

### Phone scale
`phone-large-title` 34/700/1.12 -0.022em. `phone-title-1` 28/700/1.2 -0.022em. `phone-title-2` 22/700/1.35 -0.012em. `phone-title-3` 20/700/1.35. `phone-question` 21/600/1.35. `phone-headline` 17/600/1.35 -0.012em. `phone-body` 17/400/1.35 -0.012em. `phone-reader-body` 17/400/1.55. `phone-callout` 16/400/1.35. `phone-subhead` 15/500/1.35. `phone-explanation` 15/400/1.5. `phone-footnote` 13/400/1.35. `phone-footnote-strong` 13/500/1.35. `phone-section-header` 13/600 uppercase +0.02em. `phone-caption` 12/400. `phone-caption-small` 10/600 (tab labels, week days). `phone-display-s` 44, `-m` 60, `-l` 88, all 700 and tabular (`-l` keeps -0.022em as drawn; the others -0.03em). `phone-option` 17/400/1.35 (answer options; scales with the lesson text, new), `phone-tab-label` 10/500 (tab label at rest, new), `phone-wheel` 20/400/1 (wheel picker, new).

### When each applies
- Use the desktop scale at 1024px and wider. Use the phone scale below 1024px on the web and in the apps. A page built with the wide classes inside `.shell`, `.focus` or `.reader` switches by itself: each wide style names its phone style (`phoneScale`: `web-h1` to `phone-large-title`, `web-h2` to `phone-title-2`, `web-h3` to `phone-title-3`, `web-body` and `web-lead` to `phone-body`, row titles and values to `phone-body`, `web-row-sub` and `web-small` to `phone-footnote`, `web-eyebrow` to `phone-section-header`, buttons to `phone-headline`, `web-question` to `phone-question`, `web-option` to `phone-option`, `web-reader-body` to `phone-reader-body`, `web-explanation` to `phone-explanation`; ruling 11). The generated block writes the swap.
- Exactly one `h1` per screen: `web-h1` or `phone-large-title`, or on question screens the stem itself, an `h1` styled `web-question` or `phone-question`.
- Lesson text uses the reader styles, color `reader-body`, in a 680px column (800px with full width on).

### Text scaling
- UI text follows the OS text size up to 2.0 (Flutter: at the app root, read the OS scaler first, keep it as `osTextScaler` (an inherited value such as an `InheritedWidget` or a provider, so it reaches reader Sheets and Drawers, which mount outside the page root), then set the UI scaler with `osTextScaler.clamp(maxScaleFactor: 2.0)`). Lesson text is not clamped: it uses `osTextScaler`, never the clamped `MediaQuery` value (Astra review, D190).
- Named exception, TabBar labels (D181): the label is 10px at default text and stops at 12px (1.2x). Tab labels follow iOS, which does not grow tab labels with Dynamic Type; the label stays visible and never drops to an icon. Flutter: `textScaler.clamp(maxScaleFactor: 1.2)` on the tab label only, and a long press on a tab shows its label large, as the iOS Large Content Viewer does. Web: the accessible name carries the label, and browser zoom still scales it. This is the only UI text that stops below 2.0.
- The lesson text scale (1.0 to 2.0, a slider) multiplies the OS scale for lesson text and for quiz stems and choices (as the code does). Web: set `--reader-scale` on `.reader`, on `.focus` or on any question region; `web-reader-body`, `web-reader-block`, `web-explanation`, `web-question`, `web-option`, `phone-reader-body`, `phone-question`, `phone-option` and `phone-explanation` multiply their size by it. The bundle redeclares these styles on every element, so the component slots that use them (notes, examples, passages, options, explanations) follow the nearest setting, and two readers on one page can differ (ruling 4, R3-A02). Display math is em-based and sits in a reader block or in `.reader`, which sets the reader body, so it follows too. Flutter: one reader `TextScaler` around the reader and the question column, whose `scale(fontSize)` is `osTextScaler.scale(fontSize)` times the lesson scale, with `osTextScaler` captured before the UI clamp (above); the same scaler wraps reader Sheets and Drawers.
- Controls use `min-height`, never a fixed height. Button labels, row titles and subtitles may wrap. Never truncate a title to fit a value.
- Above 1.5x: a row's value stacks under its title by itself (ruling 12: wrap rules; the title keeps at least 6em of its own text (3.2.1), and when the title and the value no longer fit on one line the value wraps under it; the chevron stays at the row end and never takes a line of its own; `.row--stack` forces it), dialog and sheet pairs wrap with the main action on top on the phone and keep secondary-then-main order on wide screens (`.dialog__actions--stack` forces the column), and the TabBar labels stay visible and stop growing at 12px (`size-tab-label-max`, D181); the phone large title steps down to title 2 when the phone screen is under 12rem wide (`layout-title-narrow`, D180; the screen is `.phone-screen`, or the `.main` of a `.shell` page below 1024, D189). Flutter: take the screen width less the gutters divided by `textScaler.scale(16)` (the width in rem); under 12 use the `phone-title-2` style for the large title.
- Round 4 rules (rulings 1, 2, 7, 9): a Slider's end labels and value move above the track when the row is under 17rem, so the track keeps the full width; tile grids use rem column minimums (`size-tile-min`), so they drop to one column at large text; the FocusHeader title truncates on one line and its clock drops the bar under 24rem, so the actions stay on screen; a full-width button pair stacks with the main action on top on phones and tablets (reverse stack), the DOM order staying secondary then main.
- Bars and reserves (ruling 3): the reserve under every floating bar is its height written in rem (`layout-reserve-tabbar`, `layout-reserve-bar-phone`, `layout-reserve-bar`) plus the safe area, so it grows with text. The bottom action bar (`.phone-bottom`, paywall CTA and reader bar) and the phone quiz bar (`.fbar-dock--phone`) hold text that wraps at large text, so they are sticky at the end of the screen: they take their own height in the flow and never hide content at any text size.
- Test every screen at 320px wide and at 200% text, in both themes.

### Math and figures
- One math rule (R2-O03): inline math is 1.12em of the surrounding text on every platform, with the text's weight and lining figures; display math is `math-display`, 1.6em of the reader body. Math never shrinks below the text. A long expression scrolls sideways in place (`.math`, `.math--display`). Give each expression a text alternative (`role="img"` with `aria-label`, or MathML).
- Every equation has a text alternative for screen readers, and every figure a description from its `figureSpec`. The figure viewer has Close, zoom in and zoom out buttons, Esc closes and arrow keys pan.
- Source Serif 4 is the design value for math and figure labels; the app renders math with KaTeX_Main today. Decision D91 rules it.
- Test fractions, matrices, long equations and diagrams at large text in both themes.

## Spacing and layout

### Spacing
- Base step is 2px. Public scale for gaps between blocks: `space-0`, `space-4`, `space-8`, `space-12`, `space-16`, `space-20`, `space-24`, `space-28`, `space-32`, `space-40`, `space-44`, `space-56`.
- `space-2`, `space-6`, `space-10`, `space-14` and `space-18` are for component internals and optical alignment only.
- Every padding, margin, gap and inset in the bundle is a `space-*` or `layout-*` token, or a literal on the 2px grid that the component README lists under "Component internals" with its board source. Odd board values (7, 11, 13) are kept only where hundreds of approved phone rows draw them, and each is listed. The build script fails on any other literal (R2-O08).

### Tiers
Tiers come from the window width, on the web and in native tablet builds alike.

| Tier | Width | Navigation | Type scale | Buttons | P2 placement | Hover affordances |
|---|---|---|---|---|---|---|
| Phone | under 600 | TabBar (floating, inset 16); 16px gutters | phone | main action full width | no (stacked) | no |
| Tablet | 600 to 1023 | TabBar centered, max 358; content in the centered 640 column, 24px sides | phone | full width of the 640 column | no (stacked) | only with a fine pointer |
| Compact | 1024 to 1439 | SidebarNav at its minimum width (220); main sides 32 | desktop | natural width | yes | only with a fine pointer |
| Wide | 1440 and up | SidebarNav (220 to 244); main sides 44 | desktop | natural width | yes | yes |

One markup (ruling 11, CHANGE D136): the same Home markup renders all four tiers; AppShell switches the navigation and the column and the page root swaps the type (above). A page needs no separate tablet build.

"Wide" means 1024px and up. Hover-only cues (row chevrons, key hints) depend on the input (`hover: hover` and `pointer: fine`), not the width. Focus mode shows the question and the explanation side by side from 1134px (`bp-focus-split`); below it the explanation opens as a 440px Drawer. Phones under 400px (`bp-phone-narrow`) move the quiz flag to the question header.
- Built in the bundle (R2-O25, ruling 11): the shell switch (`.shell` shows SidebarNav from 1024, compact to 1439, and the floating TabBar below) and the focus split (`.stage > .xpl` becomes a drawer below 1134). CSS custom properties cannot drive `@media`, so the bundle repeats the `bp-*` values as literals; the build script fails when a media query uses a width that is not a `bp-*` value (or one less). `.shell--desktop` and `.focus--split` force the wide layout inside documentation frames only.

### Shell
- Sidebar: flex basis 220, maximum 244. Main padding 28 top, 44 sides, 44 bottom. Content maximum `layout-content-max` (1080), centered.
- One gap between blocks: 28px (`layout-section-gap`, in a column and between columns; `layout-cols-gap` folded in, 3.0.0).
- Row inset 20px (settings 16px), vertical 13px.
- Layout classes: `.shell`, `.shell__side`, `.main`, `.wrap`, `.stack` (`--12`, `--16`, `--24`), `.cols` and the column classes. See the Layout components. Lessons use ReaderLayout (`.reader`, `.reader__col`, 680, or 800 with `.reader--wide`).

### Columns
Use one of four pairs. They wrap with `flex-wrap`; there are no media queries.
- Primary and secondary: `.col-primary` (1.45 1 480) with `.col-secondary` (1 1 340). Home, Plan, Performance, Record, Mock setup.
- Picker and panel: `.col-picker` (1 1 480) with `.col-panel` (0 1 400, sticky, top 28). Custom quiz.
- Equal: `.col-equal-a` (1 1 420) with `.col-equal-b` (1 1 380). Quiz tab, Plan day.
- List and detail: `.col-list` (1 1 300, max 360) with `.col-detail` (999 1 460). Settings.

### Focus mode (quiz, mock, assessment)
No sidebar. Header 64px, 20px side padding. Question column 720px (600px while the explanation shows). Explanation column 440px, 14px gap, slides in from the right. Floating bar 64px high, radius 32, 28px above the bottom, maximum 720px (1080px on wide pages). Stage padding 56px 40px, bottom `layout-reserve-bar` (8.75rem, 140 at default text). Below 1134 the explanation is a modal drawer with its own footer (counter and Next), so the main action is reachable inside the focus trap (R3-O03). The mock question list (ruling 5): wide pushes the content, tablet is a left drawer, phone a bottom sheet; Close and the clock sit in the header inside `.qpanel-shift`, so the panel never covers them. The panel is open only with `.qpanel.is-open`, on every tier (R4-O17).
- Modal panels on narrow tiers (ruling 8): below 1024 the question list and below 1134 the explanation drawer follow the full modal contract: `role="dialog"`, `aria-modal="true"` and a label; the page behind is `inert` (the header stays visible but inert); focus moves into the panel and returns to the opener; Esc closes; the scrim is a real element (`.scrim.scrim--qpanel` under the header, `.scrim.scrim--xpl` over the window) that the app inserts with the panel, fades over `dur-switch` and closes on click, and the page scroll locks. On wide screens the same elements are a complementary `aside` and a region with no scrim. The app switches the roles at the tier change.
- Passage items (ruling 2): from 1134px the Passage takes a left column (1 1 480, maximum 640) and the question sits right; each scrolls on its own; the explanation replaces the passage column on reveal. Below 1134px and on the phone the passage collapses to four lines above the stem, with "Show Passage" opening a Drawer (wide) or a Sheet (phone).
- Results pages (mock and quiz results) stay in focus mode: no sidebar and no TabBar, content in `.wrap` (1080 maximum), Done top right on the title row; Done leaves focus mode (usage gap 11).

### Phone frame
390px reference. Gutter 16px. A 44px nav bar (`.phone-nav`; back at the left), then a large title with 6px 4px 20px padding. The screen container is `.phone-screen` (renamed from `.phone-body`, which is the body type style, R2-O16). Sections 24px apart. Grouped lists inset 16px with radius 14. TabBar floats 64px high, 16px in, 24px up (or safe area plus 8). Sheets rise from the bottom with a 14px top radius. Bottom reserves (ruling 3): `.phone-screen--tabs` (`layout-reserve-tabbar`, 6.5rem) plus the safe area; with a bottom action bar or the phone quiz bar the bar is sticky and the reserve is only 8 or 16 (`--bottom`, `--bottom-2`, `--bar`). Respect `env(safe-area-inset-*)` at every edge. No status bar is drawn in boards.

## Radius and elevation

- Radius tokens: `radius-xs` 5 (key caps, Pro mark), `radius-sm` 8, `radius-md` 12, `radius-lg` 14, `radius-xl` 18 (cards), `radius-2xl` 22 (dialogs), `radius-bar` 32 (floating bar), `radius-full` 9999 (switches, dots, tracks, avatars, the tab bar, tags (D188), and the pill buttons the approved boards draw: the floating bar counter and action, the phone dialog pair and the compact pill `btn--pill-sm`; no other button), and `radius-back` 11 (back link A only).
- Radius follows height: under 40px uses `radius-sm`, 40 to 44px `radius-md`, 46px and up `radius-lg`. Exceptions drawn as pills (D187, D189): `btn--bar`, `.cnt`, `btn--dialog` and `btn--pill-sm` use `radius-full`; a tertiary `btn--bar` or `btn--dialog` keeps `radius-lg`, a tertiary `btn--pill-sm` `radius-md`.
- Rings are inset box-shadows: 1px for fields, search, select and white buttons (`border-control`), 1.5px for checkboxes, radios, answer badges and the switch off ring (`border-control`), 2px for selected (`accent`) or wrong and invalid (`danger`), 2.5px for the current question chip and the spinner arc (`border-ring-current`). Ring strokes: track 2px (`border-ring-selected`), value 2.4px (`size-ring-stroke`), the 44px ring 2.5px. Hairlines are 0.5px `divider`.
- Cards are flat in light; in dark they carry a 1px inset `edge-card`. Only floating things get an elevation token, in four levels (R2-O23, no value changed): level 1 control (`elev-nav-active`, `elev-segment`, `elev-knob` switch thumb, `elev-thumb` slider thumb; 1 to 3px blur), level 2 floating (`elev-popover`, `elev-bar` with the `edge-bar` ring, `elev-toast`; 10 to 14px offset), level 3 panel (`elev-drawer`, `elev-sheet`), level 4 modal (`elev-modal`).
- Z order: `z-base` 0, `z-sticky` 10, `z-nav` 20 (TabBar, floating bar, reader bar), `z-overlay` 40 (scrim), `z-modal` 50 (dialog, drawer, sheet), `z-popover` 60, `z-toast` 70, `z-tooltip` 80 (Tooltip). Each modal owns a scrim and surface pair; a popover opened inside a modal stacks above it; a later overlay of one layer stacks above an earlier one.

## Iconography

- The app's icon set is Phosphor (the bundled icon font) plus a few own icons. Use the Regular weight at 20 to 23px (stroke about 1.7 to 1.8) and Bold for 14 to 16px chevrons and arrows (stroke 2.2). The active nav icon uses a heavier stroke (2 to 2.1).
- Icons take the color of their context: `icon-muted` inactive, `accent` active or leading in a row, `text-secondary` in an IconButton.
- No icon sits on a tinted tile inside a card. No emoji as decoration. No filled icons in rows.
- This system holds no icon files. Previews use plain stroke glyphs drawn for the previews. Product screens need these glyphs from the Phosphor set: home, book (study), question (quiz), sliders (settings), magnifying glass, caret right, caret left, caret down, arrow right, x, check, flag, info, warning, user, sparkle, chart, bell, target, circle-half, calendar, bookmark and trash (Bookmarks), list (question list), clock (the mock clock), minus and plus (Custom Quiz counts), brain (Practice; still missing). Decision D41 tracks the files.
- The logo is the Pantas mark (a mortarboard with a P and a tassel) with the wordmark in Geist 700. The mark's paths are in `components/Cover/preview.html` and come from the app's `pantas_logo.dart`. The tassel is `accent`, the rest is `text-primary`. The tassel swings on the waiting screen (`.tassel-swing`, motion.md).

## Motion

Curves and durations are tokens; `motion.md` holds every recipe, the choreographies and their Flutter values. In short:
- Phone is the reference. Wide animates where phone animates. Never remove approved motion.
- Enter with `motion-enter`; move things already on screen with `motion-move`; spring a transition (switch thumb) with `motion-spring`; fade color with `motion-fade`. Dialogs and toasts use `motion-house`, drawers and sheets `motion-slide`, as in the phone code.
- Press: scale 0.97 (options 0.98), `dur-short-1` down, `dur-short-3` up. Hover: `dur-short-2` color.
- A keyframed overshoot never also takes an overshooting curve (R2-O13): pops run `pn-pop` (.4 to 1.08 at 60% to 1) with `motion-enter` then `motion-fade` per segment, so the drawn peak is the ruled 1.08. `motion-spring` is for transitions only (switch thumb, edge tab).
- No shake on a wrong answer. Reduced motion removes spatial motion, keeps short color fades and stops every loop.

## Accessibility

- Contrast: text 4.5:1 (3:1 at 24px and up); icons, control boundaries and focus rings 3:1; both themes. See the contrast table.
- Targets: 44px minimum on touch (phone, tablet, any coarse pointer); smaller drawn controls get a padded hit area. With a mouse only, 32px preferred and 24px minimum. Sidebar items (40px) and the sidebar search (38px) are pointer-only.
- Focus: every control shows a 2px `accent` outline, offset 2px, on its own shape, for keyboard focus only (`:focus-visible`). Items whose selected state is an accent ring take a `text-primary` focus ring, so focus never looks like selection. An invalid field keeps its red ring and adds the outer focus outline. Clip card content on an inner wrapper or keep 4px clearance so focus rings are not cut.
- Never color alone: right and wrong carry a check or a cross and hidden text; errors carry an icon and a sentence; the current page carries `aria-current`; a switch shows state by thumb position; a task marker carries a status word.
- Screen readers: answer options are a radiogroup and stay focusable and readable after the reveal (`aria-disabled`, never `disabled`); navigation items are links with `aria-current="page"`; segmented controls are tabs (view switch) or a radiogroup (sort and filter); popovers are menus, listboxes or non-modal dialogs; toasts and the floating bar hint use `role="status"`; a submit error uses `role="alert"`.
- Modals (Dialog, Drawer, Sheet): `role="dialog"` with `aria-modal`, labelled by the title and described by the body; initial focus on the safe action of a destructive confirm, otherwise on the first field or the main action; Tab stays inside; the page behind is inert; Esc and a visible Close; focus returns to the trigger. The mock question list below 1024 and the explanation drawer below 1134 follow the same contract (ruling 8; Focus mode above).
- Reduced motion: no translate, scale or rotate; overlays appear in place with a 150ms fade; loops stop (spinner, skeleton pulse, blink, hourglass); the spinner shows a static arc and a visible "Loading" label; the press scale is removed.
- Forced colors (Windows high contrast): controls, selection and focus get real borders and outlines in system colors, because box-shadow rings disappear there; every supported selected or current state gets the border, whether it is set by a class or by its ARIA attribute (D190); the slider track and thumb are redrawn with system colors (D190); every floating surface (popover, toast, tooltip, dialog, drawer, sheet, bars) gets a 1px `CanvasText` border (D189). Data marks drawn as backgrounds (chart bars and points, week done and half dots, the question flag dot, the reader thread) keep `CanvasText` with `forced-color-adjust: none` (R3-O06); week dots are painted by state, so planned, no-study and today cells show no dot (R4-O02).
- Icon-only controls carry an `aria-label` and, with a fine pointer, a Tooltip that repeats it with its shortcut ("Flag (F)"); a cut title shows its full text in a Tooltip (R3-O10).
- Text scaling: see Type. The TabBar label cap is the one named exception (D181).
- Character keys (WCAG 2.1.4, R2-O12): single-letter shortcuts (answer letters, F to flag) act only while focus is inside the question region, never page-wide, and Settings > Accessibility > Keyboard Shortcuts (a switch, on by default, wide screens only) turns them off. Modifier shortcuts (Ctrl K) are unaffected.
- Forms use native inputs (ruling 6): Checkbox, Radio and Switch are `input` elements; Select is a native `select` except the onboarding listbox, which carries its value in a hidden input.

## Voice and copy

- Title Case on buttons and links: "Keep Going", "See Pro", "Continue Lesson", "Start the Mock Exam", "Add Exam Date", "Try 7 Days Free", "Try Again".
- Simple English, short sentences, the verb first. "Pantas plans your weeks backward from the day."
- Say "points", not "marks". Say "questions", not "cards".
- American spelling. No em dashes.
- Say only what the app measured. No invented streaks, ranks or percentages.
- Fine print belongs to its button: right-aligned under it, `web-small`. Example: "Free for 7 days, then ₱99 a month. Cancel any time."
- Errors say what happened and what to do. No raw codes.

## Information architecture

Four destinations, the same order everywhere.

| Destination | SidebarNav (1024 and up) | TabBar (below 1024) |
|---|---|---|
| Home (plan, week, accuracy) | slot 1 | slot 1 |
| Study (subjects, lessons, reader) | slot 2 | slot 2 |
| Quiz (practice, mock exams, custom quiz) | slot 3 | slot 3 |
| Settings (exam, account, appearance, Pro) | slot 4 | slot 4 |

Plan lives inside Home. Performance and Record open from Home. Focus mode (quiz, mock, assessment) hides both bars.

## Flutter handoff

The Flutter app consumes the same `tokens.json`. The generator is built later, with the code migration; until then this table is the contract.

### Generator
- One command reads `tokens.json` and writes `pantas_tokens.g.dart` (one Dart class per token family, table below; the themed ones are ThemeExtensions with `copyWith` and `lerp`) and a `tokens.css` laid out exactly as the design-system page writes it. CI regenerates both and fails when the committed output differs from the source, and runs `tools/build_css.py --check` and `tools/flutter_names.py`, which builds the full identifier list from `tokens.json` and fails on a duplicate inside a family, a Dart reserved word or built-in identifier, an illegal identifier, a token with no field, a component README that names a field or token that does not exist, or a component README line that names a deprecated token outside a deprecation note (R4-O13).
- Names (ruling 1), one mechanical rule per family: strip the family prefix in the table, then lowerCamelCase; a name that starts with a digit takes the family letter (`space-4` is `PantasSpace.s4`, `radius-2xl` is `PantasRadius.r2xl`); a name that is a Dart reserved word or built-in identifier takes the family noun as a suffix (`dur-switch` is `PantasDurations.switchDuration`). A name may repeat across families (`PantasCurves.fade` and `PantasDurations.fade`) but never inside one. Colors and type keep the whole name (`text-secondary` is `textSecondary`, `web-row-title` is `webRowTitle`). Every token has a field.

| Family in `tokens.json` | Dart class | Field type | Prefix stripped | Example |
|---|---|---|---|---|
| `color` | `PantasColors` (ThemeExtension) | `Color`; primitives are `static const Color` | none | `text-secondary` is `textSecondary` |
| `type` | `PantasType` | `TextStyle` (rem times 16; letter spacing in px) | none | `web-row-title` is `webRowTitle` |
| `spacing` | `PantasSpace` | `double` | `space-` | `space-4` is `s4` |
| `radius` | `PantasRadius` | `double` (`full` builds a `StadiumBorder`) | `radius-` | `radius-2xl` is `r2xl` |
| `shadow` | `PantasShadow` (ThemeExtension) | `List<BoxShadow>` per theme | `elev-` | `elev-knob` is `knob` |
| `border` | `PantasBorder` | `double` (ring widths) | `border-` | `border-ring-strong` is `ringStrong` |
| `layout` | `PantasLayout` | `double`; `PantasFlex(grow, shrink, basis)` for the flex triples; `bp-*` are `double` | `layout-` | `layout-col-primary` is `colPrimary` = `PantasFlex(1.45, 1, 480)`; `bp-wide` is `bpWide` |
| `size` | `PantasSize` | `double` | `size-` | `size-btn-bar` is `btnBar` |
| `easing` | `PantasCurves` | `Curve` (`Cubic` with the same four numbers; `motion-linear` is `Curves.linear`) | `motion-` | `motion-fade` is `PantasCurves.fade` |
| `duration` | `PantasDurations` | `Duration` | `dur-` | `dur-fade` is `PantasDurations.fade` |
| `zIndex` | `PantasZ` | `int` (paint order of overlays) | `z-` | `z-modal` is `modal` |
| `opacity` | `PantasOpacity` | `double` | `opacity-` | `opacity-disabled` is `disabled` |

- Rem values (`layout-reserve-*`, `size-chart-col`) become logical pixels (rem times 16) multiplied by the text scaler at the use site. `PantasFlex` is laid out by the shell's wrap widget the way CSS flex-wrap does: place items at their basis, wrap when the bases and gaps exceed the width, then share the free space by `grow` (never `Flexible(flex:)`, which takes integers).
- Recipe values that motion.md keeps inside one named recipe (the reveal mark, ripple, panel fades, skeleton crossfade, view swap, pane change, check draw delay, tassel) are generated from motion.md's recipe table into `PantasMotionRecipes` (const `Duration`, delay and `Curve` per recipe, R3-O21), so the code thread never hard-codes them.
- Component READMEs name tokens, not hand-copied field lists (ruling 1): a Flutter section says which tokens a widget reads (`surface-modal`, `elev-knob`) and the field comes from the rule above; today's code field may follow in brackets (`text-secondary` [`secondaryLabel`]) until the code migration. Deprecated names stay until the next major version.
- Colors: CSS `#RRGGBBAA` becomes `Color(0xAARRGGBB)` (`#1D1D1F52` is `0x521D1D1F`). Aliases resolve at generation time per theme.
- Rings are `BorderSide(width, color, strokeAlign: BorderSide.strokeAlignInside)`, never a `BoxShadow` (Flutter has no inset shadow). Elevation tokens become `BoxShadow` lists.
- Letter spacing in em becomes logical pixels per style (`-0.012em` at 17 is `-0.204`). Font sizes in rem become logical pixels (rem times 16).
- Curves become `Cubic(a, b, c, d)` with the same four numbers; durations become `Duration(milliseconds: n)`. `PantasDurations.reduced` (all spatial durations zero, fades 150ms) is returned when `MediaQuery.disableAnimationsOf(context)` is true, so widgets stop checking it one by one.
- `radius-full` becomes `StadiumBorder` or a circle.
- Material: build `ColorScheme` from the roles below, not `ColorScheme.fromSeed`, so stock widgets match. Surfaces follow Material 3 order (R2-O14): `surface` = `bg-page` (Scaffold); `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer` and `surfaceContainerHigh` = `surface-card` (Card, BottomSheet, NavigationBar, menus, Dialog, DatePicker); `surfaceContainerHighest` = `fill`; `surfaceDim` = `bg-page`; `surfaceBright` = `surface-card`; `surfaceTint` = transparent (no tonal elevation). In dark, Dialog and BottomSheet take `surface-modal` through their themes, and their hover and pressed overlays take `surface-modal-hover`. `surface-inset` and `surface-hover` are `PantasColors` fields only. A widget test pumps `AlertDialog`, `showModalBottomSheet`, `Card`, `PopupMenuButton` and `Scaffold` in both themes and compares each painted color to its role.

### Colors
| Role | Code field today | Material ColorScheme slot |
|---|---|---|
| `bg-page` | PantasColors.background | surface, surfaceDim |
| `surface-card` | PantasColors.surface | surfaceContainerLowest, surfaceContainerLow, surfaceContainer, surfaceContainerHigh, surfaceBright |
| `surface-modal` | new field | dialogTheme, bottomSheetTheme (dark) |
| `surface-inset` | PantasColors.pickerBackground |  |
| `surface-hover` | WebTokens.rowHover |  |
| `surface-modal-hover` | new field | dialog and sheet overlay color |
| `scrim-search` | new field |  |
| `hero-start`, `hero-mid`, `hero-end`, `topic-done-end`, `share-end` | new fields (gradient stops) |  |
| `on-hero`, `on-hero-secondary` | new fields |  |
| `fill` | PantasColors.fill | surfaceContainerHighest |
| `fill-skeleton` | PantasColors.skeleton |  |
| `surface-segment-on` | PantasColors.segmentOn |  |
| `edge-card` | PantasColors.cardEdge |  |
| `edge-bar` | webFloatingEdge |  |
| `text-primary` | PantasColors.label | onSurface |
| `text-secondary` | PantasColors.secondaryLabel | onSurfaceVariant |
| `text-on-fill` | PantasColors.onFillLabel |  |
| `text-on-tint-secondary` | new field |  |
| `text-disabled` | PantasColors.disabledActionLabel, WebTokens.disabledText |  |
| `icon-muted` | new field |  |
| `icon-chevron` | PantasColors.chevron |  |
| `divider` | PantasColors.separator | outlineVariant |
| `divider-strong` | WebTokens.strongDivider |  |
| `border-control` | PantasColors.controlOutline | outline |
| `accent` | PantasColors.accent | secondary, tertiary |
| `accent-fill` | PantasColors.accentFill | primary |
| `accent-fill-hover` | WebTokens.accentHover |  |
| `accent-hover` | WebTokens.tintText |  |
| `accent-tint` | PantasColors.accentTint | primaryContainer, secondaryContainer |
| `accent-tint-hover` | WebTokens.secondaryHover |  |
| `accent-tint-text` | PantasColors.accentTintText | onPrimaryContainer, onSecondaryContainer |
| `on-accent` | PantasColors.onAccent | onPrimary |
| `kbd-on-fill` | new field |  |
| `accent-bar` | PantasColors.floatingRight |  |
| `danger` | PantasColors.destructive | error |
| `danger-text` | PantasColors.wrongText | onErrorContainer |
| `danger-text-hover` | new field |  |
| `danger-fill` | WebTokens.dangerFill |  |
| `danger-fill-hover` | WebTokens.dangerHover |  |
| `danger-tint` | PantasColors.wrongTint | errorContainer |
| `danger-bar` | PantasColors.floatingWrong |  |
| `danger-muted` | new field |  |
| `on-danger` | PantasColors.onDestructive | onError |
| `warning-text` | PantasColors.warningText |  |
| `warning-tint` | new field |  |
| `warning-tint-text` | new field |  |
| `pro` | PantasColors.pro |  |
| `on-pro` | new field |  |
| `switch-off` | css .sw |  |
| `switch-thumb` | PantasColors.switchThumb |  |
| `toast-bg` | PantasColors.toastBackground | inverseSurface |
| `toast-text` | PantasColors.onToast | onInverseSurface |
| `toast-action` | PantasColors.toastAction | inversePrimary |
| `toast-action-hover` | new field |  |
| `scrim` | WebRootModal literals | scrim |
| `liquid-start` | PantasColors.liquidStart |  |
| `liquid-end` | PantasColors.liquidEnd |  |
| `chart-1` | new field |  |
| `chart-2` | new field |  |
| `chart-3` | new field |  |
| `chart-4` | new field |  |
| `chart-5` | new field |  |
| `figure-bg` | PantasColors.figureBackground |  |
| `figure-reader-bg` | PantasColors.readerFigureBackground |  |
| `figure-viewer-bg` | PantasColors.figureViewerBackground |  |
| `figure-on-viewer` | PantasColors.onFigureViewer |  |
| `figure-scrim` | WebTokens.figureScrim |  |
| `figure-caption` | WebTokens.figureCaption |  |
| `reader-body` | PantasColors.readerBody |  |
| `reader-strong` | PantasColors.readerStrong |  |
| `reader-deep` | PantasColors.readerDeep |  |
| `reader-note-text` | PantasColors.readerNoteText |  |
| `reader-mistake` | PantasColors.readerWarn |  |
| `reader-mistake-tint` | PantasColors.readerWarnTint |  |
| `reader-mistake-text` | PantasColors.readerWarnText |  |

Code fields with no role: `shadow` and `transparent` (literals), `switchThumbShadow` and `segmentedShadow` (now `elev-knob` and `elev-segment`), `inactiveDateLabel` and `tertiaryLabel` (now `text-secondary`), `choiceOutline` and `pendingMark` (now `border-control` and `divider-strong`).

### Type
- Phone (`PantasType`): `largeTitle` = `phone-large-title`; `pageTitleCompact` = `phone-title-1` (`pageTitle` 30 folds in, D19); `sectionHero` 24 folds into `phone-title-2`; `body` = `phone-body`; `rowValue` = `phone-body` in `text-secondary`; `emphasized` = `phone-headline`; `subhead` 15/400 = `phone-explanation` metrics at 1.35; `subheadStrong` 15/600 = new; `footnote` = `phone-footnote`; `sectionHeader` = `phone-section-header`; `caption` 11 folds into `phone-caption` 12; `captionSmall` and `captionStrong` = `phone-caption-small`; `mathSerif` is a `copyWith` of the parent style (no math style). New fields: `title2`, `title3`, `question`, `readerBody`, `callout`, `subheadMedium`, `explanation`, `footnoteStrong`, `displayS`, `displayM`, `displayL`.
- Wide (`WebTokens`): `h1`, `h2`, `h3`, `qtext` (`web-question`), `big` (`web-big-numeral`), `sub`, `sm` (`web-small`), `eb` (`web-eyebrow`), and the inline lead 17 (`web-lead`). New fields for every other `web-*` style. The generator writes one `TextStyle` per style into `PantasType` (`webRowTitle`, `phoneBody`), and components read only these.
- Material `TextTheme` (R2-O15), so stock widgets (TextField, AlertDialog, SnackBar, TabBar, DatePicker) use Pantas type. Phone theme: displayLarge `phone-display-m`, headlineLarge `phone-large-title`, headlineMedium `phone-title-1`, titleLarge `phone-title-2`, titleMedium `phone-headline`, bodyLarge `phone-body`, bodyMedium `phone-callout`, bodySmall `phone-footnote`, labelLarge `phone-headline` (buttons), labelMedium `phone-subhead`, labelSmall `phone-caption`. Wide theme: displayLarge `web-display`, headlineLarge `web-h1`, headlineMedium `web-h2`, titleLarge `web-h3`, titleMedium `web-title-sm`, bodyLarge `web-lead`, bodyMedium `web-body`, bodySmall `web-small`, labelLarge `web-button`, labelMedium `web-label`, labelSmall `web-caption`.

### Type slots
Every text slot in the bundle and its style (generated by `tools/build_css.py`; ruling 7). A weight entry is a state or a named emphasis modifier (the build fails on a rest weight, R3-O09); "glyph box" is the line-height-1 exception.

| Selector | Type style | Weight override | Line height |
|---|---|---|---|
| `.btn` | `web-button` |  |  |
| `.btn--lg` | `web-button-lg` |  |  |
| `.btn--phone` | `phone-headline` |  |  |
| `.btn--pill-sm` | `web-link` |  |  |
| `.btn--xs` | `web-label` |  |  |
| `.btn--notice` | `web-link` |  |  |
| `.btn--text-phone` | `phone-headline` |  |  |
| `.btn--text-phone-sm` | `web-link` |  |  |
| `.kbd` | `web-key-hint-sm` |  |  |
| `.btn--primary .kbd` | `web-tag` |  |  |
| `.hint-text` | `web-small` |  |  |
| `.link` | `web-link` |  |  |
| `.back` | `web-row-title` |  |  |
| `.back--phone` | `phone-body` |  |  |
| `.card__foot-text` | `web-sub` |  |  |
| `.link-tile` | `web-row-title` |  |  |
| `.row` | `web-row-title` |  |  |
| `.row__title--strong` | inherits | 600 |  |
| `.row__sub` | `web-row-sub` |  |  |
| `.row__v` | `web-row-value` |  |  |
| `.row--settings .row__title,.row--settings .row__v` | `web-row-title-settings` |  |  |
| `.row--phone .row__title` | `phone-body` |  |  |
| `.row--phone .row__sub` | `phone-footnote` |  |  |
| `.row--phone .row__v` | `phone-body` |  |  |
| `.group__head` | `web-eyebrow` |  |  |
| `.group__foot` | `web-small` |  |  |
| `.group-note` | `web-small` |  |  |
| `.notice__title` | `web-title-sm` |  |  |
| `.notice__text` | `web-sub` |  |  |
| `.notice--phone .notice__text` | `phone-footnote` |  |  |
| `.dialog__title` | `web-h3` |  |  |
| `.dialog__body` | `web-body` |  |  |
| `.dialog--phone .dialog__title` | `phone-title-3` |  |  |
| `.dialog--phone .dialog__body` | `phone-explanation` |  |  |
| `.drawer__title` | `web-h3` |  |  |
| `.sheet__title` | `phone-title-3` |  |  |
| `.popover__item` | `web-row-value` |  |  |
| `.popover__item:is(.is-selected,[aria-selected="true"],[aria-checked="true"])` | inherits | 600 |  |
| `.toast` | `web-row-value` |  |  |
| `.toast__action` | `web-link` |  |  |
| `.toast--phone` | `phone-subhead` |  |  |
| `.field__label` | `web-field-label` |  |  |
| `.field__opt` | inherits | 400 |  |
| `.field input,.field textarea` | `web-row-title-settings` |  |  |
| `.field--multi textarea` | `web-body` |  |  |
| `.field__msg` | `web-small` |  |  |
| `.search` | `web-sub` |  |  |
| `.search--phone` | `phone-body` |  |  |
| `.select` | `web-row-title-settings` |  |  |
| `.popover__empty` | `web-sub` |  |  |
| `.seg__btn` | `web-label` |  |  |
| `.seg__btn:not(:is([aria-selected="true"],[aria-checked="true"],[aria-pressed="true"],.is-on))` | inherits | 500 |  |
| `.choice__label` | `web-row-title-settings` |  |  |
| `.choice-group > legend` | `web-field-label` |  |  |
| `.slider__a` | `web-label` |  | 1 (glyph box) |
| `.slider__a--lg` | `web-stat-unit` |  |  |
| `.slider__value` | `web-link` |  |  |
| `.tag` | `web-tag` |  |  |
| `.pro` | `web-pro` |  |  |
| `.avatar` | `web-glyph` |  |  |
| `.avatar--lg` | `web-h3` |  | 1 (glyph box) |
| `.wd small` | `web-key-hint-sm` |  |  |
| `.wd b` | `web-nav` |  |  |
| `.wd.is-off small,.wd.is-off b` | inherits | 400 |  |
| `.wd.is-today small` | inherits | 700 |  |
| `.wd.is-today b span` | `web-label` | 700 |  |
| `.week--phone .wd small` | `phone-caption-small` |  |  |
| `.week--phone .wd.is-today small` | inherits | 700 |  |
| `.cal b` | `web-glyph` |  |  |
| `.cal small` | `web-pro` |  | 1 (glyph box) |
| `.exam-chip__name` | `web-chip-name` |  |  |
| `.exam-chip__days` | `web-small` |  |  |
| `.month-cell` | `web-nav` |  |  |
| `.month-cell:is(.is-selected,[aria-selected="true"],[aria-pressed="true"])` | inherits | 700 |  |
| `.month-cell:is(.is-past,:disabled,[aria-disabled="true"])` | inherits | 400 |  |
| `.date-grid__dow` | `web-key-hint-sm` |  |  |
| `.date-cell` | `web-nav` |  | 1 (glyph box) |
| `.date-cell:is(.is-today,[aria-current="date"])` | inherits | 700 |  |
| `.date-cell:is(.is-selected,[aria-selected="true"])` | inherits | 700 |  |
| `.date-cell:is(.is-past,:disabled,[aria-disabled="true"])` | inherits | 400 |  |
| `.wheel__opt` | `phone-wheel` |  |  |
| `.wheel__opt:is(.is-selected,[aria-selected="true"])` | inherits | 500 |  |
| `.choice-tile__name` | `web-title-sm` |  |  |
| `.choice-tile__sub` | `web-small` |  |  |
| `.choice-tile--day .choice-tile__sub` | `web-tag` |  |  |
| `.choice-tile--day .choice-tile__name` | `web-h3` |  |  |
| `.choice-tile--plan .choice-tile__name` | `web-link` |  |  |
| `.choice-tile__amount` | `web-h2` |  |  |
| `.choice-tile__period` | `web-sub` |  |  |
| `.gauge__label` | `web-sub` |  |  |
| `.stat-row__top` | `web-row-title-settings` |  |  |
| `.stat-row__v` | `web-stat-value` |  |  |
| `.stat-row.is-empty .stat-row__v` | inherits | 400 |  |
| `.timer__time` | `web-timer` |  |  |
| `.opt` | `web-option` |  |  |
| `.opt__badge` | `web-link` |  | 1 (glyph box) |
| `.opt .math` | inherits | inherit |  |
| `.opt:is(.is-selected,[aria-checked="true"]) .opt__badge` | inherits | 700 |  |
| `.opt.is-right` | inherits | 600 |  |
| `.opt--phone` | `phone-option` |  |  |
| `.xcard__key` | `web-link` | 700 | 1 (glyph box) |
| `.xcard__label` | `web-eyebrow` |  |  |
| `.xcard__body` | `web-explanation` |  |  |
| `.xpl-phone__label` | `phone-footnote-strong` |  |  |
| `.xpl-phone__body` | `phone-explanation` |  |  |
| `.fbar__hint` | `web-small` |  |  |
| `.cnt` | `web-link` |  |  |
| `.qnav__q` | `web-field-label` |  | 1 (glyph box) |
| `.qnav__q:is(.is-current,[aria-current="step"])` | inherits | 700 |  |
| `.rblock__head` | `web-link` |  |  |
| `.rblock__body` | `web-reader-block` |  |  |
| `.frac` | inherits |  | 1.15 (glyph box) |
| `.rblock__solution-label` | `web-eyebrow` |  |  |
| `.math--display` | `math-display` |  |  |
| `.passage__label` | `web-eyebrow` |  |  |
| `.passage__text` | `web-reader-body` |  |  |
| `.passage__paras > li::marker` | `web-small` |  |  |
| `.passage__source` | `web-small` |  |  |
| `.passage--phone .passage__text` | `phone-reader-body` |  |  |
| `.figure__cap` | `web-small` |  |  |
| `.fviewer__zoom-level` | `web-row-sub` |  |  |
| `.fviewer__cap` | `web-sub` |  |  |
| `.chart__summary` | `web-sub` |  |  |
| `.chart__legend` | `web-caption` |  |  |
| `.chart__y` | `web-caption` |  |  |
| `.chart__y > span` | inherits |  | 1 (glyph box) |
| `.chart__clipped` | `web-caption` |  |  |
| `.chart__val` | `web-tag` |  |  |
| `.chart__x` | `web-caption` |  |  |
| `.chart__col.is-current .chart__x` | inherits | 600 |  |
| `.chart__empty` | `web-sub` |  |  |
| `.dtable` | `web-row-value` |  |  |
| `.dtable caption` | `web-title-sm` |  |  |
| `.dtable th` | `web-eyebrow` |  |  |
| `.sidebar__brand` | `web-h3-lg` |  |  |
| `.nav-item` | `web-nav` |  |  |
| `.nav-item:is(.is-on,[aria-current="page"])` | inherits | 600 |  |
| `.sidebar__who-name` | `web-label` |  |  |
| `.sidebar__who-plan` | `web-caption` |  |  |
| `.tabbar__item` | `phone-tab-label` |  |  |
| `.tabbar__item:is(.is-on,[aria-current="page"])` | inherits | 600 |  |
| `.focus-head__title` | `web-row-sub` |  |  |
| `.phone-screen .phone-large-title,.shell:not(.shell--desktop) > .main :is(.web-h1,.phone-large-title)` (phone-screen (max-width:12rem)) | `phone-title-2` |  |  |
| `.reader` | `web-reader-body` |  |  |
| `.reader__col strong` | inherits | 600 |  |
| `.reader--phone` | `phone-reader-body` |  |  |
| `.reader-bar__count` | `web-small` |  |  |
| `.reader-bar__lesson` | `web-label` |  |  |
| `.tooltip` | `web-caption` |  |  |
| `.search-panel__field input` | `web-search-input` |  |  |
| `.search-group__label` | `web-eyebrow` |  |  |
| `.search-result__title` | `web-title-sm` |  |  |
| `.search-result__sub,.search-result__snippet` | `web-row-sub` |  |  |
| `.search-result__v` | `web-row-value` |  |  |
| `.search-panel__foot` | `web-small` |  |  |
| `.search-panel__field input` ((max-width:599px)) | `phone-body` |  |  |
| `.hero-list > li` | `phone-subhead` |  |  |
| `.fine-print` | `web-small` |  |  |
| `.acc-row__label` | `web-row-sub` |  |  |
| `.acc-row__v` | `web-row-value` |  |  |
| `:is(.choice--parent,.choice--all) .choice__label` | `web-title-sm` |  |  |
| `.choice__meta` | `web-small` |  |  |
| `.pbar-head__label` | `web-label` |  |  |
| `.pbar-head__value` | `web-small` |  |  |
| `.slider__end` | `web-small` |  |  |
| `.spinner__label` ((prefers-reduced-motion: reduce)) | `web-row-sub` |  |  |

### Spacing, radius, shadow, motion
- Fields follow the family table above; `PantasShape.gutter` and `rowInset` become `PantasLayout.gutterPhone` and `rowInset`; `groupRadius` (14) is `PantasRadius.lg`, `cardRadius` (18) `xl`, `pillRadius` `full`.
- `PantasShadow`: one `List<BoxShadow>` per `elev-*` token per theme, in four levels (README Radius and elevation).
- `PantasCurves` and `PantasDurations` replace the code's classes of the same names: `tap` is `dur-short-1`, `release` `dur-short-3`, `quick` 160 folds into `dur-short-2` 150 (D93), `base` is `dur-medium-1`, `page` `dur-medium-2`. Durations hold the scale (`short1` to `long3`) for generic motion and the one-off values, each with a single owner (motion.md).
- Breakpoints (`PantasLayout`): `bpPhoneNarrow` 400, `bpTabletPortrait` 600, `bpTabletLandscape` 1024, `bpWide` 1440, `bpFocusSplit` 1134, read from the window width on every platform (native tablets too).

## Decisions

Each line: what, from, to, why. CHANGE means a value already drawn or built moved. Everything else is a value chosen where the sources were silent. Every line is final when recorded: Aedwon delegated these decisions ("um you can decide for me based on the design system and whichever is the best for UX. for refinements, please ensure the following are being considered * WCAG 2.0 AA * Apple HIG", Nov 8; "you decide for me (unless it's something absolutely necessary that I decide)", earlier). Only a decision he keeps for himself, or one that is absolutely necessary for him, goes to him. A status in brackets ends a line; `governance.md` lists the statuses and the approval rule.

### Open items
Not decisions: work that waits on a missing file or on app code. Nothing here needs Aedwon's ruling.
- D41: the icon files (Phosphor) are not uploaded. Previews use drawn glyphs.
- D91: the Source Serif 4 font files are not bundled. Load them from Google Fonts until the code thread bundles them.
- D170: the Mock exam phone layout waits on the quiz code. Until the quiz migration adds the type swaps below 600, build focus pages with the phone variants.

### Color
1. `text-muted`: `#8A8A8E` (3.4:1) to `#707074` (4.9:1 on white, 4.5:1 on `#F5F5F7`). Lightest gray that passes. [Superseded by D47: merged into `text-secondary`.]
2. `icon-chevron`: `#B8B8BD` and `#C7C7CC` (2.0:1) to `#8F8F93` (3.2:1 on white, 3.0:1 on the hover well). Meets 3:1.
3. Near-whites folded: `#F2F2F5` into `surface-hover` `#F7F7F9`; `#E9E9EE` placeholder into `fill-skeleton` `#E6E6EA`; `#E9E9EE` ghost hover into `fill`. One value per role.
4. Red tint `#FDE8EA` to `#FDECEE`; right bar `#EEF8F5` to `#EFF7F5`; toast action `#7FD4C4` and `#7FD6C5` to `#7FD8C6`; link hover `#075C4E` to `#086A5A`. One value per role.
5. Pro mark: teal on tint to gold `#D9A400` with ink text `#1D1D1F` (new token `on-pro`, 7.4:1). Code already uses gold; the web boards drew teal.
6. Settings "Your exam" icon: red to teal (`accent`). Red is only for destructive and wrong; the red drew on 64 boards.
7. Unchecked checkbox and radio ring: `#C7C7CC` (1.7:1) to `border-control` `#8A8A8E` (3.4:1). Dark: `#3D3D3D` (1.5:1) to `#8E8E93` (5.1:1). Meaningful control boundaries need 3:1.
8. Dark teal icon and ring `#1A957F` (white on it 3.7:1) to `accent` `#4CC3AC`. Three dark teals become two (fill `#0F8571`, accent `#4CC3AC`).
9. Past dates: `#C7C7CC` in both themes to alias `text-disabled`. [Superseded by D48.]
10. Key hint inside a primary button: white 16% chip with 88% white text (3.4:1) to black 16% chip with white text (6.9:1 light, 6.0:1 dark). Fails 4.5:1 otherwise.
11. Tonal button hover: label `#0B7A68` on `#D6EBE6` (4.2:1) to label `accent-hover` `#086A5A` (5.2:1).
12. Gray text on `fill` (gray tag): `text-secondary` (4.3:1) to `text-on-fill` `#636366` (5.1:1). The code already has this role.
13. Ghost hover: a gray `#EDEDF0` well to the label color at 8%, with the label turning `text-primary` (neutral), `accent-hover` (teal) or `danger-text-hover` (red). Nav, icon button and counter hovers (alpha .04, .045, .05) fold into the same 8%.
14. Scrim: web `#1D1D1F` at .32 and .22, phone black at .34 and .32, to one per theme: ink at .32 in light, black at .28 in dark. [Amended by D51: dark]
15. Accuracy ramp: five named steps. [Superseded by D46.]
16. Failing control rings kept from the source. [Resolved by D45: fixed to 3:1.]
17. Values chosen with no source: `accent-tint-hover` dark `#1E3C35`; `accent-fill-hover` dark `#0E7967` (derived in code, no board); `accent-hover` dark `#7FD8C6`; `danger-text-hover` dark `#E0706B`; dark elevations for popover, drawer, modal and sheet. [Amended by D51: small dark elevations]

### Type
18. One size per role (CHANGE): h1 34, 36, 42, 48 to 38; h2 24, 30 to 26; eyebrow 12 to 13; small 14 to 13; sub 16 to 15. A hero uses `web-display` 48/700/1 (taken from the 45 ring-percentage boards).
19. Phone title 1: boards draw 30/1.12 (35 uses) and code `pageTitle` is 30; the ruling is 28/1.2. Code `sectionHero` 24, caption 11 and caption-small 10/500 fold to `phone-title-2` 22, `phone-caption` 12 and `phone-caption-small` 10/600.
20. Reader body: phone code 16/1.6 to 17/1.55 (canvas); desktop 18/1.7 from code.
21. Math font: the handoff says Source Serif 4; the app renders KaTeX_Main and does not bundle Source Serif 4. [Superseded by D91]
22. Letter-spacing -0.012em is kept on phone 17px and larger text. Desktop body has none.

### Spacing, radius and size
23. Row vertical padding 15 to 13 (476 rows use 13). 13 stays, as most approved board rows draw it. [Lead ruling (delegated, Nov 7)] [Resolved by D179]
24. Phone section gap 22 to 24 (4-multiple rule).
25. Two-column pairs: seven drawn pairs become three. [Amended by D67: four.]
26. Card radius 16 and 20 to 18 (360 and 41 cards).
27. Radius 9 (nav items, exam chip, 345 uses) to 10; in-button key hint 6 to 5; phone notice 14 to 16; phone dialog 20 to 22; phone floating bar 60/30 to 64/32. [Amended by D73: radius values]
28. Sheet top radius: canvas draws 22; the ruling and the app code say 14. 14 is used.
29. Pills to rounded rectangles (Nov 7 rule): phone dialog pair 46px (r99 to 14), phone compact buttons (r99 to 12), floating-bar counter and action 46px (r99 to 14). The TabBar and its active item stay pill-shaped: they are navigation, as the approved phone boards draw them. [Lead ruling (delegated, Nov 7)] [Amended by D187: the dialog pair and the floating-bar buttons are pills again] [Amended by D189 and D190: the compact pill the onboarding board draws returns as `btn--pill-sm`; other phone compact buttons stay rounded]
30. Button heights: secondary and tertiary 42 (boards) and 44 (code). Default is 44 everywhere; 42 is `btn--sm` for rows and for wide dialog actions (notices are `btn--notice` 44, phone dialogs `btn--dialog` 46; D189). Large 50 is only for the one action a page exists for.
31. Press scale: 0.96 (web code), 0.97 (CTA), 0.98 (options) to 0.97 for buttons and 0.98 for options.
32. Toast Undo target 31 to 44px. The 32px icon button gets a 44px hit area.
33. Checkbox radius 7 is kept from the stylesheet (boards draw 6 in 55 uses). [Superseded by D73: 8.]

### Motion
34. The house curve `(.3,.9,.3,1)` is folded into `motion-enter` `(.2,.9,.3,1)` for entrances. [Amended by D77: overlays]
35. Drawer, sheet and dialog curves become `motion-enter`. [Superseded by D77: phone code curves restored.]
36. Popover: boards drop in from 6px above in 200ms; code rises 8px in 240ms. Code used.
37. Rise offset 10 (desktop) and 14 (phone) to 14. Push offset 24 (desktop) and 40 (phone) to 40. Pop overshoot 1.12 (boards, code) to 1.08 at 60% (ruling). Pop duration 350 to 500 to 420. [Amended by D113: the 1.08 peak is now the drawn peak]
38. Rings fill in 900ms after a 300ms wait; the ruling listed 600ms for rings. Gauges fill in 1400ms (D79). Bars fill in 600ms. Boards use 800 to 1400. Rings stay 900 after 300, as the phone boards draw them (phone is the motion reference). [Lead ruling (delegated, Nov 7)]
39. Shake on a wrong answer is removed. 18 boards still draw it. The Mock finale's deduction shake is choreography and stays (motion.md rule 8).
40. Reduced motion: boards force 1ms and loop forever (strobing). Now every loop stops. [Amended by D81.]

### Sources and gaps
41. No icon files exist in the sources. Previews use plain drawn glyphs. The set is now named (Phosphor) and the needed glyphs are listed under Iconography; the files are still missing.
42. The mark is drawn from `pantas_logo.dart` exactly (paths and viewBox). No separate logo file exists.
43. Components not in any board but needed for completeness: `Popover` items, `Checkbox` mixed state, the busy and done Button, disabled and focus states everywhere. Their values come from the closest drawn state and the rulings.

### Round 1: color
44. Token tiers: 79 primitives hold every hex once; roles alias them per theme; identical pairs became aliases (`reader-deep` light = `bg-page`, `accent-bar` dark = `accent-tint`, `accent-hover` light = `accent-fill-hover`, `danger-text-hover` dark = `danger-text`, `liquid-end` light = `accent`). No value changed. `reader-warn*` renamed `reader-mistake*`: the card is the lesson's "Traps to Watch For", so red stays (it marks what learners get wrong).
45. CHANGE: control boundaries meet 3:1 (resolves D16). Field, search, select and white-button rings `divider` (1.3:1) to `border-control` (3.4:1); answer letter badge ring `divider-strong` (1.5:1) to `border-control`; the switch off track gains a 1.5px `border-control` ring; the not-started task marker `#C7C7CC` to `border-control`.
46. CHANGE: accuracy ramp (resolves D15). Light `#52A294`, `#409889`, `#2E8E7E`, `#1D8473`, `#0B7A68`: step 1 is the lightest point on the code's own line (`#CFE8E2` to `#2F8F7E`) that holds 3:1 on white, and the steps run to `accent-fill`. Dark `#2E7566`, `#337F70`, `#3C9583`, `#44AC97`, `#4CC3AC`: dimmer means lower (the old dark ramp was brightest at the lowest accuracy); step 1 raised to 3:1. One rule on both platforms: below 45, 45 to 54, 55 to 64, 65 to 74, 75 and up, with no interpolation (the code's `accuracyTint` lerp goes).
47. CHANGE: `text-muted` merges into `text-secondary` (resolves D1): light `#707074` to `#6E6E73`, dark `#949494` to `#A3A3A3`, for placeholders, hints and tab labels. `text-muted` stays one release as a deprecated alias.
48. CHANGE: past dates (`text-past`) alias `text-secondary`, weight 400, instead of `text-disabled` (2.2:1). A date is readable content.
49. CHANGE: dimmed content uses color, not opacity. Dimmed answer options (42% opacity, about 2.6:1) and dim rows (45%) now use `text-secondary` text; a dimmed option's badge ring is `divider`.
50. CHANGE (dark): roles that shared `#2A2A2A` separate. `surface-inset` to the card `#1F1F1F` (the approved dark board draws the footer as the card with a rule); `fill` to `#303033`; `fill-skeleton` to `#2C2C2C`; `text-disabled` `#949494` to `#6B6B6B`, one step below secondary as in light.
51. CHANGE (dark): floating surfaces separate from the page. Toast `#1D1D1F` (1.1:1 on the page) to `#3A3A3C` with a 1px `#4A4A4A` edge and shadow alpha .6; `elev-nav-active`, `elev-segment` and `elev-knob` alpha to .5; scrim black 28% to 48%. No dark board draws these; check against one when it exists.
52. CHANGE: unselected segment labels `text-secondary` (4.3:1 on fill) to `text-on-fill` (5.1:1).
53. New role `text-on-tint-secondary` `#5E6E6A` (4.6:1 on `accent-tint`) for the subtitle of a selected row; dark aliases `text-secondary`. Value chosen.
54. CHANGE (dark): `warning-text` `#D9A400` (the Pro gold) to `#F0A35A` (7.9:1), so gold marks only Pro. New `warning-tint` `#FFF1E5` (board `.tago`) and `warning-tint-text` (light = `warning-text`); dark `#33281A` and `#F2C27A` are chosen.
55. New role `danger-muted` `#F4AFAF` (the finale's wrong answers, drawn with no token); dark `#5A2C2A` is chosen.
56. CHANGE: an invalid field drops the red wash and keeps `surface-card` with the 2px `danger` ring, icon and sentence. The boards drew no error state; the wash put `text-secondary` placeholders at 4.3:1.
57. Red rule wording: an invalid field is a wrong input, so it stays red. "Wrong" covers wrong answers, invalid entries and the common-mistake lesson card. [Lead ruling (delegated, Nov 7)]
58. CHANGE (dark): the active TabBar label and icon `#4CC3AC` to `accent-tint-text` `#7FD8C6`, because text on `accent-tint` uses `accent-tint-text`. Both pass.
59. Notice tones: default (info, teal icon), success (teal check), warning (orange icon). The review proposed a red critical tone; it is dropped because red never marks a status.

### Round 1: type
60. Type sizes move to rem (16px = 1rem): no visual change at default size. Line heights added to the 14 styles that had none: buttons, nav, segments and back link 1.25 (the stylesheet used 1, which clips a wrapped label), links, rows, tags and the Pro mark 1.3, key hints 1.2, eyebrow 1.35. Chosen.
61. New styles from the boards: `web-h3-lg` 22/700 (call-to-action title; line height and tracking chosen from `web-h3`), `web-label` 14/600 and `web-caption` 12 (sidebar account, now as the board draws it instead of 15/500 and 13), `web-stat-unit` 22/600, `web-row-title-settings` 16, `phone-explanation` 15/400/1.5, `phone-footnote-strong` 13/500. CHANGE for the sidebar account block (toward the board).
62. CHANGE: phone explanation text 17 to 15/1.5, as the phone board draws it.
63. CHANGE: ExamChip month 9/700 to 11/700 (9px was unreadable).
64. CHANGE: settings row title 17 and value 15 to 16, as the Settings boards draw them.
65. CHANGE: CardFooter caption 14 to 15, as approved Main and pantas.css draw it.

### Round 1: spacing, layout and size
66. CHANGE: `layout-section-gap` 26 to 28, so one block gap exists (it equals `layout-cols-gap`). Every page moves 2px per gap.
67. CHANGE: a fourth column pair, list and detail (1 1 300 max 360, 999 1 460), as about 60 Settings boards draw it (amends D25).
68. Wide means 1024px and up for natural-width buttons, P2, the desktop type scale and hover affordances; tablet portrait (600 to 1023) uses the phone rules in a 640 column. TabBar serves every width below 1280, centered at 358 on tablets. Focus mode splits at 1134; below it the explanation opens as a Drawer. [Lead ruling (delegated, Nov 7)] [Amended by D136]
69. CHANGE: phone week-day cells 34 to 44 wide, so each day is a 44px target (7 x 44 + 6 x 4 + 20 = 352 of 358).
70. Targets by input. Touch 44 (padded hit areas: no visual change for small buttons, back link, segments, popover items, nav items); pointer 32 preferred, 24 minimum. Sidebar items (40) and sidebar search (38) are pointer-only. Replaces "targets are 44px at least". [Lead ruling (delegated, Nov 7)]
71. CHANGE: on phones narrower than 400px the quiz bar's flag moves to the question header so "Not this one" fits on one line (at 358px the counter, flag and Next left 84px for the hint). This changes the approved phone bar layout. [Lead ruling (delegated, Nov 7)] [Approved by Aedwon, Nov 8: "the flag reposition is okay"] Ruling 9 (round 2) places it at the right end of the question header.
72. CHANGE: `btn--bar` padding is symmetric 22px unless a key hint follows the label (then 22 and 14). The old padding off-centered labels with no hint.

### Round 1: radius
73. CHANGE: size-named radius scale (resolves D26, D27, D33). Checkbox 7 to 8; 42px buttons 11 to 12; sidebar items 10 to 12; search, segmented track and exam chip 10 to 8; notice and answer option 16 to 14; explanation card 20 to 18; onboarding tiles 16 to 14; Home link tiles 16 to 18; month cells 10 to 12; skeleton lines 6 to 5; pills 99 to 9999 (no visible change). Rule: under 40 `radius-sm`, 40 to 44 `radius-md`, 46 and up `radius-lg` (the review said 40 to 46 `md`; 46px buttons keep 14 as drawn). The back link keeps 11 (`radius-back`) because back link A is a fixed decision.

### Round 1: buttons
74. Button kinds become primary, secondary, neutral and tertiary with tones accent and critical; old class names stay as aliases (removed in 3.0.0, D118). `btn--outline-red` is the secondary kind in the critical tone and `btn--white` stays for the places the boards draw it; neither is deprecated, and no board changes. The review's height merge (42 to 44, 50 to 52, phone badge 30 to 32) is not applied: it conflicts with its own `btn--sm` rule and changes approved sizes. [Lead ruling (delegated, Nov 7)]
75. New neutral button (`btn--neutral`, gray `fill`), replacing an inline hack in the phone dialog pair. Hover: `text-primary` at 8% over `fill`. Chosen.
76. Busy button: width locked to its rest width, `aria-disabled` while busy (focus kept), verb and result announced politely; the done state returns to rest after 1.5s. Chosen.

### Round 1: motion
77. CHANGE (back to code, amends D34 and D35): overlays use the phone code curves. Dialog opens 420 and closes 320 on `motion-house` `(.3,.9,.3,1)`; drawer and sheet open 450 and close 400 on `motion-slide` `(.2,1,.35,1)`; the dialog scrim fades 300 linear (code) instead of 150; drawer and sheet scrims 350 `motion-fade`; toasts on `motion-house`.
78. Choreography curves become tokens with their exact values: `motion-gauge` `(.2,.8,.25,1)`, `motion-scroll` `(.22,1,.36,1)`, `motion-pop-b` `(.3,1.5,.5,1)`, `motion-burst` `(.15,.7,.35,1)`. No value changed.
79. Duration tokens are renamed to a scale (`dur-short-1` to `dur-long-3`) and same-valued names merge (pop and dialog open, rise and drawer open, page and dialog close, fill and spin, push and check). No duration changed. New `dur-gauge` 1400 (app half gauge), `dur-toast` 4000, `dur-toast-action` 8000. Stagger stays 80 (phone); the review suggested 60 from the desktop `.up` boards.
80. Approved motion is now built in `bundle.css`, not only described: sliding markers for TabBar and SidebarNav, overlay exits, the 150ms late reveal, the wrong-cross pop (1.1) and right-check pop (1.15) over 560ms as in the app, the right-answer ripple, check draw, stagger, view swap, pane change, page rise, tassel swing. No value changed.
81. Reduced motion replaces the global 1ms rule (amends D40): no translate, scale or rotate; overlays fade in place at 150ms; color fades stay at 150ms or less; loops stop; the spinner shows a static arc and a visible "Loading" label.
82. Toast timing: 4s, or 8s with an action, paused on hover and focus, one at a time with a queue. The old preview removed the Undo toast after 2.4s. Values from the review; the 2s minimum before a new toast replaces the current one is chosen.
83. The pause screen's blink stays (approved motion). Under reduced motion it is static, which meets WCAG 2.2.2 for users who need it. [Lead ruling (delegated, Nov 7)]
84. Ring fill 900. [Duplicate of D38]

### Round 1: components and behavior
85. New components from the boards: TaskStatus, Gauge, StatRow, SectionHeader, LinkTile, Avatar (30 and 44), Select, Slider, DatePicker, SelectableTile, ProgressBar, Timer, Explanation, QuestionNavigator, ReaderBlock, FocusHeader, and the Layout group (AppShell, Columns, FocusLayout, PhoneFrame, TabletLayout). Values the boards do not give are chosen and named in each component's Status: StatRow paddings, Select default height 48, QuestionNavigator gap 8, ReaderBlock padding 16/18 and radius 14, the Today ring size 34, header and note spacing 8.
86. CHANGE (toward the phone board): the phone right answer shows the check inside the badge, with no mark at the right end; phone options stack 10px apart (desktop 12).
87. CHANGE: the selected week day is a 2px `accent` ring instead of the hover well (1.07:1); Today gains the progress ring board Main draws.
88. Focus rule (amends the README): items whose selected state is an accent ring take a `text-primary` focus ring; an invalid field adds an outer focus outline. Chosen.
89. CHANGE: disabled compound controls use one opacity, `opacity-disabled` 0.4 (was .45 and .42); disabled rows and labels use `text-disabled`.
90. The z-index scale is replaced (nav 20, overlay 40, modal 50, popover 60, toast 70, tooltip 80) so a toast or popover opened from a modal stays above it. No visual change.
91. Source Serif 4 is the design value for math and figure labels, as the approved handoff states. The code thread bundles it and tests it against the math engine before any font swap; KaTeX_Main in the app today is drift. [Lead ruling (delegated, Nov 7)]
92. The lesson text scale covers quiz stems and choices, as the code does (the system said stems only).
93. Code to align with the system: hover fades are 160ms in code and 150ms here; the Material dialog radius is 14 in code and 22 here; the checkbox press .94 is new (no board value); the slider thumb gains a 1px `border-control` ring (CHANGE from the phone board) so it holds 3:1 on white; unselected wheel-picker values use `text-secondary` instead of `#AEAEB2` (CHANGE: they are readable values).
94. Row vertical padding 13. [Duplicate of D23]
95. List-action rows (Sign Out, Delete Account) use `btn--sm` ghost buttons pulled left so the label lines up with the row text; a non-destructive confirm such as Sign Out uses the primary button. Chosen.
96. Behavior the patterns now specify where no source decided it. The offline scope (opened lessons, cached quizzes, a started mock), the offline and sync messages, choreography lifecycles (the result is saved before its animation; a tap settles to the end), the keyboard map (Enter, A to D, F, Esc, Ctrl K; letter keys come from the answer key hints), search results grouped by type, and the notice priority. Chosen to close review gaps. [Lead ruling (delegated, Nov 7)]

### Round 2 (Nov 7)
97. CHANGE: the blank question chip ring in the mock question list `divider-strong` (1.5:1) to `border-control` at 1.5px (3.4:1 light, 5.1:1 dark). Blank versus answered is the main information in a timed mock, and ring present versus absent is the shape cue; each chip's name now carries its state ("Question 12, blank, flagged"). (R2-O07)
98. CHANGE: on a selected row (`accent-tint`), the value `text-secondary` (4.4:1) to `text-on-tint-secondary` (4.6:1) and the chevron `icon-chevron` (2.8:1) to `accent-tint-text` (4.5:1). The Settings list and detail pair shows it. The contrast script now tests every color set inside a tinted or filled block. (R2-O05)
99. CHANGE: spacing on the public scale and the 2px grid (R2-O08). Dialog padding 26 to 24 and gap 18 to 16; phone dialog top 22 to 20; call-to-action card top 26 to 24; sidebar top 22 to 20; section header bottom 9 to 8; floating bar right 9 to 8; in-button key hint 7 to 8; selectable tile 11 to 12. Odd values that hundreds of approved phone rows draw (7, 11, 13) stay, each listed under "Component internals" with its board count.
100. CHANGE: every component font maps to a named style (R2-O01, ruling 7). Snaps under 0.1 line height or one size or weight step: hint, help and footer lines 13/1.3 and 13/1.4 to `web-small` 13/1.45; toast action and counter 15/600/1.2 to `web-link` 1.3; search 15/1.2 to `web-sub` 1.45; month cell 15/500/1.2 to `web-nav` 1.25; card footer caption and gauge label 15/1.4 to `web-sub` 1.45; phone notice text 13/1.4 to `phone-footnote` 1.35; phone buttons 17/600/1.25 to `phone-headline` 1.35; phone dialog body 15/1.45 to `phone-explanation` 1.5; date-picker weekday 11/600/1.3 to `web-key-hint-sm` 1.2; reader solution label 12/600 +0.04em to `web-eyebrow` 13/600 +0.02em; sidebar wordmark 22/700/1.2 -0.02em to `web-h3-lg` 1.3 -0.012em; day tile number 20/700/1.2 to `web-h3` 1.3; 44px avatar initial 19 to 20 (`web-h3`). New styles where the role is real: `web-field-label` 13/600/1.3, `web-title-sm` 16/600/1.3, `web-timer` 17/700/1.2, `web-explanation` 17/400/1.55, `web-reader-block` 16/400/1.6, `math-display` 1.6em.
101. CHANGE: near-duplicate styles merge (R2-O22): `web-seg` into `web-label` (segment labels 1.25 to 1.3), `web-back` into `web-row-title` (back link 1.25 to 1.3), `web-key-hint` into `web-tag` (in-button key hint 1.2 to 1.3). Removed in 3.0.0. `web-pro` and `web-row-title-settings` stay (visible weight; rows need 1.3).
102. CHANGE: one math rule (R2-O03). Inline math 1.12em of its text everywhere (`web-math` was a fixed 21px). Display math `math-display` 1.6em of the reader body, about 29px at 18px (the bundle drew 21px; the README and the boards said 30). Both follow the lesson text scale (R2-O02).
103. Keyboard shortcuts (ruling 1, R2-O12, WCAG 2.1.4): single-letter keys (the item's option letters and F) act only while focus is inside the question region; a Settings row "Keyboard Shortcuts" (Switch, on by default, wide screens only, under Accessibility) turns them off. Modifier shortcuts are unaffected. [Lead ruling (delegated, Nov 7)]
104. Passage component and the passage-question layout (ruling 2, R2-O09). Chosen: the collapsed passage shows four lines; the column is 1 1 480 with a 640 maximum (`layout-passage`, `layout-passage-max`, new, no board). [Lead ruling (delegated, Nov 7)] [Amended by D140]
105. Chart component (ruling 3): bar or line, one teal series, labels HTML at 12px minimum at every width, the plot scrolls sideways when columns run out. Chosen: plot height 220 (`size-chart-h`, new, no board), columns at least 2.75rem, bars up to 28px with radius 5, points 8px, a second series dashed with square markers. Accuracy by topic keeps the five steps in AccuracyBar; a time series is one teal series (usage gap 10). [Lead ruling (delegated, Nov 7)] [Amended by D134]
106. Data values (ruling 4): one custom property `--value` on the element, read by the class (bars, rings, gauges, task partial rings, chart columns). The value is a unitless number from 0 to 100 (`style="--value:62"`), not "62%" as the ruling's example wrote: SVG dash lengths cannot read a percent of the path, and one form for every data component avoids two contracts. [Lead ruling (delegated, Nov 7)] Deviation flagged for the lead.
107. FloatingBar stacked variant (ruling 5): the hint on its own line above the actions, actions right-aligned, main last, no icon-only buttons. Applies automatically in a dock narrower than 17.5em (the 1.5x stacking threshold on a 390 phone) and by `.fbar--stack` (Flutter: text scale above 1.5). Chosen: the stacked bar uses `radius-xl` (18). [Lead ruling (delegated, Nov 7)]
108. Form controls on native inputs (ruling 6): Checkbox, Radio and Switch are `input` elements (Switch `role="switch"`); forms use a native `select`, and the onboarding listbox keeps a hidden input; Field gains a trailing action slot (`.field__action`) used for the date picker. [Lead ruling (delegated, Nov 7)]
109. Type from styles (ruling 7): the bundle's generated block defines `--type-*` and `--tracking-*` from `tokens.json`; components use only these. A state may change the weight; a single-glyph box may set line height 1. The build script fails on anything else. [Lead ruling (delegated, Nov 7)]
110. CHANGE (rename, ruling 8, R2-O16): the phone screen container `.phone-body` (and `--root`, `--tabs`) is `.phone-screen`; `.phone-body` is only the type style. The build fails when a type-style class carries layout. New bottom reserves `.phone-screen--bar`, `--bottom`, `--bottom-2` (usage gap 13).
111. The quiz flag under 400px sits at the right end of the question header (`.page-head--question`), and a page head inside a container that owns its gap has no bottom margin, by rule rather than a wrapper (ruling 9, usage gap 6). [Lead ruling (delegated, Nov 7)]
112. CHANGE (dark): `fill-skeleton` `#2C2C2C` (invisible on the hover well, 1.02:1) to `#3D3D3D` (R2-O20). Invisible folds (R2-O21, under 1.0 CIEDE2000): dark `accent-fill-hover` `#0E7967` to `#0B7A68`; dark `reader-mistake-tint` `#2C1D1C` to `#2E1E1D`; light `icon-chevron` `#8F8F93` to `#8E8E93`; dark `edge-card` `#2C2C2C` to `#2A2A2A`; light `fill-skeleton` `#E6E6EA` to `#E3E3E8`. `teal-550` renamed `gray-550`.
113. The pop draws its ruled peak (R2-O13, amends D37): the keyframes hold the overshoot (1.08 at 60%) and each segment eases without overshoot (`motion-enter`, then `motion-fade`). With `motion-spring` the drawn peak was about 1.15. Flutter: a `TweenSequence` (.4 to 1.08 over 60% on `Cubic(.2,.9,.3,1)`, then to 1.0).
114. New role `surface-modal` for dialogs and sheets: the card in light, `#2A2A2A` in dark, so a dark dialog separates from the dimmed cards (usage gap 24). No dark board draws it. Chosen.
115. Toasts clear what floats at the bottom (R2-O17): `--toast-offset` 104 above a TabBar (24 + 64 + 16), 104 above the focus-mode bar (28 + 64 + 12), 92 above the phone quiz bar. Chosen.
116. Themes follow the OS when no `data-theme` is set (System), and `color-scheme` is set per theme so native controls, scrollbars and autofill match; text selection is `accent-tint` with `text-primary`, the caret `accent` (R2-O26). Appearance offers Light, Dark and System. Chosen.
117. Accuracy steps are measured on their `fill` track, where step 1 is 2.6:1 light and 2.4:1 dark; the bar is exempt as supplementary because the number is always printed (WCAG 1.4.11, option a of R2-O06; amends D46's "holds 3:1 on white"). No value changes.
118. Removed in 3.0.0 (deprecated in 2.0.0, or equal-valued): `text-muted`; the button aliases `btn--tonal`, `btn--ghost`, `btn--ghost-teal`, `btn--ghost-red`, `btn--danger`; `dur-instant` (unused); `size-week-day-phone` (equal to `size-week-day`); `layout-cols-gap` (equal to `layout-section-gap`); styles `web-seg`, `web-back`, `web-key-hint` (D101). Deprecated: `text-past` (an alias of `text-secondary`), removed at the next major.
119. Flutter ColorScheme surfaces follow Material 3 order (R2-O14): `surface` is the page, the low and high containers are the card, the highest is `fill`, no surface tint. Before, `Scaffold` would have painted white and `Dialog` the hover well. Chosen.
120. Usage-test rulings (chosen): results pages stay in focus mode with Done on the title row (gaps 11, 12); the WeekStrip legend sat under the Home header row (gap 20; removed by D186); a static row in a card with chevrons keeps the chevron slot (gap 23); the sidebar search sits 14px above the first destination as drawn (gap 19, CHANGE from 4); the bar hint reads "Check when you are ready" once an answer is picked (gap 14); the answer badge grows with its letter at large text (gap 16). [Amended by D186]

### Round 3 (Nov 8)
121. New role `surface-modal-hover` (R3-O02): light equals `surface-hover`; dark is white at 6% over `surface-modal` (about `#363636`, 1.2:1 on `#2A2A2A`; secondary text 4.7:1 on it). In dark the old well equaled the dialog surface (1.00:1), so rows, cells and white buttons in a Dialog or Sheet showed no hover or press. An alpha literal because no new gray clears the 2.0 CIEDE2000 rule between `#303030` and `#3A3A3C`. Chosen.
122. A completed row that is also selected colors its title `text-on-tint-secondary` (4.6:1 light; `text-secondary` was 4.4:1 on `accent-tint`), R3-A06. Chosen.
123. CHANGE (dark): `danger-text-hover` `#E0706B` (it fell to 4.1:1 over its 8% wash on the dialog surface) to `#F0807A` (4.9:1 there, 5.6:1 on the card), R3-A07. The contrast script now composites state washes before it measures a label.
124. CHANGE (dark): data marks use `accent`, controls `accent-fill` (R3-O07). Progress bar fill, slider fill, week done and half dots, the week legend (removed by D186) and chart bars go from the button teal `#0F8571` (2.9:1 on `fill`) to `#4CC3AC` (6.1:1). Light is unchanged (both `#0B7A68`). [Amended by D186]
125. ReaderTopBar (ruling 2, HANDOFF, RD_FocusMotion): pinned; "n of N" 13/400 plus the lesson title 14/600 (board `.n` and `.lt`); the app sets `.is-titled` after 90px of scroll and `.is-hidden` after 120px more, cleared by the first scroll up; the 3px progress thread (`size-thread`, `accent` on `fill`) stays at the top edge while the bar hides. Chosen: 64px wide and 44px on the phone (FocusHeader heights), title and bar moves on `motion-move` (the board's `(.4,0,.2,1)` has no token). Reduced motion switches the states at once. [Lead ruling (delegated, Nov 8)]
126. Gradients (ruling 10): stop tokens `hero-start`, `hero-mid`, `hero-end`, `topic-done-end`, `share-end`, `on-hero`, `on-hero-secondary`, and four recipes (`.card--hero`, `.card--topic-done`, `.card--share`, `.card--promo`). CHANGE folds under 1.0 CIEDE2000: ST_ProPMA's hero start `#0E8C77` into `#0E8B76` (the topic-done and share start); the share end `#064C40` into `#0A4D42` (`teal-712`). CHANGE: the phone hero radius 24 to `radius-2xl` 22, and its teal shadow is not drawn (principle 1: only floating things have a shadow). Kept: padding 26 by 22, feature rows 15/500 with 21px `#BFF0E4` icons. White body text stays off the top 40% of the hero (4.2:1 there; titles are large text). [Lead ruling (delegated, Nov 8)]
127. SearchOverlay (ruling 9, SD_Search, SD_SearchRecent): scrim `scrim-search` (ink at 22%, black at 40% in dark), panel 640 (`layout-search`) at 110 from the top, radius 18, field row 60 with a 19px query (`web-search-input`), Esc hint, results grouped under eyebrow labels, the active result on the hover well with an Enter hint, matched text in `mark` (`accent-tint-text` on `accent-tint`), key-hint footer on `surface-inset`. CHANGE snaps: group label 12 to `web-eyebrow` 13, result radius 10 to `radius-md` 12, highlight radius 3 to `radius-xs` 5. Chosen: the phone opens it as a full-screen sheet without the key footer; an empty search shows a bare EmptyState inside the panel.
128. Tooltip (R3-O10): `toast-bg` and `toast-text`, `web-caption`, 4 by 8 padding, radius 8, at most 240 wide, 8px from the anchor, top then bottom, `z-tooltip`; shows after 500ms (`dur-tooltip`) on hover and at once on keyboard focus, hides on Esc, stays while hovered, never on touch; fades in `dur-short-2`. Chosen.
129. Flutter naming (ruling 1, R3-O01, R3-A03, R3-A10): one Dart class per token family (PantasColors, PantasSpace, PantasRadius, PantasShadow, PantasBorder, PantasLayout, PantasSize, PantasCurves, PantasDurations, PantasZ, PantasOpacity, PantasType), so `PantasCurves.fade` and `PantasDurations.fade` no longer collide; reserved words take the family noun (`switchDuration`); flex triples are `PantasFlex`; `radius-2xl` is `r2xl` everywhere; component READMEs name tokens. `flutter_names.py` enforces it. [Lead ruling (delegated, Nov 8)]
130. Lesson text scale scope (ruling 4, R3-A02): the scaled styles are redeclared on every element, so `--reader-scale` on any root reaches notes, examples, passages, options, explanations and display math, and two readers can differ; `phone-option` (17/400, the phone option) and `phone-explanation` now scale; overlays reset the scale to 1. [Lead ruling (delegated, Nov 8)]
131. Bottom reserves (ruling 3): `layout-reserve-tabbar` and `layout-reserve-bar-phone` 6.5rem and `layout-reserve-bar` 8.75rem (the bar offset, height and gap written in rem), plus the safe area. Deviation, chosen: the bars keep a pixel minimum height (a 4rem bar would be 128px tall at 200% text), and the bottom action bar and the phone quiz bar are sticky in the flow, because their fine print and hint wrap unpredictably, so no token can predict their height (the rem reserve still covered too little for the stacked quiz bar at 320 and 200%). At 200% text nothing ends under a bar at 320 and 390. [Lead ruling (delegated, Nov 8)]
132. Mock question list tiers (ruling 5): Close and the clock live in the header inside `.qpanel-shift`, so the panel never covers them; wide pushes the content and the bar re-centers on the question column (MK_NavMotion); 600 to 1023 a left drawer under the header with a scrim that leaves the header clear; under 600 a bottom sheet that stops below the header; the same markup, with `.is-open` on the narrow tiers and `.is-hidden` on wide. [Lead ruling (delegated, Nov 8)] [Amended by D162]
133. CHANGE: SegmentedControl (ruling 6, R3-O20). The track is an inline grid of equal columns as wide as the widest label, so labels never wrap; the thumb reads the count and the selection through `:has()` (2 to 5 segments, otherwise the selected segment draws the thumb color without the slide); unselected labels 600 to 500 (the boards draw 600 for both) so the state also reads as weight. [Lead ruling (delegated, Nov 8)] [Amended by D172]
134. Chart (ruling 7, R3-A11, R3-A15): the plot never scrolls sideways; when the chart is under 36, 25, 19.5 and 14rem wide (the plot about 3rem less) it shows the last 12, 8, 6 or 4 points with "Showing the last N weeks"; the full series stays in the table. The line is drawn per column from each point to the next, so line and points share one coordinate system; the plot reserves headroom for a value label at 100. [Lead ruling (delegated, Nov 8)] [Amended by D171]
135. StatRow link variant (ruling 8): `a.stat-row--link`, the whole row clickable, a chevron at the end of the top line, the hover well, the focus ring inside. Subject rows on Performance open the subject page. [Lead ruling (delegated, Nov 8)]
136. CHANGE: shell tiers (ruling 11). SidebarNav from 1024 (was 1280): compact 1024 to 1439 (the sidebar at 220, main sides 32, chosen), full from 1440 (new `bp-wide`; `bp-desktop` deprecated). Tablet 600 to 1023: TabBar, the centered 640 column with 24px sides. Phone: 16px gutters. Below 1024 a page root swaps wide styles for phone styles (`phoneScale`, the pairs in Type), so one Home markup serves 600, 1024 and 1440; `.tablet-column` and `.main--tablet` are deprecated. [Lead ruling (delegated, Nov 8)]
137. Rows stack at large text by themselves (ruling 12), by wrap rules rather than a container query (a container query does not reach inside a `button` row): the title keeps at least 8em of its own text, and when the title and the value no longer fit on one line the value wraps under the title (about 1.5x on a 390 phone). `.row--stack` stays as a forced override. Headings break long words (`overflow-wrap`, hyphens), so a 200% title never runs off a 390 screen. Chosen: 8em. [Lead ruling (delegated, Nov 8)] [Amended by D178]
138. Mock flag (R3-O04, HANDOFF hard rule, checked on MK_FiveMin): "Flag" with its F hint, a 36px tertiary button (`.btn--xs`, new `size-btn-xs`, 14/600) at the right end of the question header at every width; the mock bar holds the counter, hint and action only. The quiz keeps the bar flag (QS_Flag).
139. The explanation below 1134px is a modal drawer with a scrim and its own footer (counter and Next), and the floating bar's main action hides while it is open (R3-O03). Chosen: modal, not complementary, because the drawer covers the bar's right end. [Amended by D162]
140. Passage after the reveal (R3-O08, CHALLENGE of D104): "Show Passage" at the right end of the explanation head opens the passage in a Drawer (wide) or Sheet (phone); on the phone the collapsed passage expands in place ("Show Full Passage", `aria-expanded`), and passages over about 300 words keep the Sheet. Amends D104; the two-column limit stays.
141. Type slots (R3-O09): rest weights become styles with the same values (`phone-tab-label`, `phone-wheel`, `web-stat-value`, `web-chip-name`, `web-glyph`; no visual change). CHANGE: slider "A" labels 14/500 and 22/500 to `web-label` 600 and `web-stat-unit` 600 (the boards draw 500). `web-math` and `phone-math` are deprecated (never consumed); `.math` is the contract. Chart axis labels use line height 1 with a half-line offset (no visual change). The build fails on any rest weight.
142. Stroke widths become tokens (R3-O22): `border-ring-current` 2.5 (current chip, spinner, the 44px ring) and `size-ring-stroke` 2.4 (ring value). No value changes.
143. Renames and deprecations, 3.1.0 (R3-O13, R3-O19, R3-O12): `size-btn-md` renamed `size-btn-bar` (md was larger than the default); `figure-viewer-bg` deprecated (no consumer); `bp-desktop` deprecated (ruling 11); `chart-5` aliases `accent`; private custom properties `--_h` and `--_p` renamed `--h` and `--p`. Old names stayed until 4.0.0, then went (D191), except `figure-viewer-bg`. [Amended by D173]
144. CHANGE: dialog width subtracts the 24px side inset once (R3-A12): at 320 and 390 a dialog is 272 and 342 wide (it was 240 and 310).
145. Dialog and sheet pairs at large text (R3-A12, usage gap 32): on the phone the pair wraps with the main action on top, each full width (`flex-wrap: wrap-reverse`; each button's basis 7.5em keeps equal halves until then); on wide screens it wraps secondary then main; `.dialog__actions--stack` forces the column. Chosen.
146. WeekStrip at 320 (R3-A04): days keep 44 and never shrink; when seven do not fit, the days scroll inside the strip and the selected day scrolls into view; the ExamChip moves to its own line first. Chosen.
147. SidebarNav marker (R3-A14): positioned from the measured current item (`--active-top`, `--active-height`, `.is-measured`), so it follows large text; without a measurement the current item draws its own highlight. Chosen.
148. Plan tile (usage gap 24, ST_ProPMA and ST_Paywall wide): `.choice-tile--plan` with the name 15/600 (`web-link`), the price 26/700 (`web-h2`) and period, an optional per-month line, a solid tag on the top edge, a 1px `divider` edge as drawn; three plans per row on wide screens, one per row on the phone, Season Pass across the row. CHANGE: radius 16 to `radius-lg` 14 (the SelectableTile radius).
149. Fine print (usage gap 22): `.fine-print` under its button in a `.cta-block`, right-aligned on wide screens and centered below 1024 (ST_ProPMA phone). "Restore Purchases" on the phone is `.btn--text-phone-sm` 15/600 (usage gap 27).
150. Display math that scrolls sideways shows an edge shadow on the side it can scroll to (usage gap 6); stacked fractions use `.frac` (usage gap 5). Chosen.
151. The mock clock in the header is `.timer--inline`: the time and a 60px bar on one line, centered on the 64px header like the title (usage gap 12). Chosen. [Amended by D161]
152. Toasts clear the TabBar and the phone bar including the safe area and the rem reserve (R3-O17): before, a 34px home-indicator inset put the toast 2px over the TabBar.
153. Motion recipe values get Flutter names (R3-O21): motion.md's recipe table generates `PantasMotionRecipes`. No value changes.
154. Reduced motion covers the chart bar grow and the FigureViewer exit (R3-O05, R3-A05); forced colors keep data marks drawn as backgrounds (R3-O06). No value changes. [Amended by D166]

### Round 4 (Nov 8)
155. Slider at large text (ruling 1, usage gap 10): the slider is a size container; under 17rem of row width (`layout-slider-narrow`: the end labels at their text size plus the 160px minimum track, `size-slider-track-min`) the end labels and the value move above the track, which then takes the full row width. In rem, so at 200% text it applies from 544px down; at default text only rows under 272px stack (a Settings card on a 320 phone). Count sliders (Custom Quiz, number of questions) use `.slider__end` for the minimum and maximum (`web-small`, `text-secondary`), so the maximum never reads as the value (usage gap 9). No value changes at default text. [Lead ruling (delegated, Nov 8)]
156. Tile grid columns in rem (ruling 2, usage gap 15): `.choice-grid` columns are at least `size-tile-min` (10rem, 160px at default text, as before), so at 200% text a 390 grid drops to one column and "CSE Professional" stays on screen. No value changes at default text. [Lead ruling (delegated, Nov 8)]
157. ListRow split anatomy (ruling 3, usage gap 2, Bookmarks BM boards): `.row--split` holds `.row__main` (the link or button: lead, title, subtitle, value, chevron) and a trailing `.row__action` (an IconButton) as siblings, never nested. The hover well covers the main area only; one hairline runs under both from the row inset; link styles never reach row parts (`a.row__main`, `a.row__t`). Chosen: the action sits 8px from the right edge (4 on the phone), so its 20px glyph lines up with the chevron column. [Lead ruling (delegated, Nov 8)]
158. CHANGE: SelectableTile rest ring (ruling 4, usage gap 7): transparent to 1px `border-control` (3.4:1 on the card, 3.2:1 on the page), so a tile shows on a card as well as on the page; hover 1.5px `divider-strong` to 1px `text-secondary` (the control hover rule). The plan tile keeps its drawn `divider` edge. [Lead ruling (delegated, Nov 8)]
159. Grouped checkboxes (ruling 5, usage gap 8, Custom Quiz CZ boards): for more than eight topics, `.choice-tree` per subject with a parent checkbox (`.choice--parent`, label `web-title-sm`) whose state is mixed when some topics are checked (`input.indeterminate`, `.is-mixed` in previews), its topics in `.choice-tree__children` indented by the checkbox plus 12px, an optional count (`.choice__meta`), and an optional Select All row (`.choice--all`) above the subjects. Tiles stay for two to eight choices. [Lead ruling (delegated, Nov 8)]
160. CHANGE: WheelGroup (ruling 6, usage gap 14, Onboarding exam date, OB boards): `.wheel-group` lays the month, day and year wheels in equal columns with one shared selection band (`bg-page`, radius 8, 12px in from each side) behind them; each wheel drops its own band. The phone boards draw the columns 140 and 80 wide; equal columns are the ruling. [Lead ruling (delegated, Nov 8)]
161. FocusHeader from one markup (ruling 7, usage gaps 18 and 19): slots in order Close, title, clock (`.timer--inline`), actions. The title is one line with an ellipsis at every width (its full text stays in the document title), so the header keeps its 64px and the actions never leave the screen; under `layout-focus-head-narrow` (24rem) the clock drops its bar; under 600 the sides narrow to the phone header's 4 and 8. Measured: at 320 and 200% text the Report button ends inside the screen. Amends D151. [Lead ruling (delegated, Nov 8)] [Amended by D176]
162. Focus panels are modal on narrow tiers (ruling 8, R4-O03, R4-O17, usage gap 20): below 1024 the question list and below 1134 the explanation drawer take `role="dialog"` with `aria-modal="true"` and a label; the page behind is `inert` (the header stays visible but inert); focus moves into the panel and returns to the opener; Esc closes; a real scrim element (`.scrim--qpanel` under the header, `.scrim--xpl` over the window) fades over `dur-switch` and closes on click, and the page scroll locks. The app switches the roles at the tier change. The 100vmax spread-shadow scrims and their clip-paths are removed. One panel state: `.qpanel.is-open` on every tier (wide no longer reads `.is-hidden`); the app opens it on first load at 1024 and up. Amends D132 and D139. [Lead ruling (delegated, Nov 8)]
163. Button pairs on phones (ruling 9, usage gap 22): DOM order is secondary then main everywhere. Below 1024 a `.btn-row` of `.btn--block` buttons and the bottom action bar (`.phone-bottom`) stack in reverse, so the main action is on top as the phone boards draw it (MK_PauseA, QV_EndFree, L_ChangeExam2, ST_ProPMA); focus order then runs secondary first, which is acceptable for a two-button group. Pairs the boards draw side by side (dialogs, notices) keep the main action at the right end. A CardFooter pair sits in a `.btn-row`; a button and its fine print sit in a `.cta-block`. [Lead ruling (delegated, Nov 8)]
164. Markup examples (ruling 10, usage gap 1): every component with nested classes gets a "Markup" section with a minimal example, taken from its preview with the documentation scaffolding, forced states and repeats removed. [Lead ruling (delegated, Nov 8)]
165. Reader overlays keep the lesson scale (ruling 11, R4-O01): Dialog and Sheet reset `--reader-scale` to 1 except a Sheet that shows lesson content (`.sheet--reader`, the phone passage); the app copies `--reader-scale` onto it, because overlays mount outside the page root. A Drawer never resets it. Flutter: the sheet child sits inside the same lesson `TextScaler`. [Lead ruling (delegated, Nov 8)]
166. Forced colors keep week dots by state (R4-O02): only done dots paint `CanvasText`; half dots paint a half `CanvasText` disc with a `CanvasText` edge; planned, no-study and today cells show no dot, as in the normal theme. The legend keys followed (the legend is removed by D186). Amends D154. [Amended by D186]
167. CHANGE: promo card secondary text (R4-O04): inside `.card--promo`, secondary text and fine print use `text-on-tint-secondary` (4.6:1 on the tint end, 5.4:1 on the card end in light), because the card ends in `accent-tint` where P2 puts the CTA and its fine print; `text-secondary` was 4.4:1 there. Rows added to the contrast table.
168. State washes are tokens (R4-O05): `opacity-hover` 0.08 (`PantasOpacity.hover`) and `opacity-spinner-track` 0.3 (`PantasOpacity.spinnerTrack`). Hover and press washes are the label color at `opacity-hover` over the ground: `color-mix(in srgb, currentColor calc(var(--opacity-hover) * 100%), transparent)`. The contrast script reads the token. No value changes.
169. Passage bottom reserves in rem (R4-O07): the three 140px literals become `layout-reserve-bar` plus the safe area; the build fails on a pixel bottom reserve of 100px or more above a pinned bar. No value changes at default text.
170. One markup scope (R4-O08, option a): one markup serves every width for `.shell` pages and for the FocusHeader (D161). Focus and reader pages swap their type below 1024 but keep the wide geometry (stage sides, option padding, the explanation drawer); under 600 build them with the phone variants (`.fbar-dock--phone`, `.opt--phone`, `.xpl-phone`, `.reader--phone`) until the quiz migration adds the swaps.
171. Chart (R4-O06, R4-O09): the clipped note shows only when the container query hides a column (it counts the columns, so a 10-point series at 30rem prints nothing); `.chart__line` is deprecated (removed in 4.0.0, D191) and the README asks for per-column segments only. Amends D134.
172. SegmentedControl track (R4-O10): the thumb and the buttons sit in `.seg__track` inside the scrolling `.seg`, so a track that overflows (320, or 200% text with "6 Months") keeps the thumb on its segment while it scrolls. Markup without the track still works. Amends D133.
173. `figure-viewer-bg` is un-deprecated (R4-O11): the Flutter figure viewer stage reads it (black); the web viewer uses `figure-scrim`. Amends D143.
174. Housekeeping (R4-O14, R4-O15, R4-O16, R4-O18): CHANGE lines ship in a minor and are final when recorded (D191, governance); the checks ship with the system as `tools/build_css.py`, `tools/contrast.py`, `tools/flutter_names.py` and `tools/validate.py`; the `.main--tablet` reserve rule is removed (the class was a no-op alias, removed in 4.0.0, D191); QuestionNavigator rows are grids of six, not `display: contents`, so their row role survives in every WebView.
175. Small additions from the usage test, each for a named screen: `.card__head` (Custom Quiz "Your Quiz"), `.pbar-head` (Onboarding step header), a SectionHeader may hold one small teal tertiary Button for an action on the section (Custom Quiz "Select All"), the glyph list gains bookmark, trash, list, clock, minus and plus (Bookmarks, Custom Quiz, Mock), the ExamChip calendar tile is 2.625rem wide (42px at default text) so "DEC" fits at 200%, a centered EmptyState keeps its one action at natural width on every tier, and a Toast may cover content for its 8 seconds at large text (it never covers the bar it sits above). Chosen.
176. FocusHeader height on phones (recheck R4R-O01): under 600 the one-markup header is 44px at default text (`layout-focus-head-phone`, 2.75rem), as the approved phone boards and `.focus-head--phone` draw it, and grows only with text; the phone question list sheet and its scrim start under it. 64px stays from 600 up. One markup now covers the phone, so `.focus-head--phone` was deprecated (removed in 4.0.0, D191). No board value moves. Amends D161.
177. Recheck housekeeping (R4R-O02 to R4R-O06, usage recheck): the segmented tablist example keeps one Tab stop (`tabindex="-1"` on unselected tabs, `role="none"` on `.seg__track`); the last three literal opacities become tokens (`opacity-bar-ring` 0.26, `opacity-ripple` 0.38, `opacity-scroll-edge` 0.18; `PantasOpacity.barRing`, `.ripple`, `.scrollEdge`); the TabletLayout example shows the AppShell markup; `tools/build_css.py --check` writes nothing and fails on drift (CI), `--write` rebuilds; the PhoneFrame bottom bar lines agree; the stacked slider puts the large end label at the track's end with the value beside it; split rows keep the chevron at the row end at large text; QuestionNavigator and Explanation show the full modal markup and behavior below their tier change. No value changes.
178. Row stacking threshold and chevron (patch 3.2.1, found drawing review boards with 3.2.0): the title keeps at least 6em of its own text before the value stacks (was 8em in D137, which stacked DK_Settings "Practice" with "10 questions" in a 300px column at 100% text; 6em still stacks it at 200%); the chevron is out of the wrapping flow at the end of the row, centered on it, with its slot kept as padding, so it never wraps onto its own line (plain rows at 320px in a phone dialog and at 200% text). Checked by `r4/tools/rows_check.js` in the build. No board value moves. Amends D137.

### Board picks (Nov 8)
Aedwon delegated seven review boards on Nov 8 ("you can decide for me based on the design system and whichever is the best for UX"), with WCAG 2.0 AA and Apple HIG as the bar, and asked to drop the week legend. Version 3.3.0.
179. List row vertical padding stays 13 (board D23, Current): a 17px title (line height 1.3) plus 13 above and below gives a 48px row, over the 44pt HIG minimum target; the Settings row has a 16px title and is 47px, as the approved DK_Settings draws it. No value changes. Resolves D23 and D94. [Lead ruling (delegated, Nov 8)]
180. CHANGE: the phone large title steps down at large text (board G6, option A): the phone screen is a size container (`.phone-screen`; for a `.shell` page below 1024 the `.main`, D189), and under `layout-title-narrow` (12rem of screen width; a 320 phone at 150% text or more, a 390 phone at 200%) `phone-large-title` takes `phone-title-2` (22px, 44px at 200%), two steps down, as board A draws it at 320 and 200%. Words still break as a last resort (`overflow-wrap: break-word` on headings), so a title never runs past the screen edge (WCAG 1.4.10 reflow). Why: HIG Dynamic Type grows large titles less than body text. [Lead ruling (delegated, Nov 8)]
181. CHANGE: TabBar labels never drop to icons (board G13, option B): the "icon-only mode" and "labels may drop to icons" rule is removed. At large text the label stops at 12px (`size-tab-label-max`; 10px at default text), as board B draws. Why: HIG tab bars keep visible labels and tab labels do not grow with Dynamic Type; WCAG 2.4.6 and 3.3.2 keep a visible label. Four labels fit at 320 wide and 200% text (measured). [Lead ruling (delegated, Nov 8)]
182. SelectableTile in a row (board G17, option A): tiles top-align their content (`justify-content: flex-start`; day tiles keep their centered content), and a tag sits on the tile's top edge (top -10, left 16), as the plan tile does; the grid adds 10px above when a tile has a tag. Why: mixed tiles (one with a tag) start their text on one line. [Lead ruling (delegated, Nov 8)] [Amended by D190: the tag is in an in-flow header slot, centered on the top edge, so it never covers a title at large text]
183. CHANGE: `.cta-card` padding 24 to 20 (`space-20`) (board G23, option A), so Home cards share one 20px inset with `.card--pad`, the card footer and the stat list. Why: one inset on the page. Moves a value on the approved Home board. [Lead ruling (delegated, Nov 8)]
184. Columns tops line up (board G24, option A): the section header of a column's first card sits inside the card (a `.card--pad` holding a `.sec-head` with the `web-h3` title and the link), not above it, so Home's two cards start on one line. Rule in Columns; Home in patterns. Why: the cards' tops align. [Lead ruling (delegated, Nov 8)]
185. ExamChip wrap (board G25, option A): when the chip wraps under the days (a phone under 600 wide), it takes its own line, left-aligned under the days, and the hairline is removed (`flex-basis: 100%`, no margin-left, 4px left padding, no border). From 600 up the chip stays beside the days after its hairline. Limit (D189): CSS cannot see a wrapped item, so the hairline goes by viewport, not by wrapping. The boards draw 390 and 1440 only; at 600 and up the chip has room at default text, and at very large text in a narrow tablet column a wrapped chip can sit right-aligned with its hairline. Accepted until a board draws that case. Why: a hairline with nothing beside it reads as a stray rule. [Lead ruling (delegated, Nov 8)]
186. CHANGE: the WeekStrip legend (`.week-legend`, "Done / Partly done") is removed (Aedwon disliked it). A day that has a status shows a Tooltip with the status in sentence case: "Done", "Partly done", "No study", "Planned" and "Today". It shows on hover with a fine pointer and at once on keyboard focus, never on touch (Tooltip's `hover: none` rule). Each day's accessible name already ends with its status, so the tooltip is `aria-hidden="true"` with no `aria-describedby` (an exception to the Tooltip rule, so the status is not announced twice). Status stays clear without color: done is a full dot, partly done a half dot, and the name carries it; touch users see the dot shape and the selected day's plan. `.week__days` scrolls at 320, so one `.tooltip` sits in `.week`, outside the scroll container, and the app positions it over the day with the data property `--x` (D189). Today always reads "Today" (D189); it has no dot, and its ring and its name carry the progress. `.page-head__after` stays as an empty slot. Amends D120, D124 and D166. [Lead ruling (delegated, Nov 8)]
187. CHANGE: undo D29 where it turned approved pill buttons into rounded rectangles. Restored to `radius-full`: the floating-bar counter (`.cnt`) and action (`btn--bar`), 46px (14 back to pill), and the phone dialog pair (`btn--dialog`), 46px (14 back to pill). Text actions and ghost buttons still highlight as rounded rectangles (Principle 3; a tertiary `btn--bar` or `btn--dialog` keeps `radius-lg`; the `.cnt` counter is a ghost button that hovers as a pill, as drawn). The TabBar stays a pill. Wide-screen buttons and `btn--notice` (Got It, Manage: the boards draw them 44px, radius 12) stay rounded rectangles; the board "Retry" (44px, radius 99) gets a class in D189 (`btn--pill-sm`); D190 drops the "Allow" and "Replay" classes (an Android system prompt the app does not style; a board playback control). Aedwon: "'pills' refer to labels as pills, it's an AI-generated pattern i don't like. usually they use it in things like Connected or something, among other things as eyebrows for example." [Approved by Aedwon, Nov 8] [Amended by D188: tag pills stay]
188. Tags keep their pill shape; decorative eyebrow pills are banned (board D188, Current). Aedwon (Nov 8), on the tag board: "you can keep this specific type of pills. this makes sense functionally. what i don't want to see is something like the ones i attached", with two landing-page heroes whose eyebrow ("THE MSL NETWORK", "PERFORMING ARTS PLATFORM") sits in an outlined capsule with an icon or dot above the headline. Rule: an eyebrow is plain `web-eyebrow` text (SectionHeader); never a capsule, border, tint, dot or icon around a label that only introduces a heading. The system has no such pattern today. [Approved by Aedwon, Nov 8]
189. Audit fixes after 3.3.2 (first pass of release 3.4.0; 27 findings from the read-only audit of 3.3.2, all fixed or settled; the audit file records each resolution). By finding number: 1 radius list says tags (D188); 2 version numbers say 3.4.0; 3 and 4 governance and D187 agree with D188 (tags are pills, decorative pills are banned), D187 and D29 are marked amended; 5 the data contract has one more unitless property, `--x`, so the WeekStrip tooltip is placed without an inline `left` (`.tooltip[style*="--x"]` reads `calc(var(--x) * 1px)`); 6 SectionHeader keeps the eyebrow above a section that holds several cards or rows, and D184's card header (an `h3` inside the card) is for the first card of a column on Home, stated in SectionHeader, Columns and patterns; 7 CHANGE (the only value change in this patch): a `.sec-head` directly inside a card drops its 4px side padding (title and link sit on the 20px inset, as D183 and D184 promise); 8 D29 and D30 are corrected; 9 the Button radius rule carries the D187 exception; 10 the large title step-down also works for a `.shell` page below 1024 (its `.main` is a size container); 11 the old name in PhoneFrame is `.phone-body`; 12 and 15 the TabBar 12px cap is a stated exception in the text-scaling rule and the type-slot rule, with Flutter guidance (a 1.2 `TextScaler` clamp, a long press that shows the label large, and the title swap by width in rem); 13 the radius notes in `tokens.json` name every pill (the Flutter source no longer says "Never a button"); 14 "Open for Aedwon" is rebuilt; 16 a plain `.dialog` under 600 is a fallback with rounded equal halves, and the app mounts `dialog--phone` with the pill pair on phones; 17 `btn--pill-sm` (44px, the board "Retry"), taken from the approved onboarding board (the day toggles are toggles, not Buttons) [amended by D190: the first pass also added `btn--pill-xs` and `size-btn-pill-xs` for the board "Replay" and named "Allow" for `btn--pill-sm`; both are dropped, because "Replay" is a board playback control and "Allow" an Android system prompt]; 18 `.tooltip` gets the forced-colors border; 19 `.week-legend` and the TabBar icon-only mode were removed under the pre-production rule (no product consumes them), now stated in governance; 20 and 21 Tokens used lists and the SectionHeader Status are refreshed; 22 statuses use the allowed words; 23 desktop rows are 17px titles and 48px (Settings 16px, 47px); 24 the ExamChip hairline limit is documented in D185 and WeekStrip (CSS cannot see a wrapped item, and the boards draw 390 and 1440 only); 25 Today always reads "Today" in the WeekStrip tooltip; 26 the `.cnt` counter is stated as the one ghost button that hovers as a pill; 27 the touch fallback is accepted in WeekStrip: planned is future and no-study is past, both are in the day's name and the selected day's plan. [Lead ruling (Aedwon: "fix all", Nov 8)]
190. Astra review fixes after 3.3.2 (release 3.4.0; 16 findings from an outside adversarial review of the 3.3.2 snapshot, all verified against the live files, all fixed or settled; `astra-findings.md` records each resolution). By finding number: 1 the search panel joins the reduced-motion entrance list, so it fades in place; 2 on touch the SegmentedControl buttons are themselves 44px (a transparent block border keeps the drawn 34px segment, phone 32), the 38px well is drawn on the track, because the scrolling `.seg` clipped the old overflowing hit area; 3 amends D182: the SelectableTile tag is in flow in a header slot at the top of the tile, centered on its top edge, and untagged tiles in the same grid reserve the same slot, so titles stay aligned and the tag never covers a title at 200% text (default text: the title still starts at the tile padding); 4 the WeekStrip reference script tracks hover and focus apart, treats the whole strip and the tooltip as the hover zone, and waits 500ms on hover; the Tooltip and WeekStrip rules say so; 5 CHANGE: the study-day row keeps seven days in order with 44px minimum columns, the gap shrinks from 10px toward 4px, and under about 320px the row scrolls sideways with the selected day scrolled into view (README 46px claim corrected to 44px); 6 wheel rows, the five-row viewport, snap spacing and the band follow the scaled line (the larger of 36px and the line plus 16px), and under `layout-wheel-full` (21rem, new token) the month wheel shows Jan, Feb with the full name kept for assistive technology, no separate fallback control; 7 CHANGE: supporting text inside `card--selected` uses `text-on-tint-secondary` (4.63:1, was 4.38:1), and the contrast check lists the composition; 8 the forced-colors selection border and the selected-focus outline cover `date-cell[aria-selected]`, `month-cell[aria-selected]` and `[aria-pressed]`, `choice-tile[aria-pressed]` and `qnav__q[aria-current="step"]`; 9 the Explanation drawer example no longer sets `inert` on `.stage` (it holds the dialog); `inert` goes on `.qcol` and the other background siblings, and the heading takes `tabindex="-1"`; 10 CHANGE: a toggled flag is the outline glyph when off and the filled glyph when on (class `glyph-fill-on`), plus `accent`, for the IconButton, the labeled Flag button and Flutter; 11 Flutter captures the OS text scaler before the 2.0 UI clamp and builds the reader scaler from it, including reader Sheets and Drawers; 12 the slider track and thumb are redrawn with system colors in forced colors, for the WebKit and Firefox engines; 13 the Field input stretches to the full 48px well; 14 Columns documents the wrapped state as it behaves (the picker panel keeps its 400px and the Settings list its 360px maximum when stacked; a stacked sticky panel cannot move, which a browser check confirmed), instead of promising full width; 15 the motion recipe names `--h`; 16 a hidden chart column is readable through a visible tertiary "Show Table" button that opens the DataTable (`chart__table`, `chart__table-toggle`), shown only while columns are hidden. Lead corrections to the first pass (D189 item 17): `btn--pill-xs` and `size-btn-pill-xs` are removed (the board "Replay" is a board playback control, not an app control), and `btn--pill-sm` stays for the onboarding "Retry" only ("Allow" is an Android system prompt the app does not style). The release adds classes and a token, so by the Versioning rule it is a minor: the unpublished 3.3.3 becomes 3.4.0. CHANGE items for the 4.0.0 review: 5, 7 and 10. [Lead ruling (Aedwon: "fix all, ask astra for its opinion too", Nov 8)]
191. 4.0.0: Aedwon's delegation makes every lead ruling final; deprecated names removed. Aedwon (Nov 8): "um you can decide for me based on the design system and whichever is the best for UX. for refinements, please ensure the following are being considered * WCAG 2.0 AA * Apple HIG"; earlier: "you decide for me (unless it's something absolutely necessary that I decide)". So lead rulings and CHANGE lines recorded under the delegation are final; there is no approval queue, and only a decision Aedwon keeps for himself, or one absolutely necessary for him, goes to him. "Decisions to review" becomes "Decisions"; "Open for Aedwon" becomes "Open items" (D41, D91, D170: missing files and app code, not decisions); the status tag "[Still open]" is removed. Removed: tokens `text-past`, `size-btn-md`, `bp-desktop`, `size-icon-sm`, `size-gauge-h`; type styles `web-math`, `phone-math`; classes `.chart__line`, `.focus-head--phone`, `.tablet-column`, `.main--tablet`. `figure-viewer-bg` stays (D173). The private properties `--_h` and `--_p` were already renamed (D143), so nothing is left to remove. Amends D174 and D143. [Lead ruling (delegated, Nov 8)]
192. CHANGE: the ReaderTopBar back is the BackLink with the parent's name ("< Study"), not an icon-only IconButton. Wide screens keep the Esc KeyHint after it; phones use `back--phone`. The bar's columns become the back link, the title, and the contents button, with the title still centered. Why: Aedwon saw the icon-only back on staging and chose to keep the label on every reader back, matching every other back on a page with a parent. [Approved by Aedwon, Nov 9]
