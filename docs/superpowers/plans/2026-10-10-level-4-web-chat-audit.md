# Level 4 Web Chat Audit Implementation Plan

> **For agentic workers:** follow `WORKFLOW.md` and `SUBAGENTS.md` from main. The
> lead executes this plan inline; tasks are tightly coupled through one shared
> library. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Run Level 4 (lesson standards and illustration review, 158 lessons)
through dispatcher-started ChatGPT web chats, with two independent reads per
lesson, script-enforced guardrails, and a local monitor page.

**Architecture:** Small Python scripts under
`docs/content/audit/coverage-r1/level4/` share one library. A local queue
process registers dispatcher assignments, reads worker state, and serves the
page. Chats read packets from GitHub and hand in through the relay to one
validating script. Secret run state (which packets are planted, the defect key,
forms awaiting their pair) lives in `~/.pantas-audit/level4/`, outside the
pushed folder.

**Tech stack:** Python 3.9 standard library only (the relay's `python3` is
3.9.6: no `match`, no `X | Y` types, no third-party packages). `unittest` for
tests. Plain HTML and CSS for the page, taken from mockup version 3.

**Spec:** `docs/superpowers/specs/2026-10-10-level-4-web-chat-audit-design.md`,
revision 2. Policy: main `168e393dc997de4531f4fdd5b683c66025e75d0e`.

## Global constraints

- Findings only. No edit to lessons, questions, illustrations, importer, schema,
  roadmap, app, Google Doc, or the relay and dispatcher code.
- Corpus input is read only: worktree `Pantas-wt-content-qa-r2` at
  `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Every script that reads it checks
  that commit and a clean tree, and exits nonzero otherwise.
- `status.md` line 1 never becomes `STATE: RUNNING`.
- Aedwon confirmed the issue eraser on October 10. Its switch is the
  `eraser_confirmed` key in the local config; the lead sets it `true` at setup,
  and the code default stays `false`.
- Pacing gate (Aedwon, October 10): the queue registers the next lesson only
  after the current one is green. It never skips a lesson and never holds one
  by itself.
- The built page matches `level4/mockups/level4-page-v3.html` 1:1. Text that the
  mockup does not contain needs Aedwon's approval before it ships.
- No em dashes and American spelling in everything a person reads.
- Commit messages explain why and carry no AI attribution.
- Run all tests with:
  `python3 -m unittest discover -s docs/content/audit/coverage-r1/level4/tests -v`

## File map

All under `docs/content/audit/coverage-r1/level4/`.

| File | Responsibility |
|---|---|
| `rules.json` | The rule table: id, severity, kind, short rule text, proof flag |
| `l4lib.py` | Paths, config, corpus guard, lesson parsing, hashing, text normalizing |
| `mechanical.py` | Script-only rule verdicts per lesson |
| `build_packets.py` | Packets for real and planted lessons, plus the local index |
| `form.py` | Answer form shape and `validate` |
| `handin.py` | The one command a chat runs through the relay |
| `compare.py` | Pair comparison, copy flag, deciding items, ruling merge |
| `dispatch.py` | Thin wrapper over the dispatcher CLI and `gh` |
| `runqueue.py` | The run state machine |
| `eraser.py` | Hand-in issue body replacement, gated |
| `server.py` | Local page server and the queue loop |
| `page/index.html` | The page, from mockup version 3 |
| `prompts/reader.md`, `prompts/decider.md` | Assignment text templates |
| `report.py` | Pilot report, findings, counting check, summary |
| `tests/test_*.py` | One test file per module |
| `.gitignore` | Ignores `inbox/` |

Local only, never committed during the run: `~/.pantas-audit/level4/` holding
`config.json`, `index.json` (packet id to lesson, planted flag, order),
`planted/` (edited lesson copies and `key.json`), `forms/`, `queue.json`.

## Interfaces fixed across tasks

```python
# l4lib.py
LEVEL4_DIR, AUDIT_WT, CORPUS_WT, STATE_DIR          # pathlib.Path
CORPUS_COMMIT = "765c5dc0fa5586281047bf4f7b30d09ab3707887"
def load_rules() -> list            # rows of rules.json
def chat_rule_ids() -> list         # kinds "chat" and "source-check", in table order
def check_corpus() -> None          # raises L4Error on wrong commit or dirty tree
def parse_lesson(text) -> dict      # {"frontmatter": dict, "body": str, "headings": [(level, title, line)]}
def sha256_text(text) -> str
def norm(text) -> str               # collapse whitespace, strip
def quote_in(quote, lesson_text) -> bool   # norm(quote) in norm(lesson_text), len(norm(quote)) >= 8
def load_json(path), save_json(path, obj)  # save is atomic (write temp, rename)

