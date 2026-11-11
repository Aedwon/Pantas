# Patterns

How the components combine. The rules here were decided in review (HANDOFF hard rules, the Nov 7 placement decision P2, the round 1 lead rulings). Where the boards drew several answers, the rulings below choose one. A ruling that changes something already drawn is marked CHANGE and listed in the README under Decisions. "Wide" means 1024px and up.

## Button placement

### Wide screens (P2, approved Nov 7)
- Buttons sit at the right end of their card or dialog, at natural width (`.btn-row`).
- With two buttons, the secondary comes first and the main one last (rightmost).
- Card buttons are 44px. Dialog, notice and row buttons may be `btn--sm` (42px). A large button (50px) is only for the one action a page exists for.
- Gap between two buttons: 8px.
- Never a full-width button on a wide screen. `btn--block` works only below 1024px.

```
Card footer          [ About 15 min                    [ Continue Lesson ] ]
Dialog / notice      [ text ...                [ Cancel ] [ Save ]       ]
Destructive dialog   [                       [ Keep It ] [ Discard (red) ] ]
```

### Uncovered cases (CHANGE, each flagged)
- Centered layouts (empty and error states, ending screens, onboarding welcome): center the single action at its natural width on every tier, the phone included (it is not the screen's main bottom action). A pair is centered, secondary then main.
- Side panels and drawers: the action sits at the panel's bottom right at natural width, not full width. The boards drew a 100% width 50px button.
- A stacked phone-style pair on a wide page (guardian confirm, paused quiz notice) becomes a right-aligned row, secondary then main.
- Settings action rows with no main action (Sign Out, Delete Account) stay left as a row of ghost `btn--sm` buttons (`.row-actions`), the first pulled left so its label lines up with the row text. They are list actions, not a call to action. Destructive goes last.
- Pairs drawn reversed (main then secondary: ST_Pro, HM_ExamPassed) become secondary then main.
- A destructive confirm: the safe choice first (ghost), the red `btn--primary btn--critical` last. A red ghost on the left of a primary is for an unconfirmed destructive option on a page (Discard This Mock), not for a dialog.
- A non-destructive confirm (Sign Out keeps progress) uses the primary button.
- A results page puts Done (primary large) top right, level with the title: the title and Done share `.page-head__title-row`. Results pages stay in focus mode (no sidebar, no TabBar), content in `.wrap`; Done leaves focus mode.
- A card with caption text and an action: caption left, action right (CardFooter). A long caption wraps and the action drops under it on a narrow card.
- A call-to-action card (Home assessment): title, one line, then the action at the right end (`.cta-card`). The board drew the button left-aligned under the text; P2 puts it at the right end.

### Phone and tablet portrait
- The main action fills the width (`btn--phone`, 52px) at the bottom, in a bar over a fade to the page color (`.phone-bottom`, sticky at the end of the screen, so at large text it takes its own height and covers nothing) or inside its card.
- A page built once with the wide classes switches by itself below 1024px (ruling 11): phone type, the TabBar, full-width `.btn--block`, the 640 column on tablets.
- A secondary action is stacked under the main one, same width, tonal or ghost. A destructive secondary is red text (`btn--tertiary btn--critical`), not a red box, until a confirm dialog.
- One markup (ruling 9): the DOM order is secondary then main everywhere. Below 1024 a `.btn-row` of `.btn--block` buttons and the bottom action bar (`.phone-bottom`) stack in reverse, so the main action is on top as the phone boards draw it; focus order then runs secondary first, which is acceptable for a two-button group. A CardFooter pair sits in a `.btn-row`; a button and its fine print sit in a `.cta-block`.
- Side by side pairs only in dialogs (on the phone, `dialog--phone`: 46px pills, `btn--dialog`, secondary left, main right, 10px gap; the secondary is `btn--neutral`; on wide screens `btn--sm` rounded rectangles) and notices (44px, `btn--notice`, 8px gap). The app mounts `dialog--phone` under 600 (Dialog README).
- Disabled shows `fill` with `text-disabled`; it does not disappear.
- Confirm a destructive action in a centered dialog, never in a sheet.

## Navigation model

Choose the container by what the user is doing.

| The user wants to | Use | Example |
|---|---|---|
| Go to another destination | the TabBar or SidebarNav link | Home to Study |
| Go deeper into one item, with a way back | a pushed page with a BackLink | Subject to lesson |
| Pick or filter without leaving (phone) | a Sheet | Sort by |
| Pick or filter without leaving (wide) | a Popover, or a Drawer for a long list | Sort menu; lesson list |
| Answer one question before going on | a Dialog | Discard this mock? |
| Focus on one task with no distractions | a full-screen route in focus mode | Quiz, mock, assessment |

- On a route change, move focus to the new page's `h1` and announce the page title. Restore the scroll position when going back.
- Keep the tab or sidebar selection on the destination, not on the pushed page.

## Page header and back link
- Back link above the title (6px gap), then the title, then an optional lead line, then 28px (`layout-section-gap`) to the content.
- Back link variant A: a rounded highlight (radius 11) that reaches 14px into the margin; the arrow sits 6px left of the page edge so the title stays aligned.
- Root pages (Home): a date line above the title (`web-sub`), and a right-hand slot for the WeekStrip on the same row. It wraps on narrow screens.
- Home columns (D184): the Today's Plan card and the Accuracy card start on one line. Accuracy's header (`.sec-head`: title and "See All Subjects") sits inside its card (`.card--pad`), not above it, with no side padding of its own. This is for the first card of a column only; a section that holds several cards or rows keeps its eyebrow header above (SectionHeader README). Home cards share one 20px inset, including the call-to-action card (D183).
- The WeekStrip has no legend (D186). A day's status shows in a tooltip on hover or focus; on touch the full and half dots and the day name carry it.
- Settings detail pane: a line icon, `web-h2` and one line (`page-head--pane`).
- Results pages: Done sits top right, level with the title. "See all questions →" sits inside the score card under the subject rows. The score ring and the subject breakdown are one card with no divider.
- Question screens: the stem is the page `h1`.
- Phone: 44px bar (`.phone-nav`) with the back link at the left and a text action at the right; large title below. Focus mode uses FocusHeader (close left, report right, no title).
- Question header (`.page-head--question`): the subject overline at the left; at the right end the mock's "Flag" button with its F hint at every width (`.btn--xs .btn--tertiary`, `aria-pressed`; R3-O04, MK question boards), and in a quiz the flag only on phones under 400px; the stem `h1` below.
- Focus header: Close stays at the left of the content column. In a mock the header sits inside `.qpanel-shift`, so the question list never covers Close or the clock (ruling 5). A page head inside a container that owns its gap has no bottom margin.

## Card footer
- Caption (15px, `text-secondary`) at the left, action at the right, band `surface-inset`, 0.5px rule above.
- The caption is a fact ("About 15 min"). Fine print about the action goes under the button, not in the caption.

## Notices
- One per screen. Never stack two. When several apply, show the highest: a connection or saving status first, then something that needs a decision, then a tip.
- Header (icon, title, close), body text on its own line, actions right-aligned, secondary then main. "Later" or a dismiss for good.
- Tones: default (info, teal icon), success (teal check), warning (orange icon). Red is never a notice tone. Data loss uses a neutral notice with an icon; a destructive confirmation is a Dialog.
- Phone: buttons expand to the 44px pair under the text.
- Use a notice for something that needs a decision or stays true for a while. Use a Toast for a result.
- Toasts sit above whatever floats at the bottom: 104 above a TabBar or the focus-mode bar, 92 above the phone quiz bar (`--toast-offset`, set by the shell). At large text a toast may cover page content for its 8 seconds (an Undo toast over an EmptyState action, usage gap 5); the page does not reserve room for it, and it never covers the bar it sits above.

## Confirm or undo
- Undo (a Toast with Undo, 8s) when the action is easy to reverse and loses little: removing a bookmark, hiding a topic, clearing a filter.
- Confirm (a Dialog) when the action loses work or cannot be reversed: discard a mock, delete account data, reset progress. Name the consequence: "This cannot be undone."
- Never both for one action. Never auto-dismiss the only recovery route.

## Dialogs, drawers and sheets
- One modal contract (Dialog README): labelled, initial focus on the safe action of a destructive confirm or on the first field, focus trapped, page inert, Esc and a visible Close, focus returns to the trigger, the scrim fixed to the viewport with page scroll locked, a maximum height with a scrolling body and actions always visible, safe-area and keyboard insets respected.
- Dialog: title, one or two sentences, at most two buttons. Do not close a destructive dialog on a scrim click.
- Drawer: 440px from the right, `bg-page`, header (title, close), scrolling body, footer with the action at the bottom right. For lists and side tasks that keep the page in view. Below 1134px the quiz explanation opens as a modal Drawer with its own footer (the counter and Next), and the floating bar's main action hides (R3-O03). It and the mock question list below 1024 follow the modal contract with a real scrim element (ruling 8, README Focus mode).
- Large text: a dialog or sheet pair that no longer fits wraps with the main action on top on the phone, secondary then main on wide screens (R3-A12).
- Sheet (phone): from the bottom, grabber, title, body, actions. Drag down closes; Cancel or Close is the keyboard alternative. Confirm destructive actions in a dialog, not in a sheet or a drawer.

## Loading
Pick by how long and how much.

| Situation | Use |
|---|---|
| A page or block whose layout is known, first load | Skeleton (appears after 300ms, so fast loads show nothing) |
| A short wait inside a control | the busy Button (spinner and verb, then a check and the result) |
| A wait with no layout to sketch (connecting, restoring) | Spinner with a label, centered |
| A change the server will almost surely accept (flag, bookmark) | optimistic update: show it at once, roll back with a Toast if it fails |
| Refreshing content already shown | keep the content, show a small status line; never blank the page |

## Offline, saving and sync
Philippine mobile connections drop often, so every screen has these states. Status messages are neutral or orange, never red.

| State | What the learner sees | Actions |
|---|---|---|
| Initial load | Skeleton | none |
| Refresh with content kept | content stays; a small "Updating" line | none |
| Empty | EmptyState | the next step |
| Offline, cached | the cached content and a neutral Notice: "You are offline. Lessons you opened before still work." (copy follows the confirmed offline scope) | none |
| Offline, not cached | ErrorState: "This needs a connection." | Try Again |
| Saving locally | answers save on the device at once; the bar or header says "Saved on this device" | none |
| Syncing | "Syncing your answers" status line | none |
| Saved | the status line clears; no toast for routine saves | none |
| Failed to sync | an orange status line: "Not synced yet. We will try again." | Try Now |
| Signed out (session expired) | a Dialog: "Sign in again to keep syncing." Answers stay on the device. | Sign In |

- Proposed offline scope (Decision D96, Aedwon confirms): opened lessons, quizzes on cached questions, and the mock exam once started. A mock's timer and queued answers survive a dropped connection and an app restart.
- Never claim "Submitted" or "Saved" before the server confirms. Say "Saved on this device" until then.

## Pro gating
- A locked feature stays visible and says why it is locked and what opens it: the row shows the Pro mark and a chevron; the tap opens the paywall with that feature named.
- Never silently disable a Pro control. Never hide that something exists.
- A Free limit names the real limit the app enforces, taken from the pricing source (`docs/pricing.md`). No invented scarcity and no invented numbers.
- Fine print under the paywall button follows the fine-print rule below.

## Onboarding and multi-step setup
- One question per step: exam, exam date, study days, account. A progress bar shows the step ("Step 2 of 4").
- Back keeps what was entered. Skip is a ghost button where a step is optional; the main action stays at the bottom right (wide) or full width (phone).
- Leaving and coming back resumes at the same step.
- The exam date offers typed entry and a picker (DatePicker).
- Compact pills (D189): the onboarding "Retry" action is `btn--pill-sm`, a Button size (Button README). The board "Allow" is an Android system prompt and "Replay" a board playback control; neither is an app control, so neither has a class (D190). Study days and exam filters are toggles, not buttons.

## Keyboard shortcuts (wide)
| Key | Action | Where |
|---|---|---|
| Enter | the main action (Check, Next, Continue) | quiz, mock, dialogs |
| The item's option letters (A to D, A to E where an exam has five) | pick an answer | quiz, mock: focus inside the question region |
| F | flag the question | mock, quiz: focus inside the question region |
| Esc | close the overlay, or leave focus mode with a confirm | everywhere |
| Ctrl K (Cmd K) | open search | shell |
| Arrow keys | move within a group (options, segments, tabs, menu items) | everywhere |

- Single-letter keys (option letters, F) act only while focus is inside the question region (the stem, the options and the floating bar), never page-wide, and only while Settings > Accessibility > Keyboard Shortcuts is on (default on). This meets WCAG 2.1.4 (R2-O12, ruling 1). Modifier shortcuts (Ctrl K) and Esc and Enter are unaffected.
- Shortcuts never fire while focus is in a text field, except Esc and Enter.
- Key hints appear only after the first hardware key press, and only with a fine pointer.

## Search
- Search is an overlay, not a page (ruling 9, SD_Search): the sidebar search field or Ctrl K opens the SearchOverlay over a light scrim. Empty query: "Recently opened". Typing: results grouped by type (lessons, topics, questions), each group capped with a "See all" text link, the matched text marked. Arrow keys move the active result, Enter opens it, Esc closes and returns focus. Phone: a full-screen sheet from the Study tab.
- No results: a bare EmptyState inside the panel (no card), a broader-word suggestion and "Browse All Subjects" (tonal).
- Show the query in the results heading. No results: say so and suggest a broader word. Results update as the user types after a short pause.

## Empty and error states
- Centered column: icon (40px, neutral), title, one short line, at most one centered action.
- Empty: say what appears here and how it gets there. Action is tonal ("Browse Questions").
- Error: say what happened and what to do. Action is "Try Again" (tonal), which turns busy ("Trying") while it retries. Neutral icon, never red.

## Settings
Groups in this order: Your exam, Account, Appearance, Accessibility, Pro, About. Rows follow ListRow and GroupedList; a setting that applies at once is a Switch.
- Appearance: Theme (Light, Dark, System; System follows the OS live and is the default).
- Accessibility (wide screens only): "Keyboard Shortcuts", a Switch, on by default, subtitle "Letter keys pick and flag answers in a quiz." Off turns off every single-letter shortcut (ruling 1).
- Lesson text size: the reader scale slider (1.0 to 2.0); it also sizes quiz stems, options, explanations and passages.

## Passages
- A question with a passage uses the passage-question layout in focus mode: from 1134px the Passage on the left and the question on the right, each scrolling on its own; below it and on the phone the passage collapses to four lines above the stem with "Show Passage" (a Drawer wide, a Sheet on the phone).
- On reveal the explanation replaces the passage column; "Show Passage" at the right end of the explanation head brings it back in a Drawer (wide) or Sheet (phone), so the line the explanation cites can be checked (R3-O08). On the phone the collapsed passage expands in place ("Show Full Passage"); passages over about 300 words keep the Sheet. Questions that share a passage keep its scroll position.

## Data display
- Accuracy: the number is always printed; the bar or ring only supports it. Use the five `chart-*` steps. Zero ("0%") and no data ("No data", track only) look different.
- Show the sample size when it is small: "61% of 18 questions".
- Results and history tables use DataTable: a heading row, numbers right-aligned in tabular figures, one decimal only where the source has one (61.2%), sortable columns announce their sort order (`aria-sort`), and the table scrolls sideways inside its card on narrow screens with the first column kept.
- Charts use Chart: past results and trends are one teal series; other series differ by label, line style or marker shape, never by hue alone. Accuracy by subject or topic uses the five `chart-*` steps in AccuracyBar and StatRow, never in Chart. Every chart has a one-line text summary and a table equivalent for screen readers. Labels stay 12px or larger at every width. The plot never scrolls sideways: when it is narrower than its columns it shows the most recent points that fit and says "Showing the last N weeks"; the table equivalent holds the full series (ruling 7). The past-results chart runs the full content width.
- Data values are set as `style="--value:N"` on the bar, ring, gauge or chart column; the other inline properties are the data and state ones the README lists, never styling.
- A subject row that opens its page is a StatRow link (`.stat-row--link`, ruling 8): the whole row, a chevron, the hover well.

## Secondary navigation
- A teal text link with an arrow that nudges 4px on hover: "See all questions →". Never a box, tint or border.
- Place it inside the card it extends, under the rows, or at the right end of a section header. An action on the section itself (Custom Quiz "Select All") is a small teal tertiary Button (`.btn--tertiary.btn--accent.btn--sm`) in the same slot, never a link.

## Fine print
- Fine print belongs to its button: directly under it, right-aligned, `web-small`, `text-secondary`. Example under the CTA: "Free for 7 days, then ₱99 a month. Cancel any time." "Restore Purchases" sits on the left of that row.
- Phone and tablet: centered under the button, 13px. Use `.fine-print` in a `.cta-block`; the class aligns itself by tier.
- Paywall: a promo card (wide, `.card--promo`) or the teal hero (phone, `.card--hero`), then the plans as plan tiles (`.choice-tile--plan`), then the CTA with its fine print, Restore Purchases at the left (wide) or under it (phone, `.btn--text-phone-sm`). Weekly and Yearly CTA copy is not designed yet (HANDOFF).

## Forms and validation
- Label above the field (13/600), field 48px, help text 13px below. Labels use `<label for>`; help and error lines are tied with `aria-describedby`.
- Validate on blur or on submit. Never on each key. Set `aria-invalid="true"` only after validation.
- An error shows a 2px `danger` ring, an icon and a sentence that names the fix: "Enter a full email address." The field keeps its `surface-card` fill. On submit, the first error gets `role="alert"` and focus moves to it.
- The primary button stays enabled; submitting with an error moves focus to the first error. A button that depends on a choice (Check) is disabled until the choice exists.
- Required fields are the default. Mark the optional ones "(optional)". Set `autocomplete`, `type` and `inputmode` on every field.
- Choosing several of more than eight items in groups (Custom Quiz topics by subject): grouped checkboxes (`.choice-tree`, ruling 5), a parent per group with a mixed state and an optional Select All row; tiles (SelectableTile) are for two to eight choices.
- Use Radio for up to five options and Select above five. Use a Switch for a setting that applies at once; checkboxes and radios apply on submit.
- Controls are native inputs (ruling 6): `input type=checkbox` (Checkbox), `input type=radio` in a `fieldset.choice-group` (Radio), `input type=checkbox role=switch` (Switch), a native `select` (Select). A plain `<form>` submits them with no script. The onboarding listbox is the one custom select; it keeps a hidden input.
- A date field offers typed entry and the picker: the calendar button sits in the Field's trailing action slot (`.field__action`).
- Wide screens: fields keep a natural width (up to about 420px), left-aligned, with the action at the right end of the form. Phone: fields and the main action fill the width.
