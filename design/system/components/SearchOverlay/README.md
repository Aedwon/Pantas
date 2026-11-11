SearchOverlay is the search panel over the page: the field, results grouped by type with the matched text marked, and a key-hint footer.

## When to use
- Use it for search everywhere (ruling 9): from the SidebarNav search field, Ctrl K (Cmd K), or the Study search button on the phone.
- Don't build a search results page. Don't use Popover for results (it is sized for menus).

## Anatomy
- `.search-overlay`: fixed, `z-overlay`, the lighter `scrim-search` (ink at 22%, as SD_Search draws it), the panel 110px from the top (`layout-search-top`).
- `.search-panel`: 640 wide (`layout-search`), `surface-modal`, radius 18 (`radius-xl`), `elev-modal`, a maximum height with a scrolling results area.
- Field `.search-panel__field`: 60 high (`size-search-field`), padding 0 18, the search glyph in `icon-muted`, the query in `web-search-input` (19/400), an Esc KeyHint at the right; a hairline under it and a 2px `accent` line while it has focus.
- Results `.search-panel__results`: padding 10 8 8. Groups `.search-group` with `.search-group__label` (`web-eyebrow`). Result `.search-result`: padding 10 12, radius 12, title `web-title-sm`, subject `web-row-sub` `text-secondary`, an optional snippet, an optional value (`web-row-value`), and an Enter KeyHint on the active result.
- Match: native `mark` (`accent-tint-text` on `accent-tint`, 4.5:1), around the matched letters only.
- Footer `.search-panel__foot`: `surface-inset`, hairline above, `web-small` "Up and Down to move, Enter to open, Esc to close".

## Variants and props
- Empty query: one group "Recently Opened". Typing: groups by type (Lessons, Topics, Questions), each capped, with "See all" as the last result of a capped group.
- No results: a bare EmptyState inside the panel (no card), a broader-word suggestion and "Browse All Subjects" (tonal), usage gap 21.
- `.search-overlay--contained` keeps it inside a frame (previews). `.is-exiting` plays the exit.
- Phone (under 600): a full-screen sheet with the field at the top, a Cancel text button at the right end of the field (`.search-panel__cancel`, shown only under 600) in place of the Esc hint, and no key footer.
- The consumer provides the results, the query, the matched ranges and the open handler.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="search-panel" role="dialog" aria-modal="true" aria-label="Search">
  <div class="search-panel__field">
    <svg aria-hidden="true">...</svg>
    <input type="search" role="combobox" aria-expanded="true" aria-controls="sl-" aria-activedescendant="sr--0" aria-label="Search lessons and topics" placeholder="Search lessons and topics" value="stoich">
    <span class="kbd">Esc</span>
    <button type="button" class="btn btn--tertiary btn--accent btn--sm search-panel__cancel">Cancel</button>
  </div>
  <div class="search-panel__results">
    <div role="listbox" id="sl-" aria-label="Results">
      <div class="search-group" role="group" aria-labelledby="sg--0">
        <h2 class="search-group__label" id="sg--0">3 Lessons</h2>
        <a class="search-result" href="#" role="option" id="sr--0" aria-selected="true">
          <span class="search-result__t">
            <span class="search-result__title">
              <mark>Stoich</mark>
              iometry
            </span>
            <span class="search-result__sub">Chemistry</span>
          </span>
          <span class="search-result__v">13 min</span>
          <span class="kbd">Enter</span>
        </a>
        <!-- 1 more -->
        <a class="search-result" href="#" role="option" id="sr--2" aria-selected="false">
          <span class="search-result__t">
            <span class="search-result__title">Balancing equations</span>
            <span class="search-result__sub">Chemistry</span>
            <span class="search-result__snippet">
              ...why
              <mark>stoich</mark>
              iometry starts with a balanced equation...
            </span>
          </span>
          <span class="search-result__v">9 min</span>
          <span class="kbd">Enter</span>
        </a>
      </div>
    </div>
  </div>
  <div class="search-panel__foot" aria-hidden="true">Up and Down to move, Enter to open, Esc to close</div>
</div>
```

## States
- Result: rest, hover (the dialog hover well), active (`aria-selected="true"`, the same well plus the Enter hint), keyboard focus (2px `accent` ring inside). Loading: a Spinner row with "Searching". Offline: a Notice inside the panel.

## Keyboard
- Focus stays in the field. Up and Down move the active result across groups (wrapping), Enter opens it, Esc closes the overlay and returns focus to the trigger. Tab moves to the results list and back.

## Accessibility
- The panel is `role="dialog"` with `aria-modal` and a name. The field is `role="combobox"` with `aria-expanded`, `aria-controls` and `aria-activedescendant`; the results are `role="listbox"` with `role="option"` items in named groups.
- Announce the count after a pause ("3 lessons, 2 topics") in a `role="status"` region. The match is not color only: it is also shown by the result order and the subject line.

## Motion
- The scrim fades in over `dur-flip`; the panel rises like a Dialog (`dur-medium-3`, `motion-house`); on the phone it rises as a Sheet. Reduced motion: both fade in place.

## Flutter
- A `showGeneralDialog` route with `barrierColor` `scrim-search`, a `TextField` and a `ListView` of grouped results; on phones a full-screen modal route. Highlight with `TextSpan` (`accent-tint-text` on `accent-tint`).
- Reads `scrim-search`, `surface-modal`, `surface-modal-hover`, `surface-inset`, `divider`, `accent`, `accent-tint`, `accent-tint-text`, `text-primary`, `text-secondary`, `icon-muted`, `elev-modal`, `radius-xl`, `radius-md`, `web-search-input`, `web-title-sm`, `web-row-sub`, `web-row-value`, `web-eyebrow`, `web-small`, `layout-search`, `layout-search-top`, `size-search-field`.

## Do
- Keep focus in the field and move the active result with the arrows.
- Mark only the matched letters.

## Don't
- Don't navigate to a results page. Don't close the overlay while the learner is typing.

## Placement
Centered over the page, 110px from the top, on every wide screen; full screen on the phone.

## Tokens used
`border-focus`, `accent`, `accent-tint-text`, `motion-move`, `danger-text`, `size-chart-h`, `z-overlay`, `layout-search-top`, `space-16`, `scrim-search`, `dur-flip`, `surface-modal-hover`, `z-modal`, `layout-search`, `radius-xl`, `surface-modal`, `text-primary`, `elev-modal`, `dur-medium-3`, `motion-house`, `space-12`, `size-search-field`, `space-18`, `border-hairline`, `divider`, `icon-muted`, `dur-short-2`, `motion-fade`, `type-web-search-input`, `tracking-web-search-input`, `text-secondary`, `space-10`, `space-8`, `space-6`, `type-web-eyebrow`, `tracking-web-eyebrow`, `radius-md`, `surface-hover`, `space-2`, `type-web-title-sm`, `tracking-web-title-sm`, `type-web-row-sub`, `tracking-web-row-sub`, `type-web-row-value`, `tracking-web-row-value`, `surface-inset`, `type-web-small`, `tracking-web-small`, `space-40`, `space-24`, `scrim`, `radius-lg`, `dur-long-1`, `motion-slide`, `type-phone-body`, `tracking-phone-body`

## Status
Draft (new in 3.1, ruling 9). Source: SD_Search, SD_SearchRecent (scrim .22, 640 panel, 60 field, 19px query, Esc hint, grouped results, mark highlight, key footer). Snaps in D127.