# form.py
def validate(form: dict, packet: dict) -> list   # reasons; empty means accepted
# packet dict: {"id", "lesson_sha256", "standards_commit", "lesson_text", "filipino": bool}

# compare.py
def compare(form_a, form_b) -> dict
# {"rules": {id: {"state": "agree_pass"|"agree_fail"|"agree_other"|"disputed", ...}},
#  "items": [deciding items], "copied": bool}
def apply_ruling(comparison, ruling_form) -> dict   # final per-lesson result

# runqueue.py
class Run:  # persisted in queue.json
    def tick(self) -> None      # advance one step; never blocks on a chat
    def view(self) -> dict      # everything the page renders
    def start(self), pause(self), resume(self), hold_current(self, reason), restart_current(self)
```

Form shape (the packet shows the chat this exact template):

```json
{
  "packet": "L4-0417", "role": "A",
  "lesson_sha256": "<64 hex>", "standards_commit": "<40 hex>",
  "rules": {
    "L17": {
      "verdict": "pass | fail | not_applicable | needs_source_check",
      "findings": [{"quote": "<exact lesson text>", "problem": "<one or two sentences>"}],
      "checked": ["<what was checked, one item per line>"],
      "note": "<required for not_applicable>"
    }
  },
  "illustrations": [{
    "status": "missing | insufficient | unneeded_existing",
    "position_quote": "<exact lesson text at the spot>",
    "description": "<one line an artist could draw from>",
    "why": "<how it helps the student>",
    "priority": "high | medium | low",
    "method": "code | library | table_or_formula",
    "kind": "exact_exam_figure | concept"
  }],
  "accuracy_concerns": [{"quote": "<exact lesson text>", "concern": "<what looks wrong>"}]
}
```

Validation rules, each producing one plain reason string:

1. `packet`, `role`, `lesson_sha256`, `standards_commit` match the packet.
2. `rules` has exactly the chat rule ids, no more, no fewer.
3. `verdict` is one of the four values. `needs_source_check` is allowed only on
   L11. L08 to L12 may be `not_applicable` only when the packet is not Filipino.
4. `fail` needs at least one finding. Every finding quote passes `quote_in` and
   has a `problem` of at least 20 characters.
5. `pass` on a rule whose table row has `proof: true` needs at least one
   `checked` item of at least 15 characters.
6. `not_applicable` needs a `note` of at least 15 characters.
7. Every illustration entry has all seven keys with allowed values and a
   `position_quote` that passes `quote_in`. An empty list is allowed.
8. Every accuracy concern quote passes `quote_in`.

## Tasks

### Task 1: Rule table and library

**Files:** `rules.json`, `l4lib.py`, `tests/test_l4lib.py`, `.gitignore`.

- [ ] Write `rules.json` from main's `content-checklist.md` (B01 to B10, L01 to
  L27 with L22a). Kinds: `script` for B06, B08, B09, B10, L13, L16, L20, L22,
  L24; `script-assist` for B07; `record` for B04, B05; `deferred` for L06;
  `source-check` for L11; `chat` for the rest. `proof: true` for every `chat`
  rule with severity Blocker or Major.
- [ ] Tests first: `parse_lesson` on the quadratic equations lesson returns the
  seven frontmatter keys in order and headings including
  `(2, "Core Concept", 10)`; `quote_in` accepts a quote with different line
  wrapping and rejects one changed word and a 5-character quote; `chat_rule_ids`
  contains `L17` and `L11` and excludes `L22` and `L06`; `check_corpus` raises
  when pointed at a temp git repo at another commit.
- [ ] Implement, run the tests, commit.

### Task 2: Mechanical checker

**Files:** `mechanical.py`, `tests/test_mechanical.py`.

- [ ] Checks, each returning findings with line number and text:
  B06 em dash; B07 candidate British forms from a fixed list (reported as
  candidates, kind `script-assist`); B08 `\frac` at top level (not inside
  another fraction's braces), `\(`, `\[`; B09 "marks" as score, "cards"; B10 the
  five banned words; L13 words of four or more capitals not in an allow list of
  acronyms found in the corpus; L16 `##` titles outside the guide's allowed set
  per subject; L20 `###` under Examples and Traps not matching `#N: Title`, and
  a trap without a blockquote line; L22 tables, links, fenced code, horizontal
  rules; L24 frontmatter keys, order, quoting, id pattern, `estimatedMinutes`.
- [ ] Tests first: one small synthetic lesson per rule that fails it, and the
  quadratic equations lesson as a file that must produce no L22 or L24 finding.
- [ ] `python3 mechanical.py --all` writes `mechanical/<lesson-id>.json` for all
  158 lessons and prints counts per rule. Review the counts by hand for a rule
  that fires on most lessons, which signals a wrong check, and fix before commit.
- [ ] Commit.

### Task 3: Answer form validation

**Files:** `form.py`, `tests/test_form.py`.

- [ ] Tests first: a fully valid form returns `[]`; one test per validation
  rule above, each asserting the reason names the rule id or field.
- [ ] Implement `validate` and `blank_form(packet)` (the template with every
  chat rule id and empty values). Commit.

### Task 4: Packets

**Files:** `build_packets.py`, `prompts/reader.md`, `tests/test_build_packets.py`.

- [ ] A packet is one Markdown file `packets/<id>.md` with, in order: the job
  in five lines; the hand-in steps with the exact two relay request bodies; the
  blank form; the chat-judged rule rows from the checklist with the guide
  sections they cite; the Level 3 record for the lesson (goal, skill names,
  verdicts, limitations); the prerequisite lessons in full, each under its id;
  the lesson in full between two marker lines. Ids are `L4-` plus four random
  digits, unique, unrelated to lesson order.
- [ ] `index.json` in the local state directory maps id to lesson id, lesson
  hash, `planted` flag, and run order (topic order, prerequisites first, pilot
  set first). It is not written to the repository.
- [ ] Planted packets are built from `~/.pantas-audit/level4/planted/<lesson-id>.md`
  when present, with a different id and the edited text's own hash.
- [ ] Tests first: packet text contains the lesson verbatim, every chat rule id,
  and both prerequisite texts for `lesson-algebra-types-of-functions`; two builds
  with the same seed give the same ids; no packet file name or body contains
  the word "planted" or a lesson's run order.
- [ ] Build all packets, check 158 real packets exist, commit the packets.

### Task 5: Hand-in command

**Files:** `handin.py`, `tests/test_handin.py`.

- [ ] `python3 docs/content/audit/coverage-r1/level4/handin.py <packet-id> <role>`
  reads `level4/inbox/<packet-id>-<role>.json`. Role is `A`, `B`, or `D`.
- [ ] Order of work: check the id and role are expected by `queue.json`; run
  the unexpected-change check (`git status --porcelain` on the audit folder,
  allowing only `inbox/`, files recorded in `queue.json` as written by the run,
  and nothing in the corpus worktree); validate; on accept move the form to
  `STATE_DIR/forms/` and print `ACCEPTED`; on reject keep a copy under
  `forms/rejected/`, count it, and print `REJECTED` with numbered reasons; on a
  second rejection also print `HELD: stop and report that this form was not accepted`.
  On an unexpected change print `STOPPED` and set the stop flag in `queue.json`.
- [ ] Output never includes verdicts, quotes, or findings.
- [ ] Tests first, each in a temp directory with a temp git repo: accept, reject
  twice then hold, wrong role, unexpected changed file, output contains no quote
  text from the form.
- [ ] Commit.

### Task 6: Comparison and ruling

**Files:** `compare.py`, `prompts/decider.md`, `tests/test_compare.py`.

- [ ] Per rule: both `pass` gives `agree_pass`; both `fail` gives `agree_fail`
  with findings paired when one quote contains the other or they share at least
  half their words, and unpaired findings turned into deciding items; equal
  other verdicts give `agree_other`; anything else is `disputed` and becomes a
  deciding item carrying both positions as A and B in an order chosen by a
  seeded random draw recorded in the result.
- [ ] Illustration entries pair by `position_quote` the same way; unpaired ones
  become deciding items.
- [ ] `copied` is true when `difflib.SequenceMatcher` ratio over the two forms'
  concatenated `problem`, `checked`, and `note` text is at least 0.85.
- [ ] The deciding form has one entry per item: `ruling` (`uphold_a`,
  `uphold_b`, `uphold`, `reject`), a `quote` that passes `quote_in`, and a
  `reason`. `form.validate` gains a branch for role `D`.
- [ ] `apply_ruling` produces the final lesson result: per rule the verdict,
  findings, and source (`both`, `ruled`).
- [ ] Tests first: each state, pairing by containment and by overlap, the copy
  flag on near-identical forms and its absence on independent ones, ruling
  merge, and that A and B labels do not reveal role.
- [ ] Commit.

### Task 7: Dispatcher wrapper and facts check

**Files:** `dispatch.py`, `tests/test_dispatch.py`.

- [ ] Read on the relay repository's `main`: `dispatcher/cli.py` (the `status`
  output), `dispatcher/chatgpt_web.py` (how `requested_model` and
  `requested_effort` are matched), `dispatcher/models.py` (task states and
  blocker codes). Record the exact strings in a comment block at the top of
  `dispatch.py`.
- [ ] `register(assignment: dict) -> str` writes the assignment file and runs
  the dispatcher's `register`; `task_state(task_id) -> dict` parses `status`;
  `supervisor_running() -> bool`; `runners_online() -> int` through
  `gh api repos/Aedwon/chatgpt-terminal-relay/actions/runners`.
- [ ] Assignments use `repository` `Aedwon/Pantas`, `branch`
  `docs/content-coverage-audit-r1`, `base_sha` the packet commit, `worktree`
  null, `runner_required` true, `requested_effort` `High`, `max_continuations`
  2, `replacement_allowed` false, and `requested_model` as found above.
- [ ] If the dispatcher cannot select GPT 6 Sol as it stands, stop and report.
  Do not edit the dispatcher.
- [ ] Tests with a fake subprocess runner: parsing of each status form, and that
  a failed `register` raises with the dispatcher's message.
- [ ] Commit.

### Task 8: Run queue

**Files:** `runqueue.py`, `tests/test_runqueue.py`.

- [ ] States for the run: `ready`, `running`, `paused`, `limit`, `signin`,
  `offline`, `needs_you`, `stopped`, `pilot_done`, `done`. Per lesson:
  `pending`, `reading`, `deciding`, `finished`, `held`.
- [ ] `tick` rules: when running with no lesson in flight, take the next lesson
  and register roles A and B together; when both forms are in, compare; if
  there are deciding items, register role D; when the ruling is in or there
  were no items, write the lesson result into the audit folder, re-read and
  re-validate it (the pacing gate), record the written paths, and only then
  mark it finished; after the last pilot lesson set `pilot_done`; map
  dispatcher blocker codes to `limit` or `signin`; zero runners sets `offline`
  and clears by itself; the stop flag sets `stopped`.
- [ ] Anything that keeps the current lesson from finishing sets `needs_you`
  with a reason: a form rejected twice, a stalled or failed chat, a copied
  pair, an unsettled ruling, or a failed gate. The queue starts nothing new in
  that state. Only `restart_current` or `hold_current` from Aedwon leaves it.
- [ ] `view` returns the sentence key, button keys, current lesson title and
  subject, chat lines, per-lesson states for the strip, counts, and the time
  left computed from finished lessons' measured durations (none shown before
  two lessons finish).
