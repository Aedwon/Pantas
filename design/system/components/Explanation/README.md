Explanation tells the learner why the correct answer is correct. It appears after the answer is revealed: beside the question on wide screens, under the options on the phone.

## When to use
- Use it after Check, once the answer is known, in quizzes and in mock exam review.
- Don't use it for a short result such as "Correct" (that is the FloatingBar hint). Don't use it for lesson content (use ReaderBlock).

## Anatomy
- Desktop column `.xpl`: flex basis 440 (`layout-xpl`), shrinks when space is short. It sits beside the question column with a 14px gap (`space-14`).
- While it shows, the question column goes from 720 to 600 (`layout-qcol-narrow`) and the stage gap goes from 40 to 14.
- Card `.xcard`: `surface-card`, radius `radius-xl` (18), padding `space-24`, gap `space-18`, 1px `edge-card` edge.
- Head: gap `space-12`. Key: 32px circle (`size-opt-badge`), `accent-fill`, letter 15/700 in `on-accent`. Label: 13/600, uppercase, +0.02em, `text-secondary`.
- Body: 17/1.55 in `reader-body`.
- Phone `.xpl-phone`: gap `space-12`, top padding `space-12`, 0.5px `divider` rule above. Key column 30px (`size-opt-badge-phone`). Label 13/500 `text-secondary`. Body 15/1.5 `text-primary`.
- CHANGE: the board drew the card at radius 20. It is `radius-xl` (18).
- The phone text size (15/1.5) follows the phone board.
- Wide body: `web-explanation` (17/400/1.55, `reader-body`), scaled by `--reader-scale` (R2-O01, O02).

## Variants and props
- `.xpl` holds one `.xcard`. The card has `.xcard__head` (`.xcard__key`, `.xcard__label`) and `.xcard__body`.
- `.xpl-phone` holds `.xpl-phone__key` and `.xpl-phone__t` with `.xpl-phone__label` and `.xpl-phone__body`.
- Below 1134px (`bp-focus-split`) put the same `.xcard` in the body of a 440px Drawer (`layout-drawer`) over the question.
- The consumer provides the letter of the correct answer and the explanation text.
- Rule: the text says only why the correct answer is correct. It does not describe the wrong options.
- Drawer footer `.xpl__foot` (R3-O03): the last child of `.xpl`, shown only below 1134px: the counter ("4 of 10") and Next, sticky at the drawer's bottom over a hairline.
- Passage items (R3-O08): put a "Show Passage" text link (`.passage__more`) at the right end of `.xcard__head`; it opens the passage in a Drawer (wide) or Sheet (phone), so the line the explanation cites can be checked.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="xcard">
  <div class="xcard__head">
    <span class="xcard__key">B</span>
    <span class="xcard__label">Correct answer</span>
  </div>
  <div class="xcard__body">
    Decimals and fractions can name the same amou...
  </div>
</div>
```

Below 1134 the explanation is a modal drawer (ruling 8). The app sets the roles at the tier change and inserts the scrim with the drawer:

```html
<div class="focus">
  <!-- FocusHeader, inert while the drawer is open -->
  <main class="stage">
    <div class="qcol" inert>...</div>
    <section class="xpl" role="dialog" aria-modal="true" aria-labelledby="xpl-h">
      <div class="xcard">...<span class="xcard__label" id="xpl-h" tabindex="-1">Explanation</span>...</div>
      <div class="xpl__foot">
        <span class="web-small">4 of 10</span>
        <button type="button" class="btn btn--primary">Next</button>
      </div>
    </section>
  </main>
  <div class="scrim scrim--xpl"></div>
  <!-- floating bar: inert while the drawer is open; its main action hides -->
