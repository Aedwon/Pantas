Skeleton holds the shape of content that is still loading.

## When to use
- Use it when a page or a card takes more than about 300ms to load and the layout is known.
- Don't use it for one small action (use Spinner or a busy Button). Don't use it when the layout is unknown.

## Anatomy
- Blocks in `fill-skeleton`. Radius: `radius-md` (12) for blocks, `radius-xl` (18) for cards, `radius-xs` (5) for lines, `radius-full` for avatars. CHANGE: lines were 6.
- Shapes mirror the real content: a title bar, two lines, a button.
- Line height 14px by default. Set the other sizes in the layout.

## Variants and props
- `.skel` block, `.skel--card`, `.skel--line`, `.skel--round`.
- `.skel-out` fades a placeholder out over 200ms. `.skel-in` fades the real content in over 300ms, 60ms later.
- The consumer provides the layout and the swap.

## States
- Hidden for the first 300ms (`dur-wait`), then pulsing.
- Replaced by content when the load ends.

## Keyboard
- A skeleton is not focusable. Keep focus where it was.

## Accessibility
- Set `aria-busy="true"` on the region that loads. Add a hidden "Loading" status for screen readers.
- Mark the placeholder blocks `aria-hidden`.
- Under reduced motion the blocks appear and do not pulse.

## Motion
- Opacity pulses 1 to .45 over 1300ms (`dur-pulse`), `ease-in-out`, after 300ms (`dur-wait`).
- Swap: 200ms fade out, 300ms fade in, 60ms apart.
- Reduced motion: the blocks just appear and stay still.

## Flutter
- Reuse the Skeleton widgets in `components/skeleton.dart`: SkeletonPulse, SkeletonBlock and SkeletonCard.
- Reads `fill-skeleton` [`skeleton`]. The code still pulses under reduced motion; fix it to match.

## Do
- Match the final layout so nothing jumps.
- Mark the region `aria-busy="true"`.

## Don't
- Don't show a skeleton for a load under 300ms.
- Don't animate it under reduced motion.

## Placement
Where the content will be. For one small action use Spinner or the busy Button.

## Tokens used
`fill-skeleton`, `radius-md`, `dur-wait`, `dur-pulse`, `radius-xl`, `radius-xs`, `radius-full`, `motion-fade`, `dur-short-2`

## Status
Approved (from the boards); changed in 2.0: line radius 6 to 5 (`radius-xs`); radius tokens; reduced motion stops the pulse; dark `fill-skeleton`.
