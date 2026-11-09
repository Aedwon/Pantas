# Governance

How the system changes, who decides, and what every addition must carry.

## Precedence
When two sources disagree, the higher one wins:
1. Aedwon's fixed decisions: Ink and Rule is retired; teal accent; Geist; no full-width buttons on wide screens; text actions and ghost buttons highlight as rounded rectangles, and pill buttons appear only where the approved boards draw them (floating bar, phone dialog pair, compact pills), never as decorative labels (D188); P2 placement (wide: actions at the right end, main last); the phone is the motion reference; approved motion is never removed; red only for destructive or wrong; back link A; Title Case labels; teal text link with a 4px arrow nudge for secondary navigation.
2. Recorded decisions (a Decisions line marked approved, or a lead ruling under Aedwon's delegation). Both are final.
3. The normative text of this system: README rules, `patterns.md`, `motion.md`, component READMEs.
4. Examples: previews, sample copy, diagrams.

## Approval
Aedwon delegated the design decisions to the lead. On Nov 8 he wrote "um you can decide for me based on the design system and whichever is the best for UX. for refinements, please ensure the following are being considered * WCAG 2.0 AA * Apple HIG"; earlier he wrote "you decide for me (unless it's something absolutely necessary that I decide)".
- A decision the lead makes under this delegation is final when it is recorded in Decisions. It is not a proposal and it waits for no review.
- A CHANGE line is final too. It ships in the next release, and the release number follows Versioning.
- Only two kinds of decision go to Aedwon: one he explicitly keeps for himself, and one that is absolutely necessary for him to make. The lead asks in chat and records his answer as [Approved by Aedwon, date].
- A reviewer may still flag a lead ruling as a CHALLENGE finding. The lead settles it and records the result.

## Decisions register
- The README section "Decisions" is the register. Each line has a stable number that is never reused or renumbered.
- A line records what changed, from, to and why. CHANGE means a value already drawn or built moved.
- Status is written in brackets at the end of a line. Only these statuses exist (R2-O18):
  - [Approved by Aedwon, date]: settled by Aedwon.
  - [Lead ruling (delegated, date)]: settled by the lead under Aedwon's delegation. A reviewer may flag one only as a CHALLENGE finding.
  - [Lead ruling (Aedwon: "words", date)]: the lead applied an instruction Aedwon gave in chat, quoted in the brackets (D189).
  - [Rejected: reverted, date].
  - [Superseded by Dn], [Amended by Dn], [Resolved by Dn], [Duplicate of Dn]: a later line replaces, changes, closes or repeats this one. A short note may follow a colon.
- A line with no status is a chosen value, final when recorded (Approval). The README's "Open items" list names work that waits on a missing file or on app code. It holds no decisions.
- When Aedwon approves a line, the rule it states moves into the normative text and the line keeps its number with the status.

## Versioning
`tokens.json` `version` is a semver string ("4.0.0"). The system follows semantic versioning:
- Major: a token or class is removed or renamed, or a value change alters an approved board.
- Minor: a new token, component, variant or class, with old names kept.
- Patch: a value fix inside a decision already approved, a typo, a documentation fix.
A class contract that changes before any product consumes it needs no deprecation (3.2.0: `.qpanel.is-open` on every tier; 3.3.0: `.week-legend` and the TabBar icon-only mode were removed because no product consumes them yet; D189). Once a product consumes a class, the deprecation rule applies.
Deprecated names stay until the next major version, then go (one rule, used in `tokens.json` notes, the Flutter generator and component READMEs). A deprecated token's usage note says "Deprecated", names its replacement and the version that removes it. The major release removes every name so marked.

## Changelog

### 4.0.1 (Nov 9, 2026), patch
- Changed: CHANGE (D192): the ReaderTopBar back is the BackLink with the parent's name, plus the Esc KeyHint on wide screens; the bar's first column fits the link. No token or class added or removed.

### 4.0.0 (Nov 8, 2026), major
- Approval rule changed (D191): decisions the lead makes under Aedwon's delegation are final when recorded. The "proposal", "awaiting review" and "[Still open: Aedwon's review]" wording is gone. The README section "Decisions to review" is now "Decisions", and "Open for Aedwon" is now "Open items" (the icon files D41, the Source Serif 4 font files D91, the Mock exam phone layout D170); none is a decision. Only a decision Aedwon keeps for himself, or one that is absolutely necessary for him, goes to him.
- Removed names (all deprecated in 3.0.0 to 3.2.0): tokens `text-past` (use `text-secondary`), `size-btn-md` (use `size-btn-bar`), `bp-desktop` (use `bp-tablet-landscape` and `bp-wide`), `size-icon-sm` and `size-gauge-h`; type styles `web-math` and `phone-math` (use `.math`); classes `.chart__line` (use per-column `.chart__seg`), `.focus-head--phone` (use `.focus-head`), `.tablet-column` and `.main--tablet` (use AppShell). The renamed private properties `--_h` and `--_p` (now `--h` and `--p`) have no old name left. Kept: `figure-viewer-bg` (the Flutter viewer reads it).
- Also fixed: the Chart README named the second-series line class `.chart__series--b`, which only `.chart__line` used; it is `.chart__seg--b`. The FocusHeader previews of the phone class and the TabletLayout previews no longer use removed classes.