- [ ] Tests first with a fake dispatcher and injected forms: the full happy
  path, a dispute path, a copied pair, pause mid-lesson, a usage limit, pilot
  boundary, restart, hold, resume after a process restart from `queue.json`,
  and the pacing gate: with the current lesson in `needs_you`, repeated `tick`
  calls register nothing.
- [ ] Commit.

### Task 9: Page and server

**Files:** `page/index.html`, `server.py`, `tests/test_server.py`.

- [ ] Copy mockup version 3's styles and frame markup into `page/index.html`.
  Remove the dark control bar and the state radios. A short script fetches
  `/api/state` every 3 seconds and fills the one frame from `view`. Sentences,
  supporting lines, and button labels are a fixed table in the page keyed by
  the view's sentence key, with the mockup's exact text.
- [ ] `server.py` binds `127.0.0.1:8765`, serves the page, `GET /api/state`,
  and `POST /api/<start|pause|resume|hold|restart>`. A background thread calls
  `Run.tick` every 10 seconds. Run it with
  `python3 docs/content/audit/coverage-r1/level4/server.py`.
- [ ] Tests: each endpoint against a fake `Run`; and a text check that every
  sentence, supporting line, and button label in the page's table appears
  verbatim in mockup version 3.
- [ ] States the mockup lacks (`needs_you` with its reasons, dispatcher
  supervisor not running) are listed for Aedwon with proposed wording before
  they ship.
