Popover is a small floating surface anchored to the control that opened it. It has three recipes: an action menu, a single-select picker and a generic panel.

## When to use
- Use the menu for a short list of actions on one item. Use the picker to choose one value from a short list (fewer than six). Use the panel for a little read-only detail.
- For six or more options with a visible value use Select, which opens this same surface.
- Don't put forms or a second menu level inside. Don't use it for destructive confirmation (use Dialog).

## Anatomy
- Surface `surface-card`, radius `radius-lg` 14, padding 6, `elev-popover`. Minimum width 200, maximum width 380 (or the viewport minus 32). Maximum height 360, then it scrolls.
- Item: 40px minimum, radius `radius-md` 12, padding 8px 12px, 15/400. Labels wrap. Gap 10.
- Selected item: `accent-tint` fill, `accent-tint-text` and weight 600. The picker adds a check at the end (`.popover__check`).
- Separator `.popover__sep`: a 0.5px `divider` rule with 6px and 8px margins.
- The popover is `z-popover` 60, above modals (`z-modal` 50).
- It sits 8px below its trigger. It flips above, or shifts sideways, when it would leave the viewport.

## Variants and props
- Menu: `role="menu"`, items `role="menuitem"`. The trigger has `aria-haspopup="menu"`.
- Picker: `role="listbox"`, items `role="option"` with `aria-selected`. The trigger has `aria-haspopup="listbox"`.
- Panel: `role="dialog"` with an `aria-label`. It is not modal and does not trap focus. The trigger has `aria-haspopup="dialog"`.
- Every trigger has `aria-expanded` and `aria-controls`.
- The consumer provides the trigger, the items, and the position container.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="popover" role="menu" id="pm-menu" aria-label="Options">
  <button type="button" class="popover__item" role="menuitem" tabindex="-1">Edit Note</button>
  <button type="button" class="popover__item" role="menuitem" tabindex="-1">Duplicate Note</button>
  <!-- 1 more -->
  <button type="button" class="popover__item" role="menuitem" tabindex="-1">Share Note</button>
  <div class="popover__sep" role="separator"></div>
  <button type="button" class="popover__item" role="menuitem" tabindex="-1">Delete Note</button>
</div>
```

## States
- Item rest: transparent. Hover or keyboard highlight: `surface-hover`. Selected: `accent-tint`. Disabled: `aria-disabled="true"` and `text-disabled`.
- Keyboard focus: 2px `accent` outline, offset -2px, inside the item.
- Open: the trigger shows `aria-expanded="true"`.
- Exiting: add `.is-exiting`, wait for the animation, then unmount.
- Empty: `.popover__empty` shows a one-line message in `text-secondary`.
- Empty (`.popover__empty`): shown only while no option is visible; set `hidden` otherwise (the bundle makes `[hidden]` win over any component display, R3-A08).

## Keyboard
- Down Arrow on the trigger opens it and focuses the selected item, or the first. Enter and Space also open it.
- Up and Down Arrow move between items and wrap. Home and End jump to the first and last.
- Typing letters jumps to the item that starts with them (typeahead).
- Enter or Space chooses the item. Esc closes it and returns focus to the trigger. Tab closes it.
- An outside click closes it.

## Accessibility
- Set the roles and trigger attributes above. Skip disabled items when moving.
- Announce a choice in a polite live region (`role="status"`), for example "Strongest first selected".
- A selected item shows a check as well as the tint, so selection is not color alone.
- Items are 40px with a padded 44px hit area on touch (`pointer: coarse`).

## Motion
- Opens in 240ms (`dur-medium-1`): rises 8px and fades in on `motion-move`.
- Closes the same way in reverse with `.is-exiting`.
- Reduced motion: it fades in place over 150ms with no rise.

## Flutter
- Build the menu on MenuAnchor with `MenuItemButton` rows. For the picker reuse the list from Select.
- Reads `surface-card` [`surface`], `accent-tint`, `accent-tint-text`, `surface-hover`, `text-primary` and `text-disabled`.

## Do
- Close on Esc, an outside click and selection. Return focus to the trigger.
- Keep labels short and let them wrap when they must.
- Flip above or shift sideways instead of clipping.

## Don't
- Don't put forms or more than one level of menu inside.
- Don't use it for destructive confirmation.
- Don't open it on hover only.

## Placement
Below or above its trigger, 8px away, aligned to the trigger's edge.

## Tokens used
`border-focus`, `accent`, `z-popover`, `space-6`, `radius-lg`, `surface-card`, `text-primary`, `elev-popover`, `dur-medium-1`, `motion-move`, `space-10`, `space-8`, `space-12`, `radius-md`, `type-web-row-value`, `tracking-web-row-value`, `dur-short-2`, `motion-fade`, `surface-hover`, `accent-tint-text`, `accent-tint`, `text-disabled`, `border-hairline`, `divider`, `type-web-sub`, `tracking-web-sub`, `text-secondary`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: three recipes with roles, full keyboard, collision flip, maximum height 360, `.popover__check` and `.popover__sep`. Changed in 3.1: `[hidden]` wins (R3-A08).
