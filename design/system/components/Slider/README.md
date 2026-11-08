Slider sets a number within a range by dragging a thumb. In Pantas it sets the lesson text size, from 1.0 to 2.0 times.

## When to use
- Use it for a value on a smooth range where the exact number matters little, such as text size.
- Don't use it for a short list of named choices (use SegmentedControl). Don't use it for an exact number (use Field).

## Anatomy
- Visible label above: `field__label` (13/600, `text-secondary`).
- Row: small "A" (14/500, `text-secondary`), track, large "A" (22/500), value (15/600, tabular, right aligned, at least 3.2em wide). Gap 12px.
- Track 4px high (`size-slider-track`), `radius-full`. Left of the thumb is `accent` (a data mark, R3-O07), right is `fill`.
- Thumb 26px (`size-slider-thumb`), `switch-thumb`, `elev-thumb`, plus a 1px `border-control` ring.
- Hit area: the input is 44px high (`size-target-touch`).
- CHANGE: the board drew the thumb with a shadow only. The 1px `border-control` ring keeps the thumb at 3:1.
- Large text and narrow rows (ruling 1): the slider is a size container. Under 17rem of row width (`layout-slider-narrow`: the end labels at their text size plus the 160px minimum track, `size-slider-track-min`) the end labels and the value move above the track: the small end label at the left over the track's start, the large end label at the right over the track's end, the value beside it, and the track takes the full row width. At default text only rows under 272px stack; at 200% text every phone row does.

## Variants and props
- `.slider` with `.slider__a`, `input.slider__input`, `.slider__a--lg`, `.slider__value`.
- Input: `type="range" min="1" max="2" step="0.1"`. A small script sets `--p` (percent filled) from the value on every `input` event. Firefox fills the track by itself.
- The consumer provides the label, the range, the step and the value text. Use the multiplication sign: "1.5×".
- The filled part of the track is a data mark on `accent` (R3-O07; dark 6.1:1 on `fill`). The fill position is `--p` on the input (R3-O12). The "A" labels are `web-label` and `web-stat-unit` at their own weight (CHANGE D141: the boards draw 500).
- Count slider (Custom Quiz, number of questions, 5 to 40 in steps of 5): `.slider__end` for the minimum and the maximum (`web-small`, `text-secondary`, tabular) instead of the "A" glyphs, so the maximum never reads as the value; the value shows the count ("20"), and `aria-valuetext` says "20 questions". A count where the exact number matters more than the feel still belongs in a Field.

## Markup
The lesson text size slider; a count slider uses `.slider__end` for both ends.

```html
<div class="field-wrap">
  <label class="field__label" for="ts-a">Lesson Text Size</label>
  <div class="slider">
    <span class="slider__a" aria-hidden="true">A</span>
    <input class="slider__input" id="ts-a" type="range" min="1" max="2" step="0.1" value="1.5" style="--p:50%" aria-valuetext="1.5 times">
    <span class="slider__a slider__a--lg" aria-hidden="true">A</span>
    <span class="slider__value" aria-hidden="true">1.5×</span>
  </div>
  <p class="web-body">Simple English, short sentences.</p>
</div>
```

## States
- Rest, with a pointer cursor. There is no hover or pressed change.
- Keyboard focus: 2px `accent` outline, offset 2px, around the input.
- Disabled: 40% opacity (`opacity-disabled`), default cursor.
- Error and empty: not used. The slider always has a value.

## Keyboard
- Arrow Left and Arrow Down lower the value by one step. Arrow Right and Arrow Up raise it.
- Home goes to the minimum. End goes to the maximum. Page Up and Page Down move by a larger step.

## Accessibility
- Use a real `input type="range"` with a `label for`.
- Set `aria-valuetext` to a phrase ("1.5 times"), because the number alone has no unit.
- Mark the "A" glyphs and the shown value `aria-hidden`. The value text is in `aria-valuetext`.
- Show a sample line that changes with the slider, so the result is visible.
- The input is 44px high.
- Forced colors (Windows high contrast, D190): the track and the thumb are redrawn with system colors (`Highlight` fill, `CanvasText` outline, `ButtonText` thumb border on `Canvas`), because gradients and shadows are removed there; both engine tracks (WebKit and Firefox) are covered.

## Motion
- The thumb ring color fades over `dur-short-2` on `motion-fade` on hover. The value moves with the pointer, no easing. Keyboard steps jump.
- Reduced motion: the same.

## Flutter
- Use Slider in `appearance_page.dart`. Theme it with SliderThemeData built from PantasColors.
- Set `activeTrackColor` to `accent`, `inactiveTrackColor` to `fill`, `thumbColor` to `switch-thumb`, `trackHeight` to 4 and the thumb radius to 13.
- A small custom thumb shape draws the 1px `border-control` [`controlOutline`] ring.
- Snap with `divisions: 10`.
- Large text: when the row is under 17rem times the text scale, lay the labels and value in a `Row` above the full-width `Slider` (a `LayoutBuilder` on the row width).

## Do
- Show the current value next to the slider.
- Apply the change as the thumb moves, so the learner sees the effect.

## Don't
- Don't use a slider for an exact number.
- Don't hide the label. Don't rely on the thumb position alone to show the value.

## Placement
In a Settings card under the label "Lesson Text Size", full width of the card. On wide screens, natural width up to about 420px.

## Tokens used
`border-focus`, `accent`, `space-12`, `type-web-label`, `tracking-web-label`, `text-secondary`, `type-web-stat-unit`, `tracking-web-stat-unit`, `type-web-link`, `tracking-web-link`, `text-primary`, `size-slider-track-min`, `size-target-touch`, `radius-full`, `size-slider-track`, `p`, `fill`, `size-slider-thumb`, `switch-thumb`, `border-control`, `elev-thumb`, `dur-short-2`, `motion-fade`, `opacity-disabled`, `type-web-small`, `tracking-web-small`

## Status
Draft (new in 2.0). Source: the phone Appearance board (track 4, thumb 26, shadow). CHANGE: the 1px `border-control` ring on the thumb. Flutter: Slider in `appearance_page.dart`. Changed in 3.0: thumb elevation is `elev-thumb` (R2-O23); motion written (R2-O27). Changed in 3.1: fill on `accent`, `--p`, label weights (R3-O07, R3-O12, R3-O09). Changed in 3.2: labels move above the track at large text (ruling 1); count end labels. Changed in 3.4.0: forced-colors track and thumb (D190).