### 3.4.1 (Nov 8, 2026), patch
- Fixed: "Open for Aedwon" left out the round 1 CHANGE lines (D18, D45 to D93); it pointed to a review page, which 4.0.0 retired (D191). No value changes.

### 3.4.0 (Nov 8, 2026), minor
- Fixed (D189, the 27 findings of the 3.3.2 audit): stale pill and version wording; `tokens.json` radius notes name every pill (the Flutter source no longer says "Never a button"); the large-title step-down also reaches a `.shell` page below 1024; the TabBar label cap is a named text-scaling exception with Flutter guidance; Dialog, SectionHeader, Columns and WeekStrip rules agree; "Open for Aedwon" rebuilt; Tokens used lists and Status lines refreshed.
- Fixed (D190, the 16 findings of the outside review of 3.3.2): reduced motion covers the search panel; the SegmentedControl touch target is a real 44px button; the SelectableTile tag is in a header slot and never covers a title at large text; the WeekStrip tooltip is hoverable and persistent; the study-day row keeps 44px columns and scrolls on narrow phones; wheel rows follow the scaled line and the month wheel shortens names on narrow groups; supporting text on the selected card is AA; forced colors cover ARIA selection states and the slider; the explanation drawer example is no longer inert; the flag toggle fills when on; the Flutter reader keeps the OS text scaler; the Field input fills its well; wrapped Columns are documented as they behave; the collapse recipe names `--h`; a hidden chart column is readable through a visible "Show Table" button.
- Added: data property `--x` (the WeekStrip tooltip placement, replacing an inline `left`); class `btn--pill-sm` (the compact pill the approved onboarding board draws for "Retry"); a forced-colors border on `.tooltip`; token `layout-wheel-full` (21rem); classes `wheel__full`, `wheel__short`, `chart__table` and `glyph-fill-on` (D190); `chart__table-toggle` is now used. Version note: by the Versioning rule the additions are a minor, so the release is 3.4.0 (the first pass labeled it 3.3.3 before the review added classes and a token); the CHANGE lines became final in 4.0.0 (D191).
- Changed: CHANGE (D189): a `.sec-head` directly inside a card drops its 4px side padding, so title and link sit on the card's 20px inset. CHANGE (D190): the study-day row's gap shrinks from 10px toward 4px so each day keeps 44px; supporting text on a selected card uses `text-on-tint-secondary`; the flag toggle is a filled glyph when on.
- Removed before release: `btn--pill-xs` and `size-btn-pill-xs` (added in the first pass, never published): the board "Replay" is a board playback control, not an app control (D190).

### 3.3.2 (Nov 8, 2026), patch
- Decided (D188): status tags keep the pill shape; decorative eyebrow pills (a capsule, dot or icon around a label above a heading) are never used. Rule text in Principle 3, Tag and SectionHeader. No value changes.

### 3.3.1 (Nov 8, 2026), patch
- Fixed (D187, undoes D29): the floating-bar counter and action (`.cnt`, `btn--bar`) and the phone dialog pair (`btn--dialog`) are pills again (`radius-full`), as the approved boards draw them. Aedwon's "no pills" rule meant decorative text labels (eyebrows), not buttons; status tag pills are kept (D188). Text actions and ghost buttons still highlight as rounded rectangles. No token value changes. Tag shape is under review (D188).

