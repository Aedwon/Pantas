KeyHint is a small chip that names a keyboard shortcut, alone or inside a button. The `.hint-text` class is the plain-text sibling for hints that are not keys.

## When to use
- Use it on wide screens, after a hardware key press, to teach a shortcut: Enter, Esc, F, Ctrl K.
- Don't show it on touch screens or phones.
- Don't use it as the only label of a control. Use `.hint-text` for words such as "Click to copy".

## Anatomy
- Standalone: 11/600 (`.6875rem`), padding 2px 6px, radius `radius-xs` 5, text `text-secondary`, 1px `divider-strong` ring.
- In a primary or critical button: 12/600 (`web-tag`), padding 2px 8px, radius 5, `on-accent` text on `kbd-on-fill` (black 16%), no ring. CHANGE: padding 7 to 8 (2px grid, R2-O08).
- In a disabled button: transparent with a `divider-strong` ring and `text-disabled` text.
- `.hint-text`: 13px, 400, `text-secondary`, no wrap. It sits at the end of a row beside the value.
- Standalone text is `text-secondary`.
- CHANGE: the boards drew the in-button chip with a white overlay and 88% white text, which measured 3.4:1. The overlay is black 16%.

## Variants and props
- `.kbd` standalone, or inside `.btn--primary` and `.btn--primary.btn--critical`.
- Add the `hidden` attribute until the first hardware key press. Remove it in script.
- A `btn--bar` button with a visible hint changes its padding to 22px left and 14px right.
- The consumer provides the key names. Use real names: Enter, Esc, F, Ctrl K.

## States
- Rest is the only state. The chip is not a control, so it has no hover, pressed or focus state.
- Hidden: `[hidden]` removes it from layout. On touch (`hover: none` or `pointer: coarse`) it is always hidden.
- Disabled: the parent button is disabled and the chip turns gray.

## Keyboard
- The chip takes no focus. The shortcut it names is handled by the page, for example Enter to check an answer.

## Accessibility
- The chip is visual help. The button keeps its own label and, if needed, `aria-keyshortcuts="Enter"`.
- Never place the only instruction in a hint.
- `.hint-text` is plain text; it carries no role.

## Motion
- None.

## Flutter
- Build a small KeyHint widget (a Container with `radius-xs` and a Text). Show it only on wide layouts, after a hardware key press.
- Reads `text-secondary`, `divider-strong` and `on-accent`.

## Do
- Show hints on wide screens only, and only after a hardware key was used.
- Use real key names.

## Don't
- Don't show hints on phone.
- Don't use a hint as the only label of a control.
- Don't put a hint on a tertiary or secondary button.

## Placement
After the button label, or at the right end of the search field. `.hint-text` sits at the end of a row, left of the chevron.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.btn--bar:has(.kbd:not([hidden]))`: padding-inline 22px (D72, floating-bar buttons)

## Tokens used
`space-14`, `space-2`, `space-6`, `radius-xs`, `type-web-key-hint-sm`, `tracking-web-key-hint-sm`, `text-secondary`, `border-ring`, `divider-strong`, `type-web-tag`, `tracking-web-tag`, `space-8`, `kbd-on-fill`, `on-accent`, `text-disabled`, `type-web-small`, `tracking-web-small`

## Status
Approved (from the boards); changed in 2.0: standalone text `text-secondary`, in-button overlay black 16%, hidden on touch, `.hint-text` class added for text hints. Changed in 3.0: in-button chip color is the `kbd-on-fill` role (was a literal, R2-O24); hint style `web-key-hint-sm`, in-button `web-tag` (web-key-hint merged, R2-O22).
