Spinner shows that a short wait is in progress.

## When to use
- Use it for a short wait of a second or two, inside a busy Button or centered in a card.
- Don't use it for a long wait of unknown length (use a Skeleton or a message). Don't use it alone with no word.

## Anatomy
- 20px ring (`size-icon`), 2.5px stroke: track `fill`, arc `accent`.
- Inline (`spinner--inline`): 18px, 2px, takes the button's label color, with a track of the label color at `opacity-spinner-track` (0.3, R4-O05).
- `.spinner__label` holds the word "Loading". It is hidden from sight, and shown beside the arc under reduced motion.

## Variants and props
- `.spinner` and `.spinner--inline`.
- The consumer provides the host (`role="status"` or `aria-busy`) and the verb ("Saving").
- The arc is `border-ring-current` (2.5px; R3-O22).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<span class="spinner" aria-hidden="true"></span>
```

## States
- Turning (default). Under reduced motion: stopped, with the visible label.

## Keyboard
- A spinner is not focusable. A busy Button keeps focus.

## Accessibility
- Give the host `role="status"` or set `aria-busy="true"` on the region that loads.
- Pair the inline spinner with a verb so the state is clear without motion.
- Mark the arc `aria-hidden`. Read the label or the verb instead.

## Motion
- Turns 360 degrees in 900ms (`dur-long-3`), linear, forever.
- Reduced motion: the arc stops and the label shows. The verb still says what is happening.

## Flutter
- Reuse the busy spinner in PantasButton (18px) and a CircularProgressIndicator (20px, stroke 2.5) elsewhere.
- Reads `fill` and `accent`. Replace the loop with a static arc and a label when `MediaQuery.disableAnimations` is true.

## Do
- Pair it with a verb ("Saving") so the state is clear without motion.
- Give the host `role="status"` or `aria-busy`.

## Don't
- Don't use it for waits over about 2 seconds with unknown length; use a Skeleton or a message.
- Don't resize it.

## Placement
Inside a busy Button, before the verb, or centered in a card that is loading.

## Tokens used
`size-icon`, `border-ring-current`, `fill`, `accent`, `dur-long-3`, `motion-linear`, `opacity-spinner-track`, `space-8`, `type-web-row-sub`, `tracking-web-row-sub`, `text-secondary`

## Status
Approved (from the boards); changed in 2.0: `.spinner__label` shown under reduced motion; animation tokens. Changed in 3.1: stroke token (R3-O22). Changed in 3.2: track from `opacity-spinner-track` (R4-O05).