### 3.3.0 (Nov 8, 2026), board picks
- Added: tokens `layout-title-narrow` (12rem) and `size-tab-label-max` (12px). The `.phone-screen` container and one `@container` rule; a `.tooltip` use inside `.week`.
- Changed: Decisions 179 to 186, all lead rulings delegated by Aedwon on Nov 8. CHANGE lines: D180 (the phone large title steps down to title 2 at large text), D181 (TabBar labels never drop to icons; they stop at 12px), D183 (`.cta-card` padding 24 to 20), D186 (the WeekStrip legend is removed; each day with a status shows a Tooltip, `aria-hidden`). D179 keeps the 13px row padding; D182 tiles top-align and the tag sits on the top edge; D184 the first card of a column holds its header; D185 a wrapped ExamChip sits on its own line without the hairline.
- Removed: `.week-legend` (and its forced-colors rules), the TabBar icon-only mode. Both fall under the pre-production exception in Versioning: no product consumes them yet, so there is no deprecation period (D189). `.page-head__after` stays as an empty slot.
- Build: `tools/build_css.py` allows a `font-size` on `.tabbar__item` (the 12px cap).

### 3.2.1 (Nov 8, 2026), patch
- Fixed (D178, a value fix inside the settled D137): a row's title keeps 6em, not 8em, before its value stacks, so approved board rows stay on one line at 100% text (DK_Settings "Practice" with "10 questions" in a 300px column); the ListRow chevron sits outside the wrap at the row end, so it never takes a line of its own at 320px or at large text. No token, class or board value changes.
- Build: the round 4 stage runs a row check (`r4/tools/rows_check.js`): board rows on one line at 100% text, no chevron alone on a line at 320px and 200% text, the Settings row still stacking at 200%.

### 3.2.0 (Nov 8, 2026), review round 4
- Added: tokens `opacity-hover`, `opacity-spinner-track`, `opacity-bar-ring`, `opacity-ripple`, `opacity-scroll-edge`, `layout-focus-head-phone`, `size-slider-track-min`, `size-tile-min`, `layout-focus-head-narrow`, `layout-slider-narrow`; classes `.row--split`, `.row__main`, `.row__action`, `.choice-tree`, `.choice-tree__children`, `.choice--parent`, `.choice--all`, `.choice__meta`, `.wheel-group`, `.card__head`, `.pbar-head`, `.pbar-head__label`, `.pbar-head__value`, `.slider__end`, `.seg__track`, `.sheet--reader`, `.scrim--qpanel`, `.scrim--xpl`; a "Markup" section in every README of a component with nested classes.
- Deprecated (removed in 4.0.0): `.chart__line` (use per-column `.chart__seg`), `.focus-head--phone` (the one-markup FocusHeader is 44px on phones). Un-deprecated: `figure-viewer-bg` (the Flutter viewer reads it).
- Changed: the values in Decisions 155 to 177 (CHANGE lines: D158, D160, D167). Slider, tile grid and FocusHeader rules for large text; split rows; grouped checkboxes; the wheel group; modal focus panels with real scrims; one question-list state (`.qpanel.is-open`; wide no longer reads `.is-hidden`); reverse-stacked full-width pairs on phones and tablets; lesson scale in reader sheets; week dots by state in forced colors; promo card text; state washes from `opacity-hover`; passage reserves in rem; the clipped chart note only when a column is hidden; the `.main--tablet` reserve removed; question rows as grids.
- Build: the checks ship with the system as `tools/build_css.py` (round 4 adds container widths, bottom reserves, and `--check`, which writes nothing, beside `--write`), `tools/contrast.py` (washes from `opacity-hover`, promo and tile rows), `tools/flutter_names.py` (fails on deprecated names outside a deprecation note) and `tools/validate.py`. Review-round scripts are history only.

