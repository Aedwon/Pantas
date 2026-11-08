TabBar is the floating bottom navigation: four destinations in a rounded bar above the content, on phone, tablet portrait and tablet landscape.

## When to use
- Use it for the four main destinations below 1024px: phone and tablet.
- From 1024px use SidebarNav. Don't show it in focus mode (quiz, mock).
- Don't add a fifth item or a badge-only item.

## Anatomy
- Bar `.tabbar`: 64px high (`size-tabbar`), `surface-card`, a 1px `edge-bar` edge and `elev-bar`. Fully rounded (`radius-full`): the pill shape is kept by ruling, because the bar is navigation, not a button. D29 is superseded by D187, which leaves the TabBar a pill.
- Padding 6px, items 2px apart. Inset 16px (`layout-tabbar-inset`) and 24px above the bottom edge (`layout-tabbar-bottom`), or safe area plus 8px.
- Item: 52px high (`size-tabbar-item`), icon 23px, label `phone-tab-label` (10/500) in `text-secondary` (R3-O09: a style of its own, not a weight override). At large text the label grows only to 12px (`size-tab-label-max`), so four labels stay beside their icons at 320 wide and 200% text (D181, board G13 B). Icon `icon-muted`.
- Text scaling exception (D181, D189): this label is the one UI text that stops below the 2.0 clamp. Tab labels follow iOS, which does not grow tab labels with Dynamic Type, so the label grows at most 1.2x (10px to 12px). Browser zoom still scales it. The label stays visible; the web keeps it as the accessible name.
- Active marker: a real `.tabbar__marker` element, `accent-tint`, under the active item. The count and the current tab come from the markup through `:has()` (3 to 5 items); no inline `--n` or `--i` (R3-O12).
- Active item: label 600 and icon (stroke 2.1) in `accent-tint-text`.
- CHANGE: the active label and icon in dark moved from #4CC3AC to #7FD8C6 (`accent-tint-text`), because text on `accent-tint` uses `accent-tint-text`. Both pass 4.5:1 (6.3 and 8.1).
- On tablets the bar is centered at 358px at most (`layout-tabbar-max`).

## Variants and props
- Items are links (`a.tabbar__item`) with `aria-current="page"` on the current page.
- `.tabbar-dock` fixes the bar to the bottom. `.tabbar-dock--contained` keeps it inside a frame.
- The consumer provides the four destinations, in the same order as SidebarNav.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<nav class="tabbar" aria-label="Main">
  <span class="tabbar__marker" aria-hidden="true"></span>
  <a class="tabbar__item" href="#" aria-current="page">
    <svg aria-hidden="true">...</svg>
    Home
  </a>
  <a class="tabbar__item" href="#">
    <svg aria-hidden="true">...</svg>
    Study
  </a>
  <!-- 1 more -->
  <a class="tabbar__item" href="#">
    <svg aria-hidden="true">...</svg>
    Settings
  </a>
</nav>
```

## States
- Rest: icon `icon-muted`, label `text-secondary`.
- Pressed: scale 0.96, 120ms down. Keyboard focus: 2px `accent` outline, 2px offset.
- Active: marker `accent-tint`, label and icon `accent-tint-text`.
- No hover state: this bar is for touch. With a pointer on a tablet the press state is enough.
- At large text the labels stay visible and stop at 12px; they never drop to icons (D181). Do not hide a label with `.sr-only`.

## Keyboard
- Tab goes through the four items. Enter activates a link.

## Accessibility
- Wrap the items in `<nav aria-label="Main">`. Use real links with `aria-current="page"`.
- Active is shown by the marker, weight and icon, not by color alone.
- Each item is 52px high and the bar is 64px: both above the 44px target.
- Reserve `layout-reserve-tabbar` (6.5rem, 104px at default text, growing with text) plus the safe area at the bottom of scrolling content (`.phone-screen--tabs`, AppShell main; ruling 3).

## Motion
- The marker slides over 240ms (`dur-medium-1`, `motion-move`). Label and icon color fade over the same time.
- Reduced motion: the marker jumps. Colors fade at 150ms.

## Flutter
- Use FloatingTabBarScope for the bar and its bottom reserve. On tablets use WebTabletNavigation.
- Animate the marker with an AnimatedAlign of 240ms.
- Tab label (D181): wrap the label in `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.2)` (or `textScaler.clamp(maxScaleFactor: 1.2)`), so 10 becomes 12 at most. A long press on a tab shows its label large over the bar, as the iOS Large Content Viewer does (a `GestureDetector.onLongPress` overlay with the label at the full text scale), so a learner at a large text size can read it.
- Reads `surface-card` [`surface`], `accent-tint`, `accent-tint-text`, `text-secondary` and `icon-muted`. Take 358 and 104 from WebTokens.

## Do
- Reserve 104px at the bottom of scrolling content.
- Hide the bar while a sheet with its own footer button is open.

## Don't
- Don't add a fifth item.
- Don't show it in focus mode.
- Don't treat the TabBar as a button style: it is navigation. Most buttons are rounded rectangles; only the floating bar and the phone dialog pair are pills (D187).

## Placement
Fixed at the bottom, centered, below 1024px. Details are in patterns.md.

## Tokens used
`border-focus`, `accent`, `layout-tabbar-bottom`, `space-8`, `layout-reserve-tabbar`, `space-2`, `size-tabbar`, `space-6`, `radius-full`, `surface-card`, `edge-bar`, `elev-bar`, `accent-tint`, `dur-medium-1`, `motion-move`, `size-tabbar-item`, `space-4`, `text-secondary`, `type-phone-tab-label`, `tracking-phone-tab-label`, `dur-short-3`, `icon-muted`, `dur-short-1`, `accent-tint-text`, `layout-tabbar-inset`, `z-nav`, `layout-tabbar-max`, `size-tab-label-max`

## Status
Approved (from the boards); changed in 2.0: real sliding marker, links with `aria-current`, `text-secondary` labels, dark active color #7FD8C6, valid on tablets. Changed in 3.1: marker from `:has()`, `phone-tab-label`, the rem reserve; shown below 1024 (ruling 11). Changed in 3.3: labels never drop to icons and cap at 12px at large text (CHANGE D181). The icon-only mode of 2.0 is removed (no deprecation: no product consumed it, see governance Versioning). Changed in 3.4.0: the 12px cap is a stated text-scaling exception with Flutter guidance (D189).
