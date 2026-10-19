# W4c engineering audit 1

Completed October19 by independent GPT-6 Astra, continuing the same audit interrupted by usage
limits. Candidate f495a8dda858ff13305abb5715e3d667406b4277; full-family base
ffc8045bc7eb2d427c82931f7bc1c43263e5223f. Policy at review5b77018a. No source/index/HEAD
mutations. No second family audit was dispatched. Lead inspected actual source and repro log.

## Verdict

Not ready to integrate. No Critical finding established. Six auditor Important findings and
one auditor Minor follow. Root accepts all six and regrades the origin finding Important
because it violates the explicit truthful-return contract and misleads screen-reader users.
All seven enter one bounded fix pass. No cosmetic expansion or blanket review loop.

## Findings and lead disposition

1. Important: bookmarks_sheet.dart290, Move saves custom ids before sort. A failed second save
   followed by Retry recomputes numeric indices against already changed rows. Actual
   [l3,l2,l1]→[l2,l3,l1]→Retry→[l3,l2,l1]. Retain immutable intended result or use the existing
   transaction for the compound change. No new generic mutation framework.
2. Important: bookmarks_sheet.dart218, Remove commits before isRemovalCurrent. If that extra
   read throws, Retry removes already removed ids and replaces real Undo rows with empty rows.
   Actual Remove/failure/Retry/Undo leaves l3 absent. Retain the committed removal result and
   retry only remaining validation/publication, with original token/view expiry.
3. Important: study_map_providers.dart111, cached lastOpenedLessonProvider and recent lessons
   do not refresh after guarded onOpen writes. Actual storage l1, cached last=null/recent=[].
   Refresh both only after successful current-owner opening, including in-place advances.
4. Important: reader_providers.dart113, only scroll checks the15second floor. A stationary
   short lesson receives its sole check immediately and remains unread after16real seconds.
   Schedule the existing floor recheck with last actual end metrics and owner cancellation.
5. Important: reader_providers.dart119, _hasMarked is true before persistence succeeds and the
   unawaited mark future has no error handler. One transient failure escapes and suppresses
   later retry permanently. Separate pending/succeeded state and handle current-owner failure.
   Also test actual unhandled onOpen/bookmark futures at lesson_page.dart848.
6. Important: study_topic_section.dart44/187 and bookmarks_section.dart82 always wrap list
   titles, including normal text size, contrary to approved normal single-line ellipsis.
   Use shared row behavior and complete semantic labels; retain meaningful200% nonoverflow.
7. Important (lead regrade from Minor): bookmarks_section.dart98 preview pushes from=bookmarks
   without opening the sheet. It actually returns to Study. Preview must use Study origin;
   sheet entries keep Bookmarks origin. This is a truthful navigation/accessibility contract.

## Evidence

Existing candidate gates were independently inspected, not needlessly repeated:
4193full passes; clean analysis; format1459/0; layering/attribution clean.
Five additional real reproductions failed0pass/5fail against unchanged candidate.
Log /tmp/pantas_w4c_audit_repros.log SHA256
65688e14f6dfbeb60cb997095d6e780462a0df503b1e448abc603718f706db05, verified by root.
Fixtures: /tmp/pantas_w4c_compound_audit_test.dart, /tmp/pantas_w4c_recent_audit_test.dart,
/tmp/pantas_w4c_mark_audit_test.dart. Root read actual five failures and relevant production
source. Worker must retain meaningful cases in normal project tests before fixes, not copy
the entire external fixture blindly. Presentation/origin findings are source/board-derived.

## Strengths retained

Single active reader owner; provenance rejection; guarded transactions across reset/account/
exam; passive noninteractive/nonsemantic preview; fixed chrome/equal displacement; shared
defaults preserved and retired paths removed. Do not regress these during the fix pass.

## Declined to judge and lead rulings

- Phone visual acceptance: remains Aedwon's, not waived. No screenshots/computer control.
- Accepted BM neighbor curve and exact Contents fade: explicit user exceptions, no finding.
- Live PWA/server integration: separate staging handoff, not present in candidate; billing
  blocks live checks. Preserve current repository/fetchHook contract without local duplicates.
- Background/covered-time accounting: audit did not establish a failure. Root retains the
  approved15second wall-time floor from actual body activation, without inventing a new
  accumulated-foreground-time metric. New automatic marking must only execute for the current
  visible active body at its real end. While a route, Contents or app lifecycle covers it,
  suppress marking and re-evaluate on actual visibility/resume. Expired owners never restart.
  This guards the new automatic check; it does not redefine the existing floor or add analytics.

## Completion path

Same Sol implementor fixes these seven, observing meaningful RED→GREEN and affected checks.
One full final serial suite plus required static checks after the completed fix pass. Root
personally reviews data fixes and exact evidence, then uploads/integrates only if clean.
No repeat whole-family audit is required merely to confirm covering tests; unresolved or new
material issues still block acceptance. Post7223source stays local until this sequence passes.