### 3.1.0 (Nov 8, 2026), review round 3
- Added: roles `surface-modal-hover`, `scrim-search`, `hero-start`, `hero-mid`, `hero-end`, `topic-done-end`, `share-end`, `on-hero`, `on-hero-secondary`; styles `phone-option`, `phone-tab-label`, `phone-wheel`, `web-stat-value`, `web-chip-name`, `web-glyph`, `web-search-input`; `phoneScale` on wide styles (the tier type map); tokens `size-btn-bar`, `size-btn-xs`, `size-chart-col`, `size-ring-stroke`, `size-thread`, `size-search-field`, `size-tooltip-max`, `border-ring-current`, `layout-qpanel`, `layout-search`, `layout-search-top`, `layout-reader-title-scroll`, `layout-reader-hide-scroll`, `layout-reserve-tabbar`, `layout-reserve-bar-phone`, `layout-reserve-bar`, `bp-wide`, `dur-tooltip`; components ReaderLayout, ReaderTopBar, Tooltip, SearchOverlay; classes `.btn--xs`, `.btn--text-phone-sm`, `.dialog__actions--stack`, `.seg--fill`, `.stat-row--link`, `.choice-tile--plan`, `.choice-grid--plans`, `.card--hero`, `.card--promo`, `.card--topic-done`, `.card--share`, `.hero-list`, `.cta-block`, `.fine-print`, `.timer--inline`, `.acc-row`, `.qnav__row`, `.xpl__foot`, `.chart__seg`, `.chart__clipped`, `.frac`, `.stack--24`, `.passage.is-expanded`, `.qpanel.is-open`.
- Deprecated (removed in 4.0.0, except `figure-viewer-bg`): `size-btn-md` (renamed `size-btn-bar`), `figure-viewer-bg`, `bp-desktop`, styles `web-math` and `phone-math`, `.tablet-column`, `.main--tablet`. Renamed private properties `--_h` and `--_p` to `--h` and `--p`.
- Changed: the values in Decisions 121 to 154 (CHANGE lines: D123, D124, D126, D127, D133, D136, D141, D144, D148). One markup across tiers; the sidebar from 1024; rows stack by themselves at large text; the lesson scale reaches every reader component; reserves in rem; the mock flag in the question header.
- Build: `build_css_r3.py` (round 2 checks plus the rest-weight check), `contrast_r3.py` (composited state washes, hover-equals-ground), `flutter_names.py` (Dart identifiers from `tokens.json`: collisions, reserved words, illegal names, missing fields, README references). `r3/scripts/all.sh` rebuilds rounds 2 and 3.

### 3.0.0 (Nov 7, 2026), review round 2
- Removed (deprecated in 2.0.0 or equal-valued): `text-muted`; button aliases `btn--tonal`, `btn--ghost`, `btn--ghost-teal`, `btn--ghost-red`, `btn--danger`; `dur-instant`; `size-week-day-phone`; `layout-cols-gap`; type styles `web-seg`, `web-back`, `web-key-hint`. Renamed: the phone screen container `.phone-body` to `.phone-screen`; primitive `teal-550` to `gray-550`. Deprecated: `text-past`.
- Added: roles `surface-modal`, `kbd-on-fill`, `toast-action-hover`; styles `web-field-label`, `web-title-sm`, `web-timer`, `web-explanation`, `web-reader-block`, `math-display`; tokens `bp-phone-narrow`, `layout-passage`, `layout-passage-max`, `size-chart-h`; components Passage, Figure (with FigureViewer), Chart, DataTable; classes `.btn--secondary.btn--critical`, `.field__action`, `.select-native`, `.choice-group`, `.week__days`, `.page-head--question`, `.page-head__title-row`, `.page-head__after`, `.fbar--stack`, `.sidebar__search`, `.phone-screen--bar`, `--bottom`, `--bottom-2`, `.stage--passage`.
- Changed: Checkbox, Radio and Switch are native inputs; data values come from `--value`; every component font comes from `--type-*`; the shell switch and the focus split are built; toasts clear the bottom bars; System theme and `color-scheme`; the values in Decisions 97 to 120.
- Build: `build_css.py` generates the type block and fails on raw type, off-grid spacing, literal colors, type-class collisions, unresolved var() and media widths that are not `bp-*`; the contrast script tests every color on the ground a component sets; the validator enforces the primitive distance rule.

