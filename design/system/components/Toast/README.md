Toast confirms the result of an action for a few seconds, with an optional action such as Undo.

## When to use
- Use it to confirm a result the learner already knows about: Saved, Question flagged.
- Don't use it for anything the learner must act on or could miss (use Notice). A toast is not the only way to recover.

## Anatomy
- Surface `toast-bg`, radius `radius-lg` (14), text 15 `toast-text`, padding 4 6 4 18, `elev-toast`. The message has 8px padding above and below.
- Action: 15/600 `toast-action`, 44px high (`size-target-touch`), radius `radius-sm` (8).
- Dark theme: `toast-bg` is #3A3A3C with a 1px #4A4A4A edge inside `elev-toast`.
- Phone: full width less the 16px region padding.

## Variants and props
- With action (Undo) or message only.
- `.toast-region` holds one toast at a time. It is `role="status"` with `aria-live="polite"`.
- The consumer provides the message, the optional action and the minimum time rules below.
- Offsets (R3-O17): above the TabBar and the phone bar the offset uses the same safe-area `max()` as the bar and the bar height in rem, so a toast never touches the bar on a phone with a home indicator or at large text.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="toast">
  <span class="toast__msg">Question flagged</span>
  <button type="button" class="toast__action">Undo</button>
</div>
```

## States
- Entering, resting, leaving (`.is-exiting` or `.is-leaving`).
- Action hover: `toast-action-hover` (white 10%, was a literal, R2-O24). Pressed: scale 0.97. Keyboard focus: 2px `accent` outline.
- Paused: the timer stops while the pointer is over the toast, while focus is inside it and while a screen reader reads it.

## Keyboard
- Tab reaches the action while the toast is up. Enter or Space activates it.
- Do not move focus to a toast. Focus stays where the learner was.

## Accessibility
- The region is `role="status"` with `aria-live="polite"`, so the message is announced without a focus move.
- Time: 4 seconds (`dur-toast`) without an action, 8 seconds (`dur-toast-action`) with Undo.
- Never auto-dismiss when the action is the only way to recover. Use a Notice.
- One toast at a time. A new one replaces the current one after the current one has had its minimum time. Queue the rest.
- The Undo target is 44px high.

## Motion
- In 250ms (`dur-fade`), rising 16px on `motion-house`. Out 300ms (`dur-flip`), falling 8px on `motion-house`.
- Reduced motion: a 150ms fade with no movement.

## Flutter
- Reuse Toast (`components/toast.dart`). Its web variant is 15px with a 44px Undo.
- Reads `toast-bg` [`toastBackground`], `toast-text` [`onToast`] and `toast-action`.

## Do
- Keep the message to a few words.
- Pause the timer on hover and focus.
- Use Undo only when undo is possible.

## Don't
- Don't stack toasts.
- Don't use a toast for an error the learner must fix (use Notice or the field message).
- Don't use red.

## Placement
Bottom center of the window, in `.toast-region`, `z-toast` (70), above every modal.
- The region sits `--toast-offset` above the bottom edge, or 16 above the safe area if that is higher (R2-O17). Default 24.
- With a TabBar on the page (`.tabbar-dock`): 104 (`layout-tabbar-bottom` + `size-tabbar` + 16), so the toast clears the bar. In focus mode with a floating bar (`.fbar-dock`): 104 (`layout-bar-bottom` + `size-bar` + 12); on the phone dock, 92. The shell sets it by `:has()`; Flutter reads the same sum from `FloatingTabBarScope`.
- At large text a toast may cover page content for its 8 seconds (an Undo toast over an EmptyState action at 200%); the page does not reserve room for it, and it never covers the bar it sits above (usage gap 5).

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.toast--phone`: padding 13px (phone board 13px 16px (x176))

## Tokens used
`border-focus`, `accent`, `space-24`, `space-16`, `z-toast`, `layout-tabbar-bottom`, `space-8`, `layout-reserve-tabbar`, `layout-bar-bottom`, `size-bar`, `space-12`, `layout-bar-bottom-phone`, `layout-reserve-bar-phone`, `space-14`, `space-4`, `space-6`, `space-18`, `radius-lg`, `toast-bg`, `toast-text`, `type-web-row-value`, `tracking-web-row-value`, `elev-toast`, `dur-fade`, `motion-house`, `dur-flip`, `size-target-touch`, `space-10`, `radius-sm`, `toast-action`, `type-web-link`, `tracking-web-link`, `dur-short-2`, `motion-fade`, `toast-action-hover`, `type-phone-subhead`, `tracking-phone-subhead`

## Status
Approved (from the boards); changed in 2.0: live region; 4 and 8 second rule; pause on hover and focus; queue; 8 second Undo; dark edge. Changed in 3.0: the region clears the TabBar and the floating bar (R2-O17); action hover is a token (R2-O24). Changed in 3.1: safe-area and rem offsets (R3-O17). Changed in 3.2: large-text placement note (usage gap 5).

