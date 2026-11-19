# Environment Management env-a verification

Command run from the code worktree against bite-sized-content-b/content:

`dart run tool/content/lesson_checks.dart --root /Users/aedwon/.t3/worktrees/Pantas/bite-sized-content-b/content`

```text
lesson_checks exit: 1
Assigned size/coverage findings: 0
Assigned pool findings: 18
Original bodies unchanged: 3/3
Source paragraphs preserved: 3/3
```

Pool findings remain because retagging and approval are separate jobs. Full-root output also names other assigned jobs and the two environmental lessons excluded from this job.

Teaching-word counts:

```text
solid-waste-law: 246
clean-air-law: 319
clean-water-law: 326
climate-policy-law: 216
disaster-risk-law: 255
project-review-and-clearance: 301
critical-area-review: 261
wildlife-and-protected-area-laws: 274
environmental-agencies: 153
disaster-risk-and-readiness: 450
disaster-response-and-recovery: 293
choosing-a-disaster-management-area: 168
source-segregation-and-waste-types: 395
reuse-and-recycling: 379
reduction-composting-and-diversion: 211
```

`grep -rl` for the em dash printed nothing (exit 1).

The full audit ran through its sweeps and wrote 12,499 lines, then its summary crashed with IndexError on a line without tab-separated fields. Its structure rules still expect estimatedMinutes and the old frontmatter. A focused AI-tell comparison found caps=130 in the three source bodies and caps=130 in the active parts; emdash, notjust, stock, and testmakers are all 0 in both.

Question files and ledgers were not edited. The NDRRMC teaching gap is recorded in the split plan. No files were staged or committed.
