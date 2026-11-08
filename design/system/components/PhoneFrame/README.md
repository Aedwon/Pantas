PhoneFrame is the page frame on a phone. It has a 44px nav bar, a scrolling body, and a floating tab bar or a bottom action.

## When to use
- Use it for every phone screen, under 600px wide.
- Don't use it on tablets and desktops (use TabletLayout and AppShell). Don't put both a tab bar and a bottom action on one screen.

## Anatomy
- `.phone-frame`: full width up to 390 (`layout-phone-frame`), centered, `bg-page`. `.phone-frame--contained` fixes 844 high and clips, for previews only.
- Nav bar `.phone-nav`: 44 high, padding 6 8 0 4. Back link `.back.back--phone` at the left, an optional text button (`btn--text-phone`) at the right.
- Screen container `.phone-screen` (CHANGE, R2-O16: renamed from `.phone-body`, which is the body type style): gutter 16 (`layout-gutter-phone`), top 8, bottom 24, gap 24 (`space-24`). One `phone-large-title` per screen. The screen is a size container (`container-name: phone-screen`): under `layout-title-narrow` (12rem of screen width: a 320 phone at 150% text or more, a 390 phone at 200%) the large title steps down two steps to `phone-title-2` (22px, 44px at 200% text), as board G6 A draws it (D180). Words still break as a last resort (`overflow-wrap: break-word` on headings), so a title never passes the screen edge (WCAG 1.4.10). The step-down also applies to a `.shell` page below 1024, where the one-markup `web-h1` takes the phone large title by the tier swap: there the `.main` is the size container (D189). It applies wherever the phone large title shows.
- Bottom reserves (usage gap 13): `.phone-screen--tabs` 104 (24 lift + 64 bar + 16 air) for the TabBar; `.phone-screen--bar` 104 (16 + 64 + 24) for the floating quiz bar; `.phone-screen--bottom` 120 for one `.phone-bottom` button, `.phone-screen--bottom-2` 180 for two. Each adds the safe area.
- Sections: `.group-sec` blocks 24 apart (`space-24`). Put them in one container so they do not add the body gap on top.
- TabBar `.tabbar-dock > .tabbar`: floating pill, 64 high (`size-tabbar`), inset 16 at each side (`layout-tabbar-inset`), maximum 358 (`layout-tabbar-max`).
- The pill sits 24 above the bottom (`layout-tabbar-bottom`), or 8 above the safe area if that is higher.
- Items: four `a.tabbar__item` of 52 (`size-tabbar-item`). The `.tabbar__marker` sits under the active item, `accent-tint`.
- Bottom action `.phone-bottom`: padding 14 16 30, or 16 above the safe area. It has a fade from transparent to `bg-page`.
- It holds one `btn--phone`: 52 high, full width, radius 14.
- The tab bar is a floating pill. The approved phone boards draw it that way.

## Variants and props
- Tabs: `.phone-screen--tabs` with the dock. Bottom action: `.phone-bottom` with one button, or a pair in DOM order secondary then main (reverse stack), or a `.cta-block` with its fine print; no dock (R4R-O06).
- The active tab is navigation, not a button: use `a` with `aria-current="page"`.
- The consumer provides the title, the sections and the actions.
- Safe areas: use `env(safe-area-inset-*)`. Do not hard-code notch sizes.
- Reserves (ruling 3): `.phone-screen--tabs` reserves `layout-reserve-tabbar` (6.5rem) plus the safe area, so it grows with text. `.phone-bottom` (the bottom action bar) and `.fbar-dock--phone` (the phone quiz bar) are sticky at the end of the screen: they take their own height in the flow, so at any text size nothing ends up under them. Make the bar the last child of the frame; `--bottom` and `--bottom-2` now reserve only 8, `--bar` 16.
- The frame clips sideways overflow with `overflow-x: clip` (it does not become a scroll container, so sticky bars work).
- Bottom action bar `.phone-bottom` (ruling 9): DOM order secondary then main; it stacks in reverse, so the main action is on top. Group a button with its fine print in a `.cta-block`.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="phone-frame phone-frame--contained">
  <div class="phone-nav">
    <a class="back back--phone" href="#">
      <!-- content -->
    </a>
    <button type="button" class="btn btn--text-phone btn--tertiary btn--accent">Edit</button>
  </div>
  <div class="phone-screen phone-screen--tabs">
    <h1 class="phone-large-title">Study</h1>
    <div>
      <!-- content -->
    </div>
  </div>
  <div class="tabbar-dock tabbar-dock--contained">
    <nav class="tabbar" aria-label="Main">
      <!-- content -->
    </nav>
  </div>
