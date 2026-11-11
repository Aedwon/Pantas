Columns places a page's blocks side by side on wide screens and stacks them when the space is short. There are four pairs, each fixed for one kind of page.

## When to use
- Use a pair when a page has a main block and a side block that should sit next to each other.
- Don't write a new ratio. Pick one of the four. Don't use columns on the phone (blocks stack in one column).

## Anatomy
- `.cols`: flex, wraps (`flex-wrap`), gap 28 (`layout-section-gap`; `layout-cols-gap` folded in, 3.0.0), items start at the top. There are no media queries.
- Primary and secondary: `.col-primary` (`layout-col-primary`, 1.45 1 480) and `.col-secondary` (`layout-col-secondary`, 1 1 340). Pages: Home, Plan, Performance, Record, Mock setup.
- Picker and panel: `.col-picker` (`layout-col-picker`, 1 1 480) and `.col-panel` (`layout-col-panel`, 0 1 400). The panel is sticky at the top, 28 from the edge (`layout-main-pad-top`), at `z-sticky`. Page: Custom quiz.
- Equal: `.col-equal-a` (`layout-col-equal-a`, 1 1 420) and `.col-equal-b` (`layout-col-equal-b`, 1 1 380). Pages: Quiz tab, Plan day.
- List and detail: `.col-list` (`layout-col-list`, 1 1 300, maximum `layout-col-list-max` 360, inner gap 18) and `.col-detail` (`layout-col-detail`, 999 1 460, inner gap 24). Page: Settings.
- Settings list rows are `.row.row--settings` (16px inset). The detail pane starts with `.page-head.page-head--pane`: an accent icon, a `web-h2` title and a `web-sub` line.
- Column tops line up (D184, board G24 A): the first block of a column is a card, and its section header sits inside it (`.card--pad` holding a `.sec-head` with the `web-h3` title and the link), not above it. Both columns then start on one line. Home: Today's Plan and Accuracy. Blocks that are not cards (More About You) keep their header above, and so does any section that holds several cards or rows (SectionHeader README): the inside-card header is only for the first card of a column (D189).
- CHANGE: the boards and the old rules showed three pairs. The Settings list and pane make four (decision D25). The Settings pair appears on about 60 boards (ST_).

## Variants and props
- Use exactly two children in `.cols`, in the order of the pair.
- The consumer provides the blocks inside each column.
- The current Settings item has `aria-current="true"` on its row.
- Tiers (ruling 11): the pairs wrap by their bases, so below about 850px of content they stack; in the 640 tablet column every pair is one column. No media queries.

## States
- Columns have no states. A wrapped layout is the narrow state: the second column goes under the first. A wrapped block keeps its own width cap: the picker panel stays at its 400 basis and the Settings list at its 360 maximum, left-aligned, while the primary, secondary, picker, equal and detail columns fill the row (D190: documented as the approved stacked variant; no media query releases the caps).
- The panel is always `position: sticky`, but a sticky box cannot leave its container: when it wraps under the picker it is the last child, so the container ends where the panel ends and it has no room to travel; it scrolls with the page (D190, checked in a browser).

## Keyboard
- Reading and Tab order follow the DOM: first column, then second. Put the main block first.
- In the Settings list, Tab goes row by row and Enter opens the pane for that row.

## Accessibility
- Do not use column order to carry meaning. The wrapped order must still read well.
- Give the Settings list `nav` with `aria-label`, and mark the open row with `aria-current="true"`.
- The pane title is an `h2`. The page title stays the only `h1`.

## Motion
- None.

## Flutter
- Use PantasPage with WebLayoutTheme; the column ratios come from WebTokens. Choose the pair by page, not by width.
- Reads `surface-card` [`surface`] for the cards. Wrap with a Wrap or a LayoutBuilder; do not branch on device type.

## Do
- Put the main block first in the DOM.
- Keep 28px between columns and between wrapped rows.
- Use the Settings pair for any list with a detail pane.

## Don't
- Don't add a fifth ratio or a media query.
- Don't make the sticky panel taller than the viewport.
- Don't use a column pair for a single card.

## Placement
Inside `.wrap` (content maximum 1080), below the page head. One `.cols` per band of content. Stack bands with a 28px gap.

## Tokens used
`layout-section-gap`, `layout-col-primary`, `layout-col-secondary`, `layout-col-picker`, `layout-col-panel`, `layout-main-pad-top`, `z-sticky`, `layout-col-equal-a`, `layout-col-equal-b`, `layout-col-list`, `layout-col-list-max`, `space-18`, `layout-col-detail`, `space-24`, `space-14`, `space-12`

## Status
Draft (new in 2.0). Source: the layout rules and about 60 Settings boards (ST_). CHANGE: three pairs become four (D25). In the preview, the page head in the pane adds its own 24px bottom margin on top of the 24px column gap. Changed in 3.1: tier behavior documented (ruling 11). Changed in 3.3: the first block of a column carries its header inside the card (D184). Changed in 3.4.0: the wrapped state is stated as it behaves (D190).
