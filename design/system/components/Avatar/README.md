Avatar is a round marker for the learner: their initial, or their photo if they added one.

## When to use
- Use it in the sidebar account area and in the Settings profile row.
- Don't use it for a subject or a teacher. Don't use it as a button. Put the action on the row around it.

## Anatomy
- Sizes: 30px for the sidebar (`size-avatar`), 44px for the Settings profile row (`size-avatar-lg`). `radius-full`.
- Letter: `accent-tint` fill, `accent-tint-text` text, 14/700 (`web-label` at 700; 44px: `web-h3`, 20/700). CHANGE (R2-O01): the 44px initial 19 to 20, so it maps to a style. Use the first letter of the first name, uppercase.
- Image: fills the circle with `object-fit: cover`.
- Settings row: `.row.row--settings` with the avatar in the lead slot, the name as `.row__title--strong` (16/600) and the email as `.row__sub` (14/400, `text-secondary`).

## Variants and props
- `.avatar` (30px) and `.avatar--lg` (44px).
- Letter: the consumer provides one character.
- Image: the consumer provides the photo URL. Fall back to the letter if the image fails to load.
- The initial is `web-glyph` (14/700/1; R3-O09: a style, not a weight override).

## States
- Static. It has no hover, pressed, selected or disabled state.
- The profile row around it takes hover (`surface-hover`) and keyboard focus (2px `accent` outline, offset -2px).
- Empty: if the name is missing, hide the avatar. Don't show a question mark.

## Keyboard
- The avatar takes no keys. The row link takes Tab and Enter.

## Accessibility
- Next to the name as text, mark the avatar `aria-hidden` and leave the image `alt=""`.
- Alone, give it `role="img"` and `aria-label` with the full name.
- The letter on `accent-tint` is 4.5:1 in light and 8.1:1 in dark.

## Motion
- None.

## Flutter
- Build PantasAvatar on CircleAvatar with a Text initial or a NetworkImage and an `errorBuilder` fallback.
- Reads `accent-tint` and `accent-tint-text`.

## Do
- Keep the circle. Avatars may be round.
- Show the learner's name as text beside it.

## Don't
- Don't use a photo from the web as a placeholder.
- Don't add a status dot or a badge.

## Placement
Sidebar, below the navigation, left of the account name. Settings, lead of the first row.

## Tokens used
`size-avatar`, `radius-full`, `accent-tint`, `accent-tint-text`, `type-web-glyph`, `tracking-web-glyph`, `size-avatar-lg`, `type-web-h3`, `tracking-web-h3`

## Status
Draft (new in 2.0). Source: the sidebar avatar (30px) and the Settings profile row (44px, initial 19/700). Changed in 3.0: 44px initial 20/700 (`web-h3`). Changed in 3.1: `web-glyph`.
