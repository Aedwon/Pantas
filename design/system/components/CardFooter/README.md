CardFooter closes a card with a caption on the left and the card's action on the right.

## When to use
- Use it when a card has one action that applies to the whole card.
- Don't use it for two primary actions. A card has one.
- Don't use it for fine print about the action. Put that under the button, right-aligned, in `web-small`.

## Anatomy
- Band `.card__foot`: `surface-inset` fill with a 0.5px `divider` rule above. Padding 16px 20px 18px. Gap 12px between lines and 16px between caption and action.
- Caption `.card__foot-text`: 15px, `text-secondary`, line height 1.4, at the left. CHANGE: was 14 (the board draws 15).
- Action: a Button at the right, natural width (`margin-left:auto`). Default 44px (`btn`). A settings footer uses `btn--secondary btn--sm`.
- The footer wraps (`flex-wrap`). A long caption wraps first. On a narrow card the action drops under the caption.
- The last row before the footer hides its own rule automatically.
- In dark the band equals the card (`surface-inset` equals `surface-card`), and the rule separates the footer.

## Variants and props
- `.card__foot` is the last child of a Card. It holds `.card__foot-text` and one Button.
- The consumer provides the caption and the action. Keep the caption factual: "About 15 min".
- A pair: put both buttons in a `.btn-row` inside the footer (secondary then main), so below 1024 the pair stacks with the main action on top (ruling 9).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="card__foot">
  <span class="card__foot-text">About 15 min</span>
  <button type="button" class="btn btn--primary">Continue Lesson</button>
</div>
```

## States
- Rest: the only state. The footer is not a control.
- The action has its own states (see Button). A disabled action keeps the caption.
- Busy: the action shows the spinner and verb; the caption stays.

## Keyboard
- The footer takes no focus. Tab reaches the action after the card's content.

## Accessibility
- The caption is plain text that explains the action. It is not announced as a label.
- If the caption states a condition (a trial price), keep it as text next to the button.
- The action holds a 44px target, or a padded 44px hit area when it is 42px.

## Motion
- None.

## Flutter
- Build it as a Container with a top border at the bottom of the card Column, with a Wrap for the caption and the PantasButton.
- Reads `fill` or `surface-card` [`surface`] for the band, `divider` [`separator`] and `text-secondary` [`secondaryLabel`].

## Do
- Use a 44px button (`btn`). Use `btn--lg` (50px) only for the one action a page exists for.
- Keep the caption short and factual.

## Don't
- Don't stretch the button to the full width of the card.
- Don't put two primary buttons in one footer.
- Don't put a red button in a footer unless the card is a destructive confirm.

## Placement
Last child of a Card. Details are in patterns.md.

## Tokens used
`space-12`, `space-16`, `space-20`, `space-18`, `border-hairline`, `divider`, `surface-inset`, `type-web-sub`, `tracking-web-sub`, `text-secondary`

## Status
Approved (from the boards); changed in 2.0: caption 15px (was 14), wraps on narrow cards, settings-card example with `btn--sm`, last row hides its rule. Changed in 3.2: pairs sit in a `.btn-row` (ruling 9).