</div>
```

Behavior below 1134:
- Reveal: insert `.scrim.scrim--xpl`, set `inert` on every background sibling (the header, `.qcol` and the floating bar), never on `.stage` or any ancestor of `.xpl`, which must stay outside every inert subtree; move focus to the explanation heading (`tabindex="-1"` on it so it can take focus).
- Tab and Shift+Tab stay inside the drawer; Next in `.xpl__foot` is reachable there.
- Esc or a click on the scrim closes the drawer: add `.is-exiting` to the scrim, remove it after its fade (`dur-switch`), clear `inert`, return focus to the bar's Check or Next button.
- At 1134 and up: no scrim, no `role="dialog"`; the explanation is a region beside the question.

## States
- Rest: the only state. The card is not a control, so it has no hover, pressed, selected or disabled state.
- Empty: do not draw an empty card before the reveal. Draw nothing until the answer is known.
- After a wrong pick the card is unchanged. The red mark stays on the option the learner chose, not on the card.

## Keyboard
- The card takes no focus. After the reveal, Tab goes through the read-only options, then the bar action.
- In the Drawer: Tab stays inside, Esc closes it, and focus returns to the bar action.
- Below 1134px the drawer traps focus; Enter on its Next moves on; Esc closes it and returns focus to the bar action.

## Accessibility
- Give the column `role="region"` and `aria-label="Explanation"`. Place it after the options in reading order.
- Do not move focus to it. The FloatingBar hint (`role="status"`) says "Correct" or "Not this one".
- The head names the key: the letter plus the words "Correct answer". Meaning never rests on color.
- Body text `reader-body` on `surface-card`: 10.9:1 in light, 10.0:1 in dark.
- The Drawer is a dialog: `role="dialog"`, `aria-modal="true"`, and a Close icon button with an `aria-label`.
- Below 1134 the drawer follows the modal contract of FocusLayout (ruling 8): `role="dialog"` with `aria-modal`, the page `inert`, a real scrim (`.scrim.scrim--xpl`) that fades over `dur-switch` and closes on click; the app switches the role at the tier change.

## Motion
- The column slides in 28px from the right with a fade over `dur-reveal` (500ms), `motion-enter`.
- The question column changes its width over 500ms with `motion-move`.
- Reduced motion: the card fades in place over 150ms, with no slide.

## Flutter
- Desktop: build it inside WebQuizQuestion (`web/web_question.dart`). Phone: use AnswerReveal (`new_design/`).
- Reads `surface-card` [`surface`], `accent-fill`, `on-accent`, `text-secondary`, `text-primary`, `reader-body` and `divider`.
- Take sizes (440, 600, 14, 28) from WebTokens.

## Do
- Write one short paragraph in plain words.
- Keep the key letter and the label "Correct answer" together.
- Open the Drawer below 1134px wide, and keep the same card.

## Don't
- Don't explain why the other options are wrong.
- Don't put a button or link inside the card.
- Don't color the card teal or red. The option carries right or wrong.

## Placement
Right of the question column in focus mode, top aligned with the question stem. On the phone, directly under the options, with the rule above it.

## Tokens used
`layout-xpl`, `space-14`, `dur-reveal`, `motion-enter`, `space-18`, `space-24`, `radius-xl`, `surface-card`, `edge-card`, `space-12`, `size-opt-badge`, `radius-full`, `accent-fill`, `on-accent`, `type-web-link`, `tracking-web-link`, `type-web-eyebrow`, `tracking-web-eyebrow`, `text-secondary`, `type-web-explanation`, `tracking-web-explanation`, `reader-body`, `border-hairline`, `divider`, `size-opt-badge-phone`, `space-4`, `type-phone-footnote-strong`, `tracking-phone-footnote-strong`, `type-phone-explanation`, `tracking-phone-explanation`, `text-primary`, `layout-reserve-bar`, `z-modal`, `layout-drawer`, `space-20`, `bg-page`, `elev-drawer`, `dur-long-1`, `motion-slide`, `dur-short-2`

## Status
Draft (new in 2.0). Source: the quiz boards (desktop explanation column) and the phone boards (15/1.5). The 30px phone key has no class in `bundle.css`, so the preview reuses `xcard__key` (32px). Changed in 3.0: body style `web-explanation`. Changed in 3.1: drawer footer with Next (R3-O03); Show Passage in the head (R3-O08). Changed in 3.2: real scrim and the modal contract below 1134 (ruling 8).

