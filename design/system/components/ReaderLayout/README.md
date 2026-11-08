ReaderLayout is the lesson reader: the root that carries the lesson text scale and the 680px reading column with its prose rhythm.

## When to use
- Use it for every lesson (RD boards, the Study destination's reader), wide and phone.
- Don't use it for quiz or mock questions (use FocusLayout) or for settings pages (use AppShell).

## Anatomy
- Root `.reader`: sets the lesson body (`web-reader-body`, 18/400/1.7, `reader-body`; `phone-reader-body` below 1024px by the tier map) and `--reader-scale` (default 1).
- Column `.reader__col`: `layout-reader` (680) centered, `.reader--wide` 800 (`layout-reader-wide`, the full-width setting). Padding 40 by 24; on the phone 16px gutters. The lesson's bottom bar (`.phone-bottom`, "Quiz Yourself") is sticky after the column, so the column needs no reserve. The root is a full-height column, so the bar rests at the bottom of a short lesson.
- Prose rhythm: 16 between blocks; an `h2` (`web-h2`) has 40 above and 12 under it; an `h3` (`web-h3`) 28 above and 8 under; lists indent 24 with 8 between items; `strong` is 600 in `reader-strong`; a figure takes the full column (`.figure--reader`).
- Inside: ReaderBlock (note, example, mistake), Passage, Figure, display math (`.math--display`) and stacked fractions (`.frac`).
- ReaderTopBar is the first child.

## Variants and props
- `.reader--wide`: the 800 column. `.reader--phone`: phone-only screens (`phone-reader-body`, 16px gutters).
- `style="--reader-scale:1.4"` on `.reader`: the lesson text scale (1 to 2) from the reader settings slider. Everything inside follows it (ruling 4).
- The consumer provides the lesson content, the title (`h1`) and the scale.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="reader">
  <div class="reader__col">
    <h1 class="web-h1">Adding Fractions</h1>
    <p>
      You cannot add
      <span class="frac" role="img" aria-label="one half">
        <!-- content -->
      </span>
      and
      <span class="frac" role="img" aria-label="one third">
        <!-- content -->
      </span>
      yet: the pieces are different sizes.
    </p>
    <h2 class="web-h2">Make the Bottoms the Same</h2>
    <p>Find a bottom number both fractions can share...</p>
    <div class="rblock rblock--note" role="note">
      <div class="rblock__head" role="heading" aria-level="3">
        <!-- content -->
      </div>
      <div class="rblock__body">Multiply the top and the bottom by the same n...</div>
    </div>
    <span class="math math--display" tabindex="0" role="img" aria-label="one half plus one third equals three sixths plus two sixths equals five sixths">1/2 + 1/3 = 3/6 + 2/6 = 5/6</span>
    <h3 class="web-h3">Check It</h3>
    <ul>
      <li>Five sixths is a little less than one.</li>
      <li>It is more than one half.</li>
    </ul>
  </div>
</div>
```

## States
- None of its own. Bookmarks and highlights belong to the content.

## Keyboard
- None of its own. A display equation that scrolls sideways takes Tab (`tabindex="0"`) and scrolls with the arrow keys.

## Accessibility
- One `h1` (the lesson title) and a heading order without gaps. Math and fractions carry a text alternative (`role="img"` with `aria-label`, or MathML).
- The lesson scale multiplies the OS text size (README Text scaling); test it at 2x with 200% text.

## Motion
- None of its own. The reader opens with `.page-in` (motion.md).

## Flutter
- A `CustomScrollView` with the ReaderTopBar sliver and a centered column constrained to `layout-reader`; wrap the column in a `MediaQuery` whose `textScaler` is the original OS scaler (`osTextScaler`, captured at the app root before the 2.0 UI clamp, README Text size) times the lesson scale. Never read it from the clamped `MediaQuery` of the root.
- Reads `reader-body`, `reader-strong`, `web-reader-body`, `phone-reader-body`, `web-h2`, `web-h3`, `layout-reader`, `layout-reader-wide`, `layout-gutter-phone`.

## Do
- Put every lesson component inside `.reader`, so one setting scales the whole lesson.

## Don't
- Don't set font sizes on lesson content. Don't place a heading flush under a block without its rhythm.

## Placement
The page root of the reader, inside no shell (the reader hides the navigation, like focus mode) or inside `.main` on wide screens when the board keeps the sidebar.

## Tokens used
`type-web-reader-body`, `tracking-web-reader-body`, `reader-body`, `layout-reader`, `space-40`, `space-24`, `layout-reader-wide`, `space-16`, `space-28`, `space-12`, `space-8`, `reader-strong`, `type-phone-reader-body`, `tracking-phone-reader-body`, `layout-gutter-phone`

## Status
Draft (new in 3.1, R3-O11 and ruling 4). Source: RD boards, README "When each applies" (680 and 800 columns). Values chosen: the prose rhythm (no board measures it).
