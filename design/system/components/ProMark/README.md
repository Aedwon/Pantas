ProMark flags a feature that needs Pantas Pro.

## When to use
- Use it after a feature name, or at the right end of a row, for a Pro feature.
- Don't use it for a status (use Tag). Don't draw a lone gold icon on a light ground.

## Anatomy
- Text 11/700, letter spacing +0.02em, padding 1px 6px, `radius-xs` (5).
- Fill `pro` (#D9A400), text `on-pro` (#1D1D1F). The same in both themes.

## Variants and props
- `.pro` only. The consumer provides the placement and the word "Pro".
- In a flex column (a `.stack`) the mark keeps its natural width (`align-self: flex-start`; usage gap 26).

## States
- One state. It is not interactive: no hover, pressed, focus or disabled state.

## Keyboard
- None. The mark is not focusable.

## Accessibility
- The text "Pro" carries the meaning, so color is never the only cue.
- Gold with ink text is 7.4:1.

## Motion
- None.

## Flutter
- Reuse ProTag (`components/pro_tag.dart`). It draws 12px, radius 6, minimum height 20; set it to 11px and radius 5 to match.
- Reads `pro`.

## Do
- Put it right after the feature name or at the right end of a row.
- Keep the text "Pro".

## Don't
- Don't draw a lone gold icon on white (2.2:1). Always use the filled mark.
- Don't color it teal.

## Placement
After a title or at a row's right end, before the chevron.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.pro`: padding 1px (Pro mark optical height)

## Tokens used
`space-6`, `radius-xs`, `pro`, `on-pro`, `type-web-pro`, `tracking-web-pro`

## Status
Approved (from the boards); changed in 2.0: unchanged except token names and the standard sections. Changed in 3.1: natural width in a stack (gap 26).