- [ ] Commit.

### Task 10: Eraser

**Files:** `eraser.py`, `tests/test_eraser.py`.

- [ ] `erase(issue_number)` fetches the issue, and replaces the body only when
  the title starts with `[relay]` and contains the run token from the local
  config, the body parses as a `workspace_write_file` request whose path is
  under `level4/inbox/`, and `eraser_confirmed` is true. The new body is one
  line naming the run and saying the form is saved locally. Anything else is
  refused and logged.
- [ ] Tests with a fake `gh`: each refusal, the confirmed path, and that the
  switch off means no `gh issue edit` call.
- [ ] Commit. The queue calls it after each accepted or rejected hand-in.

### Task 11: Planted lessons

**Files:** local only until the run ends.

- [ ] Choose ten lessons across subjects, none in the pilot's five real
  lessons. For each, copy the lesson and introduce two or three defects that
  break chat-judged major rules: a formula first used in an example (L17), a
  skipped solution step (L19), a wrong worked answer (B02), a term used before
  it is explained with no prerequisite teaching (L25), a rule stated without its
  condition (L27), an example stem that gives away the method (L05), teaching
  prose well above Grade 5 (L02). Each defect must leave the lesson otherwise
  natural.
- [ ] `key.json` lists per planted lesson each defect: rule id, the changed
  text, and what a correct finding must quote.
