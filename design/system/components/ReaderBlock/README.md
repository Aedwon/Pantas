ReaderBlock is a boxed block inside a lesson: a note, a trap to watch for, or a worked example with its solution.

## When to use
- Use it to set apart one idea inside lesson text: a tip, a common mistake, or a worked example.
- Don't use it for the lesson's main text (use the reader body styles). Don't use it for quiz feedback (use Explanation).

## Anatomy
- Block `.rblock`: flex column, gap `space-8`, padding `space-16` top and bottom and `space-18` sides, radius `radius-lg` (14).
- Head `.rblock__head`: `web-link` (15/600/1.3), an 18px icon and a title, gap `space-8`. Body `.rblock__body`: `web-reader-block` (16/400/1.6), scaled by `--reader-scale`.
- Note `.rblock--note`: `accent-tint` fill, text `reader-note-text`, icon `accent-tint-text`.
- Mistake `.rblock--mistake` (title "Traps to Watch For"): `reader-mistake-tint` fill, text `reader-mistake-text`, icon `reader-mistake`. Red is allowed here because it marks what learners get wrong.
- Example `.rblock--example`: `surface-card` fill, 1px `divider` edge, text `reader-body`, head `reader-strong`.
- Solution `.rblock__solution`: `reader-deep` fill, radius `radius-md` (12), padding 14 by 16, top margin `space-4`. Label `.rblock__solution-label`: `web-eyebrow` (13/600, uppercase, +0.02em), `text-secondary`, with the word "Solution". CHANGE (R2-O01): it was an unnamed 12/600 +0.04em.
- Math (R2-O03, one rule): inline `.math` is Source Serif 4 at 1.12em of the surrounding text, with the text's weight and lining figures. Display `.math--display` is `math-display`: 1.6em of the reader body (about 29px at 18px; boards draw 30), centered, 4px padding above and below. CHANGE: display was a fixed 21px. Both grow with the lesson text scale.
- Padding 16 by 18 and radius 14 are chosen values. The inventories give no board values for them.

## Variants and props
- `.rblock--note`, `.rblock--mistake`, `.rblock--example`. One variant per block.
- Inline math: `<span class="math">x² + 3x</span>`. Display math: `<span class="math math--display">`.
- Display math scrolls sideways when it is wider than the block. It never shrinks. Keep the expression on one line with no-break spaces.
- The consumer provides the icon, the title, the body and, for an example, the solution text.
- Write the text in plain English a Grade 5 student can read.
- Display math that scrolls sideways shows an edge shadow on the side it can scroll to, in the color of the surface it sits on (usage gap 6). It takes Tab and scrolls with the arrows.
- Stacked fractions (usage gap 5): `<span class="frac" role="img" aria-label="one half"><span>1</span><span>2</span></span>`, numerator over a rule over the denominator, 0.86em, in Source Serif 4 with the math. The app renders the same with KaTeX.
- Every block follows the lesson text scale from the nearest `--reader-scale` (ruling 4); put blocks inside `.reader`.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="rblock rblock--note" role="note">
  <div class="rblock__head" role="heading" aria-level="3">
    <svg aria-hidden="true">...</svg>
    <span>Note</span>
  </div>
  <div class="rblock__body">
    A fraction names a part of a whole. The botto...
  </div>
</div>
```

## States
- Rest only. The block is not interactive, so it has no hover, pressed or disabled state.
- A display equation that scrolls is focusable. It shows the 2px `accent` focus ring for keyboard focus.
- Empty and error: not applicable. Do not draw an empty block.

## Keyboard
- The block takes no keys. Tab skips it.
- A scrolling display equation takes Tab. Left and Right arrows scroll it.

## Accessibility
- Give a note or a trap `role="note"`. Give the title `role="heading"` with the level that fits the page.
- The title text and the icon carry the meaning. Color is never the only cue.
- The solution label is real text ("Solution"). Do not hide it.
- Give a scrolling display equation `tabindex="0"`, `role="group"` and an `aria-label` that names it.
- Text on its fill keeps at least 4.5:1: `reader-note-text` on `accent-tint` is 8.4:1 in light and 11.5:1 in dark. `reader-body` on `surface-card` is 10.9:1 and 10.0:1.

## Motion
- None.

## Flutter
- Build it from `reader_blocks.dart`: ReaderSection for note and trap, ReaderExample for the example and solution. ContentRenderer chooses the block from the lesson data.
- Reads `PantasColors` reader fields: `reader-body`, `reader-strong`, `reader-deep`, `reader-note-text`, and `accent-tint`. The `readerWarn*` fields map to `reader-mistake`, `reader-mistake-tint` and `reader-mistake-text`.

## Do
- Keep a block to one idea and a few short sentences.
- Say what to do, then what goes wrong. Use "Traps to Watch For" for the title.
- Put the working in the solution panel, one step per line.

## Don't
- Don't use the red block for a warning that is not a learner mistake.
- Don't shrink long equations to fit. Let them scroll.
- Don't put an icon on a tinted tile inside the block. The icon sits bare next to the title.
- Don't nest one block inside another.

## Placement
In the lesson column (680px, 800px when full width is on), between paragraphs of the reader body. Blocks are 16px apart.

## Tokens used
`space-8`, `space-16`, `space-18`, `radius-lg`, `type-web-link`, `tracking-web-link`, `type-web-reader-block`, `tracking-web-reader-block`, `accent-tint`, `reader-note-text`, `accent-tint-text`, `reader-mistake-tint`, `reader-mistake-text`, `reader-mistake`, `surface-card`, `reader-body`, `reader-deep`, `divider`, `reader-strong`, `space-4`, `space-14`, `radius-md`, `space-6`, `type-web-eyebrow`, `tracking-web-eyebrow`, `text-secondary`, `font-serif`

## Status
Draft (new in 2.0). Source: `reader_blocks.dart` and the `PantasColors` reader fields. Padding 16 by 18 and radius 14 are chosen values; see Decisions. Changed in 3.0: one math rule (R2-O03); body style `web-reader-block` with the reader scale (R2-O01, O02). Changed in 3.1: scroll cue, `.frac`, scale scope (gaps 5 and 6, ruling 4). Changed in 3.2: the math line names the `.math` contract only (R4-O13).

