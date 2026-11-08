Button is the one control for every action. It has four kinds (primary, secondary, neutral, tertiary) and two tones (accent, critical).

## When to use
- Use a Button for any action that changes data or starts a task: Save, Continue, Delete.
- Don't use it to move to another page as a secondary route. Use TextLink for that.
- Don't use it for a toggle. Use Switch or SegmentedControl.

## Anatomy
- Label: Title Case, 16/600. Large and phone buttons use 17/600. Say the verb: "Keep Going", "Add Exam Date".
- Optional icon, 18px, stroke 1.8, before the label in the label color. Gap `space-8`.
- Optional key hint (`.kbd`) after the label, on primary buttons only, wide screens only.
- Height 44 by default (`size-btn`), `radius-md` 12. A button is a rounded rectangle, except `btn--bar`, `btn--dialog` and `btn--pill-sm`, which are pills as the approved boards draw them (D187, D189).
- Radius follows height: under 40 uses `radius-sm`, 40 to 44 uses `radius-md`, 46 and up uses `radius-lg`. Exceptions drawn as pills (D187, D189): `btn--bar` (46), `btn--dialog` (46) and `btn--pill-sm` (44) use `radius-full`; the filled ones only. A tertiary `btn--bar` or `btn--dialog` keeps `radius-lg` and a tertiary `btn--pill-sm` keeps `radius-md`, because text actions and ghost buttons highlight as rounded rectangles (Principle 3).
- Sizes: `btn--lg` 50 (`size-btn-lg`, `radius-lg`), `btn--sm` 42 (`size-btn-sm`, `radius-md`, padding 18), `btn--bar` 46 (`size-btn-bar`, `radius-full`; a tertiary one keeps `radius-lg`), `btn--phone` 52 (`size-btn-phone`, `radius-lg`, full width).
- `btn--dialog` is 46 (`radius-full`; a tertiary one keeps `radius-lg`) and `btn--notice` is 44 (`radius-md`). Both sit as a pair of equal halves. `btn--text-phone` is a 44px text button.
- Compact pill (D189, D190), from the approved onboarding board: `btn--pill-sm` is 44 (`size-btn`, `radius-full`, 15/600 `web-link`), for the board "Retry" (the board draws it at 40; it is 44 here for the target). It takes a kind: `btn--secondary` for the main prompt action, `btn--neutral` for the rest. The board "Allow" is an Android system prompt the app does not style, and the board "Replay" chip is a board playback control, so neither has a class. The onboarding day circles and exam filter chips are toggles (`aria-pressed`), not Buttons; use SelectableTile or SegmentedControl.
- `btn--bar` padding is 22px on both sides. If a visible key hint follows the label, the padding is 22px left and 14px right.
- CHANGE: 42px buttons moved from radius 11 to 12 (`radius-md`).
- CHANGE: the phone dialog pair uses `btn--neutral` instead of an inline gray override.
- Key hint inside a primary or critical button: `web-tag` on `kbd-on-fill` (black 16%) with `on-accent` text.

## Variants and props
- Kinds (class on `.btn`): `btn--primary` (filled `accent-fill`), `btn--secondary` (`accent-tint` fill), `btn--neutral` (`fill`, gray), `btn--tertiary` (text only).
- Tones: `btn--accent` (the default for primary and secondary) and `btn--critical`. Combine one kind with one tone:

| Kind | Default or accent | Critical | Notes |
|---|---|---|---|
| Primary | `btn--primary` | `btn--primary btn--critical` | critical only for a destructive confirm |
| Secondary | `btn--secondary` | `btn--secondary btn--critical` (class name also `btn--outline-red`): transparent, 1.5px `danger` ring, `danger-text` | |
| Neutral | `btn--neutral` | not allowed | phone dialog secondary |
| Tertiary | `btn--tertiary` (gray), `btn--tertiary btn--accent` (teal) | `btn--tertiary btn--critical` | list actions, Cancel |
| White | `btn--white` | not allowed | the white button the boards draw |