### 2.0.0 (Nov 7, 2026), review round 1
- Tokens: three tiers (primitives, roles, component roles) with aliases; radius, duration and z-index scales renamed (old names removed: `radius-btn*`, `radius-card`, `radius-inner`, `radius-xcard`, `radius-modal`, `radius-nav`, `radius-check`, `radius-pill`, `dur-press`, `dur-release`, `dur-hover`, `dur-base`, `dur-page`, `dur-push`, `dur-check`, `dur-pop`, `dur-dialog-open`, `dur-dialog-close`, `dur-drawer-open`, `dur-rise`, `dur-draw`, `dur-fill`, `dur-spin`, `z-bar`, `z-scrim`, `z-drawer`, `elev-bar-drop`, `size-bar5`, `size-bar5-rows`, `size-hit-min`, `size-btn-bar`, `size-btn-dialog-phone`, `size-btn-notice-phone`, `reader-warn*`); `text-muted` deprecated; new roles for boundaries, warning, tint text, finale red; new layout, size, motion and opacity tokens; web type in rem with line heights on every style.
- Values: the round 1 CHANGE lines, Decisions 44 to 95.
- CSS: base layer, layout layer, every approved motion built, overlay contract, input-based target and hover rules, reduced-motion rules, forced-colors rules.
- Components: 21 added (TaskStatus, Gauge, StatRow, SectionHeader, LinkTile, Avatar, Select, Slider, DatePicker, SelectableTile, ProgressBar, Timer, Explanation, QuestionNavigator, ReaderBlock, FocusHeader, AppShell, Columns, FocusLayout, PhoneFrame, TabletLayout); all 36 others updated to one README template with keyboard, accessibility, Flutter and status sections.
- Docs: `patterns.md` gains navigation model, loading, offline and sync, confirm or undo, Pro gating, onboarding, shortcuts, search and data display; `motion.md` gains Flutter values and choreography lifecycles; this file.

### 1.0.0 (Nov 7, 2026)
- First full system from the approved canvases.

## Component status
- Approved: built from approved boards; its values match them or carry a Decisions line.
- Draft: new or with chosen values; usable. The chosen values are final once recorded in Decisions.
- Deprecated: kept for compatibility; says what replaces it.
Every component README ends with its status and its source.

## Contribution checklist
A new token, component or variant is ready when:
1. Every value is a token, or a component internal named in its README. No hex in components. Fonts only through `--type-*`. `tools/build_css.py`, `tools/contrast.py`, `tools/flutter_names.py` and `tools/validate.py` pass.
2. Both themes are filled and checked; every new text, icon or boundary pair is in the README contrast table and passes, or carries an exemption or a Decisions line.
3. Every state is shown: rest, hover, pressed, keyboard focus, selected, disabled, busy, empty, error as relevant, and the combined states (invalid and focused, busy and focused, selected and disabled).
4. Keyboard and screen reader behavior is written and shown: role, accessible name, state attributes, announcements.
5. It works at 320px wide and at 200% text, under reduced motion and in forced colors.
6. Motion matches the phone; any phone motion is built, with its Flutter values.
7. The README follows the template and names the Flutter widget and the tokens it reads (token names; fields come from the naming rule, and `flutter_names.py` passes).
8. A value chosen with no source gets a Decisions line; a value that moves an approved board gets a CHANGE line.
9. The changelog and the version are updated.
10. Every README section of the template is present, with "None." where a section does not apply (Motion included). A component with nested classes has a "Markup" section with a minimal example (ruling 10).

## Acceptance matrix
Each component is checked against:

| Check | How |
|---|---|
| Both themes | preview light and dark panels |
| Contrast | the README table, generated from the resolved tokens |
| Every state, including combined states | preview |
| Keyboard | Tab order, arrows inside groups, Esc, Enter |
| Screen reader | role, name, state, announcement once |
| Text scaling | 200% text at 320px: nothing clipped, nothing overlaps |
| Touch targets | 44px under `pointer: coarse` |
| Reduced motion | end states, no spatial motion, no loops |
| Forced colors | boundaries, selection, focus and data marks still visible (Chromium "Emulate forced-colors"); WeekStrip shows dots only on done and half days |
| Lesson scale | reader content at lesson scale 2, including the phone passage Sheet (`.sheet--reader`) |
| Markup | the README example renders as the preview does |
| One markup | the page at 390, 600, 1024 and 1440 from the same markup |
| Inline styles | only the data and state properties the README lists |
| Flutter mapping | widget and fields named |