- [ ] A fresh reviewer who did not author them reads three planted lessons
  without the key and reports whether any edit is detectable as an edit. Fix
  and repeat until none is.
- [ ] Rebuild packets so planted packets exist. Nothing here is committed.

### Task 12: Reports

**Files:** `report.py`, `tests/test_report.py`.

- [ ] `pilot` writes `pilot-report.md`: per planted defect whether read A, read
  B, and the final result caught it, grouped by rule; dispute rate per rule;
  rejected forms; minutes per chat. Counts only, no pass mark.
- [ ] `final` writes `findings/<lesson-id>.md`, `illustrations.md`,
  `counting-check.md` (158 lessons, every in-scope rule accounted for per
  lesson, zero missing), `hold-list.md`, `summary.md`, and saves the planted key
  and miss-rate result. Planted packets are excluded from findings.
- [ ] Tests first on small fixture results: counts, exclusion of planted
  packets, and a failing counting check when one rule is missing.
- [ ] Commit.

### Task 13: Verification before the pilot

- [ ] Full test suite passes.
- [ ] A fresh reviewer who wrote none of the code reviews the diff against the
  spec, with attention to: output of `handin.py` leaking form content, the
  unexpected-change check, the copy flag, and the eraser's refusals.
- [ ] Dry run with no chat: inject two hand-written forms for one lesson through
  `handin.py` locally and watch the page move through reading, comparison, and
  finished.
- [ ] Re-read OpenAI's terms of use and usage policies as the dispatch runbook
  requires and record the result in the decision log.
- [ ] Report to Aedwon what he must do before Start: turn on a runner, sign in
  to ChatGPT in the dispatcher's Brave profile, start the dispatcher supervisor
  if the page cannot, and confirm or decline the eraser.
- [ ] Set `status.md` line 1 to
  `STATE: BLOCKED level 4 runs in web chats from the local queue; Codex stays stopped`.

## Self-review against the spec

- Every guardrail in the spec maps to a task: mechanical rules (2), no skipped
  rule, real quotes, proof for passes, version lock (3), planted defects (11,
  12), one hand-in and the change check (5), hold list (5, 8), never working
  around a limit (7, 8), independence layers (8 starts both together, 10
  erases, 4 opaque titles and the assignment's ban, 6 copy flag).
- Pilot and report: 8 and 12. Page: 9. Run control and stop conditions: 5, 8,
  13.
- Open facts are confined to Task 7 and are verified there before anything
  depends on them.
