AnswerOption is one choice in a question: a letter badge and the answer text. A question shows four of them in a radio group.

## When to use
- Use it for the choices of a multiple choice question, in quiz, mock and review.
- Don't use it for a setting or a form choice (use Radio or SelectableTile).

## Anatomy
- Button, `surface-card`, radius `radius-lg` (14), min height 64 (`size-opt-min`), padding 14 18 14 16, text 18, gap 16. CHANGE: the radius was 16.
- Badge: 32px circle (`size-opt-badge`), letter 15/600 (`web-link`, line height 1), 1.5px `border-control` ring. It grows with the letter (at least 2.15em), so at 200% text the letter stays inside (usage gap 16). CHANGE: the ring was `divider-strong` (1.7:1).
- Selected: 2px `accent` ring. Badge fills `accent-fill`, letter `on-accent`.
- Right: 2px `accent` ring, `accent-tint` fill, weight 600, a check at the right end. Wrong: 2px `danger` ring, `danger-tint` fill, red badge, a cross at the right end.
- Dimmed: text `text-secondary` and a `divider` badge ring. No opacity. CHANGE: it was 42% opacity.
- Phone (`opt--phone`): padding 13 14, text 17, badge 30, gap 12. The right answer shows the check inside the badge instead of the letter and no mark at the right end. Options stack 10px apart (`opts--phone`), 12px on desktop (`opts`).

## Variants and props
- The group is `role="radiogroup"` with an accessible name: `aria-labelledby` the question stem id.
- Each option is `role="radio"` with `aria-checked`. Use a roving tabindex.
- Four states: picking, submitted, revealed, review. After the reveal, options are read only: `aria-disabled="true"`, still focusable and readable. Never use the `disabled` attribute there.
- Classes: `is-selected`, `is-right`, `is-wrong`, `is-dim`, `is-late` (right answer 150ms after a wrong pick, `--reveal-delay`), `is-ripple` (ring ripple).
- Add hidden suffixes: ", correct answer" on the right option and ", your answer, wrong" on a wrong pick.
- The consumer provides the stem, the options, the right answer and the state.
- Math in an option or a stem: `<span class="math" role="img" aria-label="three quarters">0.75</span>` or MathML. It takes the text's weight and lining figures (usage gap 15).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="opts" role="radiogroup" aria-labelledby="dq">
  <button type="button" class="opt" role="radio" aria-checked="false" tabindex="0">
    <span class="opt__badge">A</span>
    <span class="opt__text">1/4</span>
  </button>
  <button type="button" class="opt" role="radio" aria-checked="false" tabindex="-1">
    <span class="opt__badge">B</span>
    <span class="opt__text">2/3</span>
  </button>
  <!-- 1 more -->
  <button type="button" class="opt" role="radio" aria-checked="false" tabindex="-1">
    <span class="opt__badge">D</span>
    <span class="opt__text">4/5</span>
  </button>
</div>
```

## States
- Rest, hover (1.5px `divider-strong` ring), pressed (scale 0.98), keyboard focus (2px `accent` outline, offset 2).
- Selected, selected with focus (the outline is `text-primary`, so focus never equals selection).
- Submitted, revealed right, revealed wrong, review, dimmed.
- Disabled: `opacity-disabled` (0.4). CHANGE: it was .42. No hover and no press on a read-only option.

## Keyboard
- Tab reaches the selected option, or the first when none is selected.
- Up, Down, Left and Right move and select. Enter checks the answer.
- Letter keys (R2-O12, ruling 1): the item's own option letters (A to D, A to E where an exam has five) and F (flag) act only while focus is inside the question region (the stem, the options and the bar), never page-wide, and only while Settings > Keyboard Shortcuts is on (default on, wide screens only). Modifier shortcuts (Ctrl K) are unaffected. This meets WCAG 2.1.4.
- After the reveal, arrows move focus but do not select.

## Accessibility
- The result is announced once through the FloatingBar hint (`role="status"`), not by the options.
- The right and wrong options carry an icon, a weight change and hidden text, so color is never the only cue.
- Options are 64px high on desktop and at least 44px on the phone.

## Motion
- Ring, badge and fill change over 180ms (`dur-short-3`). Text color 300ms. Press 120ms.
- The right check pops to 1.15 and the wrong cross to 1.1 over 560ms on `motion-move`, then settles. The ripple runs 700ms after 50ms.
- No shake on a wrong answer. Reduced motion: the end state at once.

## Flutter
- Desktop: WebAnswerOption with WebOptionState (`web/web_components.dart`). Phone: ChoiceRow (`components/choice_row.dart`).
- Reads `surface-card` [`surface`], `border-control` [`controlOutline`], `accent`, `accent-fill`, `accent-tint`, `danger-tint` [`wrongTint`], `danger` [`destructive`], `text-secondary` [`secondaryLabel`] and `divider` [`separator`].
- Set `Semantics(inMutuallyExclusiveGroup: true, checked: ...)` on each option.

## Do
- Reveal the right one about 150ms after a wrong pick.
- Keep revealed options focusable and readable.

## Don't
- Don't shake or flash the wrong option.
- Don't rely on color alone.
- Don't use the `disabled` attribute after the reveal.

## Placement
Stacked with 12px gaps (10px on the phone) in the question column (720px, or 600px while the explanation shows).

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.opt--phone`: padding 13px (phone board 13px 14px (x110))

## Tokens used
`border-focus`, `accent`, `text-primary`, `space-12`, `space-10`, `dur-short-2`, `space-16`, `size-opt-min`, `space-14`, `space-18`, `radius-lg`, `surface-card`, `border-ring-strong`, `type-web-option`, `tracking-web-option`, `dur-short-3`, `motion-fade`, `dur-flip`, `motion-move`, `size-opt-badge`, `radius-full`, `border-control`, `text-secondary`, `type-web-link`, `tracking-web-link`, `divider-strong`, `dur-short-1`, `border-ring-selected`, `accent-fill`, `on-accent`, `accent-tint`, `accent-tint-text`, `danger`, `danger-tint`, `danger-fill`, `on-danger`, `danger-text`, `divider`, `opacity-disabled`, `type-phone-option`, `tracking-phone-option`, `size-opt-badge-phone`

## Status
Approved (from the boards); changed in 2.0: radius 16 to 14; badge ring; no opacity dimming; radiogroup; letter keys; late reveal; phone badge check. Changed in 3.0: letter keys scoped to the question region and the Keyboard Shortcuts setting (R2-O12); badge grows with text; math rule.