- `btn--white` and `btn--outline-red` are not deprecated (lead ruling D74). CHANGE (3.0.0): the 2.0 aliases `btn--tonal`, `btn--ghost`, `btn--ghost-teal`, `btn--ghost-red` and `btn--danger` are removed; use the kind and tone classes.
- `btn--block` is full width below 1024px and natural width from 1024px. `btn--phone` is always full width.
- `.btn-row` lays out a group of buttons at the right end. The consumer provides the label, the kind, and the busy and done text.
- Use primary for the main action, including a Sign Out confirm. Use primary critical only for a destructive confirm.
- `.btn--xs`: 36px header button (`size-btn-xs`, radius 8, 14/600, gap 8), for the mock Flag with its F hint (R3-O04). Coarse pointers pad it to 44. A pressed Flag turns `accent` and its flag glyph changes from outline to filled (`.glyph-fill-on` on the `svg`; D190), so the state is not shown by color alone; the label stays "Flag".
- `.btn--text-phone-sm`: the 15/600 phone text button, "Restore Purchases" under the paywall CTA (ST_ProPMA, usage gap 27).
- `.btn--bar` and `.btn--dialog` use `size-btn-bar` (46).
- Fine print with its button (usage gap 22): `.cta-block` (the button and `.fine-print` under it), right-aligned on wide screens and centered below 1024px.

## Markup
A pair, secondary then main (ruling 9).

```html
<div class="btn-row">
  <button type="button" class="btn btn--neutral">Cancel</button>
  <button type="button" class="btn btn--primary">Save Draft</button>
</div>
```

## States
- Hover: primary darkens to `accent-fill-hover`. Secondary uses `accent-tint-hover` and the label turns `accent-hover`. Neutral and tertiary add an `opacity-hover` (0.08) wash of the label color (R4-O05). Critical text turns `danger-text-hover`.
- Pressed: scale 0.97, 120ms down (`dur-short-1`), 180ms back (`dur-short-3`).
- Keyboard focus: 2px `accent` outline, 2px offset, on the button's own shape. Keyboard only.
- Disabled: `fill` background, `text-disabled` label, no hover, no press. Tertiary keeps a transparent background.
- Busy: the label becomes a spinner plus a verb ("Saving"). Lock the width to the rest width in script so the button does not jump.
- Busy sets `aria-disabled="true"` and `aria-busy="true"`, never `disabled`, so focus stays on the button.
- Done: a check plus the result ("Saved") pops in. After 1.5s the button returns to rest.
- Labels may wrap at large text. The height is a minimum, so the button grows.

## Keyboard
- Tab focuses the button. Enter and Space activate it.
- While busy, the button keeps focus and ignores activation.

## Accessibility
- Use a `<button type="button">` for actions and an `<a class="btn">` for navigation that looks like a button.
- Announce the verb and the result in one polite live region (`role="status"`). Do not announce the spinner.
- A disabled button needs a visible reason nearby when the cause is not obvious.
- Touch targets are 44px or more. A 42px small button gets a padded 44px hit area on touch (`pointer: coarse`).
- Primary label on `accent-fill`, secondary label on `accent-tint` and the disabled label hold their contrast pairs in light and dark.

## Motion
- Press scales 0.97 over `dur-short-1` and releases over `dur-short-3` on `motion-move`. Color fades take `dur-short-2`.
- The done check pops in 420ms (`dur-medium-3`): keyframed overshoot to 1.08 at 60%, segments on `motion-enter` then `motion-fade` (R2-O13).
- Reduced motion: no scale. The spinner stops and the verb stays. Color fades stay at 150ms.

## Flutter
- Reuse PantasButton as `PantasButton(kind: primary | secondary | neutral | tertiary | white, tone: accent | critical)` (R3-O15), with an assert for the pairs the kind by tone matrix does not allow (neutral and white have no tone; primary and secondary take accent or critical; tertiary takes default, accent or critical). Use ButtonPair for the dialog and notice pairs.
- The `busy` flag shows the spinner and verb. Set `height`, `fontSize` and `radius` from the size table (`radius-full` is a `StadiumBorder` for the bar, dialog and compact pill sizes; a tertiary one uses its rounded rectangle) (`size-btn`, `size-btn-sm`, `size-btn-xs`, `size-btn-bar`, `size-btn-lg`, `size-btn-phone`).
- Hover washes are the label color at `opacity-hover` over the ground (R4-O05); every other slot reads its own token, never a derived color: `accent-fill`, `accent-fill-hover`, `on-accent`, `accent-tint`, `accent-tint-hover`, `accent-tint-text`, `accent`, `accent-hover`, `fill`, `text-primary`, `text-secondary`, `text-disabled` [`disabledActionLabel`], `danger-fill` [`destructive`], `danger-fill-hover`, `on-danger` [`onDestructive`], `danger-text`, `danger-text-hover`, `danger`, `border-control`, `surface-card`, `surface-hover`.