</div>
```

## States
- Tab rest `text-secondary`, active `accent-tint-text` on an `accent-tint` marker, pressed scale 0.96, keyboard focus 2px `accent` ring.
- Back link: hover tint, pressed scale 0.97, focus ring. The button follows Button states.
- Disabled bottom action: `fill` with `text-disabled`.

## Keyboard
- Tab goes through the nav bar, the body, then the tab bar or the bottom action.
- Enter opens the tab. Enter or Space presses the bottom action.

## Accessibility
- Give the tab bar `nav` with `aria-label="Main"`. Mark the active tab with `aria-current="page"`.
- Each tab shows an icon and a text label. The label stays visible.
- Targets are at least 44px: tabs are 52, the nav bar is 44, the action is 52.
- The bottom action covers content with a fade. Leave room under the last row so nothing is stuck beneath it.

## Motion
- The tab marker moves 240ms (`dur-medium-1`) with `motion-move`.
- Reduced motion: the marker jumps at once.

## Flutter
- Use FloatingTabBarScope for the tab bar and its reserve, PantasPage for the body, and WebBottomBar or FloatingBar for the bottom action.
- Large title (D180): when the screen width less the two gutters, divided by `MediaQuery.textScalerOf(context).scale(16)` (the width in rem), is under 12 (`layout-title-narrow`), use the `phone-title-2` style for the large title. Words still wrap; never clip.
- Reads `bg-page`, `surface-card` [`surface`], `accent-tint`, `accent-tint-text` and `text-secondary`. The gutter and reserve come from WebTokens.

## Do
- Keep 16px gutters and 24px between sections.
- Reserve 104px at the bottom of scrolling content.
- Use one large title per screen.

## Don't
- Don't draw a status bar in the layout.
- Don't make the active tab look like a button.
- Don't show a tab bar over a screen with a bottom action.

## Placement
The whole phone screen. Nav bar at the top, body below, floating pill or fade-and-button at the bottom.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.phone-bottom`: padding 30px (phone board 14px 16px 30px)

## Tokens used
`layout-title-narrow`, `layout-tabbar-bottom`, `space-8`, `layout-reserve-tabbar`, `layout-bar-bottom`, `size-bar`, `space-12`, `layout-bar-bottom-phone`, `layout-reserve-bar-phone`, `layout-tabbar-inset`, `z-nav`, `layout-tabbar-max`, `layout-phone-frame`, `bg-page`, `text-primary`, `space-6`, `space-4`, `space-24`, `layout-gutter-phone`, `space-16`, `space-14`, `layout-tablet-column`

## Status
Draft (new in 2.0). Source: the approved phone boards (floating pill) and the phone frame notes: 390 reference, 16 gutter, 44 nav bar, 104 reserve. Changed in 3.0: `.phone-screen` container renamed from `.phone-body` (R2-O16); bottom reserves for the bar and the bottom action. Changed in 3.1: rem reserves and the sticky bottom bar (ruling 3). Changed in 3.2: the bottom bar reverse-stacks its pair (ruling 9); no inline marker index (R4-O12). Changed in 3.3: the large title steps down at large text (CHANGE D180). Changed in 3.4.0: the step-down also reaches a `.shell` page below 1024; the old container name is fixed; Flutter title rule (D189).
