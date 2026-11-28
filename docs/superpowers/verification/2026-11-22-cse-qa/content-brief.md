# Content audit brief: checklist rows C3 and C4 (read only, local only)

Startup: Work on Aedwon/Pantas. Policy files AGENTS.md, WORKFLOW.md, SUBAGENTS.md from origin/main
(`git show origin/main:<file>`); policy commit ecfeaf0d1 or later. Edit no tracked file. No network
calls, no Firebase, no Flutter builds. Append findings to build/audit/content-findings.md as found.

Prod content root (what prod serves today): build/audit/prodtree/content (git tree d97de9415,
content/cet-bite-r1). Prod also took three files from main: content/mock/acet.yaml,
content/exams/custom_subject_tiers.json, content/illustrations/sources/pantas.yaml (see the Nov 20
"CET release shipped to prod" entry in docs/superpowers/decisions/2026-10-19-pwa-launch-log.md).

C3. "The content audit sweep runs clean on the content prod serves." Known: tools/audit/run_all.py stops
with 182 illustration-marker errors on the prod content root and crashes on an index error (search
docs/ for "C9" and "C10" in the beta lists and launch log). Do: run `python3 -I tools/audit/run_all.py`
against the prod content root (read its usage first; copy nothing into tracked paths; if it needs a
root argument or env var, use it; if it must run from a content tree, run it from a scratch copy under
build/audit/). Record the exact crash and its cause. For the 182 marker errors: classify each (by
script) and answer the real question: does any of them reach a student on a CSE screen (cse-pro or
cse-sub lessons, questions or figures)? Trace how an illustration marker is rendered in the app
(lib/ lesson reader and figure code) and what the student sees for a bad marker (blank, raw text,
error, crash). List each CSE-reachable one with path, line and what the student sees.

C4. "No unapproved question is served to the public." Known: "968 unapproved questions were still
exported until their subject is split". Do: for every question in the prod root that is tagged cse-pro
or cse-sub, determine its approval state the way the content tools define it (read
tool/checks/content_approval_check.dart, tools/build_content_export, tools/upload_content, the bite-sized
spec docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md approval sections). Then determine
whether the export/upload that produced prod serves unapproved items (read the exporter and uploader
gates). Report: count of CSE-tagged questions, count approved, count unapproved, whether unapproved
ones are exported and served, per subject. Write the unapproved id list to build/audit/c4-unapproved-cse.txt.

Format per finding: ### title / Severity (blocker, major, minor) / Evidence (file:line, ids) /
What the student sees / Fix idea. End with a summary and the line STAGE-DONE.