## Do
- Use natural width on wide screens. Put the main button last (rightmost) in a pair.
- Keep one primary per card, dialog or page.
- Write Title Case labels in simple English.

## Don't
- Don't make a button full width on a wide screen. Only the phone does.
- Don't use red for a neutral action. Red is for a destructive action only.
- Don't use a pill shape except `btn--bar`, `btn--dialog` and `btn--pill-sm`, and don't put an icon on a tinted tile inside a button.
- Don't disable a button to show it is busy.

## Placement
Wide screens: right end of a card, drawer or dialog, secondary first and main last. Phone: stacked full width, main on top. Details are in patterns.md.
- Pairs on phones and tablets (ruling 9): DOM order is secondary then main everywhere. Below 1024 a `.btn-row` of `.btn--block` buttons stacks in reverse, so the main action is on top as the phone boards draw it; focus order then runs secondary first, which is acceptable for a two-button group. Pairs the boards draw side by side (dialogs, notices) keep the main action at the right end.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.btn--bar`: padding-inline 22px (D72, floating-bar buttons)
- `.btn--bar:has(.kbd:not([hidden]))`: padding-inline 22px (D72, floating-bar buttons)

## Tokens used
`border-focus`, `accent`, `text-primary`, `size-btn`, `radius-md`, `space-8`, `space-20`, `type-web-button`, `tracking-web-button`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `dur-short-1`, `accent-fill`, `on-accent`, `accent-fill-hover`, `danger-fill`, `on-danger`, `danger-fill-hover`, `accent-tint`, `accent-tint-text`, `accent-tint-hover`, `accent-hover`, `fill`, `opacity-hover`, `text-secondary`, `danger-text`, `danger-text-hover`, `surface-card`, `surface-hover`, `border-ring`, `border-control`, `border-ring-strong`, `danger`, `size-btn-lg`, `radius-lg`, `type-web-button-lg`, `tracking-web-button-lg`, `size-btn-sm`, `space-18`, `size-btn-bar`, `space-10`, `space-14`, `size-btn-phone`, `type-phone-headline`, `tracking-phone-headline`, `space-12`, `size-btn-xs`, `radius-sm`, `type-web-label`, `tracking-web-label`, `type-web-link`, `tracking-web-link`, `space-4`, `text-disabled`, `dur-medium-3`, `motion-enter`, `type-web-tag`, `tracking-web-tag`, `space-2`, `space-6`, `kbd-on-fill`, `divider-strong`, `space-16`, `type-web-small`, `tracking-web-small`, `text-on-tint-secondary`, `size-target-touch`, `radius-full`

## Status
Approved (from the boards); changed in 2.0: kinds and tones renamed (old names stay as aliases), neutral kind, 42px radius 12, symmetric `btn--bar` padding, `btn--block` below 1024px, busy keeps focus, white and outline red deprecated. Changed in 3.0: secondary critical is built (`btn--secondary btn--critical`, alias `btn--outline-red`); "deprecated" removed from white and outline red (D74); 2.0 aliases removed; label type from `--type-web-button`. Changed in 3.1: `.btn--xs`, `.btn--text-phone-sm`, `size-btn-bar`, fine print block; Flutter kind by tone and hover tokens (R3-O04, R3-O15, R3-O19). Changed in 3.2: hover washes from `opacity-hover` (R4-O05); reverse-stacked pairs below 1024 (ruling 9). Changed in 3.3.1: `btn--bar` and `btn--dialog` are pills again (D187). Changed in 3.4.0: `btn--pill-sm`; the radius exception stated here; Tokens used lists `radius-full` (D189, D190).

