# Level 3 carry-forward items

Notes accepted at the level 2 gate (reviews 1 to 5, `gates/`) that the named level 3 plan must
settle. Each level 3 plan cites the items it closes.

| Item | Level 3 plan | What to settle |
|---|---|---|
| N3-7 | L3-W0 | Exam catalog storage form (columns or `catalogJson`) and reader API name, before any consumer reads it. |
| N3-9 / N4-5 | L3-W0 | `MistakeTag` fallback for unknown values (older builds syncing `other`). |
| N5-2 | L3-W0, L3-W4e | Who decodes old mock results with the new JSON fields empty (W4e's decoder; W0 declarations default to null). |
| N3-8 | L3-W3 | How stored pass end dates update when a catalog date moves later. |
| N-19 | L3-W3 | Google Play replacement mode per subscription pair, checked against current Play Billing docs. |
| N-23 | L3-W3 | Injecting the active exam so `proIsActive` equals `coversExam(activeExam)`; both definitions. |
| F-23 | L3-W1 | README value ranges (page title, caption, floating radius) checked against the boards using them. |
| N4-6 | L3-W2 | Name the remaining Ink-era files in the close-out task (`exam_date_sheet.dart`, `topic_scope_index.dart`, `settings_value_row.dart`, others found). |
| N5-1 | L3-W4c, L3-W4b | Topic list expand icons and the bookmarks drag handle use W1 getters (`sort`/caret, `reorder`). |
| N3-6 | none (recorded gap) | `docs/design/index.html` gallery is not regenerated; `SCREENS.md` is the registry for the v2 boards. |
