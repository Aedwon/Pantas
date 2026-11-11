Passage holds the reading text that one or more questions refer to, with its source line.

## When to use
- Use it for reading-comprehension items in quiz, mock and assessment (CSE and UPCAT language sections): the content schema's `passage` field. Code: `PassageCard`.
- Don't use it for lesson text (use the reader and ReaderBlock). Don't use it for a figure (use Figure).

## Anatomy
- Card `.passage`: `surface-card`, radius `radius-xl` (18), padding 20 by 24, gap 12, 1px `edge-card` in dark.
- Label `.passage__label` "Passage": `web-eyebrow`, uppercase, `text-secondary`. It names the scroll region.
- Text `.passage__text`: `web-reader-body` (18/1.7) in `reader-body`; phone `phone-reader-body` (17/1.55). It follows the lesson text scale (`--reader-scale`). Paragraph gap 12.
- Numbered paragraphs `.passage__paras` (an `ol`): numbers in `web-small` `text-secondary`, tabular. Use them only when the item refers to a paragraph or line.
- Source `.passage__source`: `web-small`, `text-secondary`, under the text.
- Scroll `.passage__scroll`: its own scroll region with a thin visible scrollbar (`divider-strong` thumb).
- Phone `.passage--phone`: padding 16 by 18, radius `radius-lg` (14), the ReaderBlock values.

## Variants and props
- `.passage`, `.passage--phone`, `.passage--collapsed` (four lines and a "Show Passage" text link, `.passage__more`).
- Layout `.stage--passage` in FocusLayout: `.passage-col` (flex `layout-passage` 1 1 480, maximum `layout-passage-max` 640) then `.qcol`. From `bp-focus-split` (1134) each column scrolls on its own. Below it the passage collapses above the stem, and Show Passage opens it in a Drawer (wide) or a Sheet (phone).
- On reveal the explanation (`.xpl`) replaces the passage column, so no screen shows three columns.
- The consumer provides the text, the source, the paragraph numbers and the shared scroll position.
- After the reveal (R3-O08, amends D104): the explanation replaces the passage column, and "Show Passage" at the right end of the explanation head brings it back in a Drawer (wide) or Sheet (phone).
- Phone: "Show Full Passage" expands the collapsed passage in place (`.is-expanded` on `.passage`, `aria-expanded` on the link), so the stem stays on the same scroll; passages over about 300 words keep the Sheet.
- Bottom reserves (R4-O07): `.passage-col`, `.qcol` and `.xpl` in `.stage--passage` keep `layout-reserve-bar` plus the safe area above the floating bar, in rem.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<section class="passage" aria-labelledby="pl">
  <div class="passage__head">
    <span class="passage__label" id="pl">Passage</span>
  </div>
  <div class="passage__scroll" tabindex="0" role="region" aria-labelledby="pl">
    <div class="passage__text">
      <ol class="passage__paras">
        <li>
          Mangroves grow where rivers meet the sea. The...
        </li>
        <li>
          Fishers in Bohol noticed that catches rose in...
        </li>
        <!-- 1 more -->
        <li>
          The lesson most groups learned is simple: pla...
        </li>
      </ol>
    </div>
  </div>
  <p class="passage__source">Adapted from a coastal management report, 2021</p>
</section>
```

## States
- Rest; scrolled; collapsed. Keyboard focus on the scroll region: 2px `accent` outline, offset 2.
- Empty: not applicable; a question without a passage uses the normal layout.

## Keyboard
- Tab reaches the scroll region once (`tabindex="0"`). Arrow keys and Page Up and Down scroll it. Tab moves on to the question.
- Show Passage is a text link button: Enter or Space opens the Sheet or Drawer; Esc closes it and focus returns to the link.

## Accessibility
- `role="region"` named by the label ("Passage"). The question stem stays the page `h1`.
- Questions that share a passage keep its scroll position, so a screen reader user does not lose their place.
- Lesson text scale and OS text size both apply; the text never shrinks. The phone Sheet that shows the full passage is `.sheet--reader`, so it keeps the scale (the app copies `--reader-scale` onto it; ruling 11, R4-O01); the wide Drawer keeps it too. Check: the phone passage Sheet at lesson scale 2.

## Motion
- None of its own. The Sheet or Drawer that shows the full passage uses its own motion.

## Flutter
- Reuse PassageCard (`new_design/passage_card.dart`) inside a `Scrollbar` and `SingleChildScrollView` with a `Semantics(container: true, label: 'Passage')`.
- Reads `surface-card`, `reader-body`, `text-secondary` and `web-reader-body` (phone `phone-reader-body`), scaled by the lesson `TextScaler`.

## Do
- Keep the source line. Number paragraphs only when the question refers to them.
- Keep the passage scroll position across the questions that share it.

## Don't
- Don't show the passage, the question and the explanation as three columns.
- Don't shrink the passage text to fit.

## Placement
Focus mode: left of the question from 1134px; above the stem, collapsed, below it and on the phone.

## Tokens used
`border-focus`, `accent`, `space-12`, `space-20`, `space-24`, `radius-xl`, `surface-card`, `edge-card`, `space-4`, `space-16`, `type-web-eyebrow`, `tracking-web-eyebrow`, `text-secondary`, `radius-sm`, `divider-strong`, `type-web-reader-body`, `tracking-web-reader-body`, `reader-body`, `space-28`, `type-web-small`, `tracking-web-small`, `space-18`, `radius-lg`, `type-phone-reader-body`, `tracking-phone-reader-body`, `layout-focus-head`, `layout-passage`, `layout-passage-max`, `layout-reserve-bar`, `layout-qcol`

## Status
Draft (new in 3.0, ruling 2). Values from ReaderBlock and the reader type; layout widths `layout-passage` and `layout-passage-max` are new, no board. Changed in 3.1: Show Passage after the reveal; in-place expand on the phone (R3-O08). Changed in 3.2: the passage Sheet keeps the lesson scale (ruling 11); reserves in rem (R4-O07).

