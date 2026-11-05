# P4: CET exam tags

November 5, 2026. Policy read from origin/main 0d24f62b8. Aedwon approved "proceed just before the astra audit" (post-beta priorities log, November 4) and, on November 5, "proceed with your next steps. you can use the codex accounts where needed."

## Source

- Audit Level 1 tags: `docs/content/audit/coverage-r1/lesson-exam-tags.json` at ecbfa88b (the "Pantas Audited Corpus r1" tab data), 158 lessons. Level 3 notes (`lesson-exam-tag-recommendations.json`) are used only to resolve files the audit did not tag.
- Exam ids: audit `dcat` is `dlsucet` in question files. Only `upcat`, `acet`, `dlsucet`, `ustet` change. `cse-pro`, `cse-sub`, `dost-sei`, `pupcet` stay as they are.
- Membership: `meta.exams` in each question file decides which exams show a lesson.

## Change list

`tag-changes.json`: 86 question files, each with before, after, added, removed and reason.

| Exam | Added | Removed | Lessons before | Lessons after |
|---|---|---|---|---|
| UPCAT | 9 | 14 | 136 | 131 |
| ACET | 14 | 20 | 86 | 80 |
| DCAT (`dlsucet`) | 11 | 57 | 136 | 90 |
| USTET | 4 | 39 | 145 | 110 |

Counts are over all 178 question files (one per lesson).

Added among audit lessons matches the spec's B1 counts (ACET 13, USTET 4, UPCAT 9, DCAT 11). Removed among audit lessons is higher than B1 (ACET 19, USTET 38, UPCAT 15, DCAT 54, against 12, 28, 5, 44). Most of the extra are lessons the audit tags for no CET at all, such as the four calculus lessons and inverse trigonometric functions (DOST-SEI only). B1 likely left those out. Applying the audit's tags removes them too, so this pass does.

## Files the audit did not tag

- `angles-and-radian-measure`: keep UPCAT, because unit-circle keeps UPCAT and uses radians (Level 3 foundation note). Remove ACET, USTET and DCAT, which unit-circle also leaves. Aedwon, November 5: "radian measure is used in upcat. keep it."
- `quantum-numbers-electron-configuration`: remove UPCAT, USTET and DCAT. The audit gives it no CET tag, Level 3 names DOST-SEI only, and no CET map names it. Atomic structure stays in UPCAT and USTET.
- `filipino-verb-aspect-and-focus`: keep UPCAT (UPCAT map: Language Proficiency is English and Filipino, official). Remove ACET (map: no separate Filipino section, weak report), USTET and DCAT (maps name no Filipino). CSE tags stay.
- Split lessons take the parent's audit CET tags: human-body-control and meiosis lose DCAT; cellular-respiration gains ACET. The other five splits already match.

## Checks before accepting (spec B6)

- Roadmap: no lesson in any CET has a required prerequisite outside that CET, before or after. Helpful links that point outside the exam: before 1 per exam; after UPCAT 0, ACET 4, DCAT 6, USTET 6. The roadmap skips prerequisites outside the exam's topics, so these lose only an ordering hint. P6 reviews them.
- Mock pools, simulated on the content export:
  - UPCAT: the Mathematics section's precalculus topic falls from 80 questions to 0, because the audit drops UPCAT from all four calculus lessons (the UPCAT map is Grade 7 to 10 curriculum). The sampler skips an empty topic, so the paper would come up 11 items short. Fix: remove that topic from `content/mock/upcat.yaml` and split Mathematics evenly over the other five (0.2 each). The source note already says the even split is chosen here, not published. Every other UPCAT topic keeps at least 40 questions, and at least 8 times what it needs except language application (40 for 27).
  - ACET: the blueprint is not on this branch (only on `web/staging-candidate-r1`). Against it, verbal logic has 0 questions now and 20 after (needs 45); data interpretation goes from 0 to 40 (needs 10); vocabulary falls from 120 to 20 (needs 15) and text types from 100 to 40 (needs 15). Recorded for P7; no change here.
  - CSE: no CSE tag changes, so the CSE pools do not change.
  - DCAT and USTET have no blueprint.

## Steps

1. A Sonnet subagent applies `tag-changes.json` with a script: replace each file's `meta.exams` list with `after`, keeping that file's list style (inline or block, quote style). No other line changes. It also makes the UPCAT blueprint change above.
2. Lead checks: re-run the comparison (zero differences from the audit list plus the six resolved files), `git diff` touches only `meta.exams` lines and `upcat.yaml`, the import check and the content export pass, and the pool check shows no short UPCAT topic.
3. Record in `STATUS.md` and the final report. Push to `content/cet-rewrite-r1`.

## SSOT tab update

November 5, 2026: the "Pantas Audited Corpus r1" tab now lists the 20 lessons added after the audit, under their topics and marked "Added after the audit", with their current app tags (split lessons name their parent). Angles and Radian Measure now shows its app tags (PUPCET, UPCAT) and Aedwon's UPCAT ruling. An update note follows the tab's introduction. Audit lines were not otherwise changed.
