"""Build the prompt for one batch: what Aedwon pastes into a ChatGPT web chat.

A prompt is a list of parts. Authored parts are this tool's own instructions and are checked for
leftover placeholders, em dashes and British spelling. Embedded parts (the standards, a brief,
lesson text) are copied unchanged and are not checked, because the corpus legitimately holds them.
Python 3.9 standard library only.
"""
import json
import re

import briefs as briefs_mod
import readpacket
import rw_lib

import l4lib  # noqa: E402  (vendored)

LESSON_START = "<<<<<<<< LESSON START"
LESSON_END = ">>>>>>>> LESSON END"
BRIEF_START = "<<<<<<<< BRIEF START"
BRIEF_END = ">>>>>>>> BRIEF END"
FORBIDDEN = ("{{", "}}", "TODO", "TBD", "ROLE", "ATTEMPT", "<batch", "<lesson", "\u2014")
BRITISH = ("colour", "practise", "behaviour", "analyse", "organise", "centre", "grey", "favour")


class Parts:
    def __init__(self):
        self.parts = []

    def add(self, text, authored=True):
        self.parts.append((authored, text.strip("\n")))

    def text(self):
        return "\n\n".join(text for _, text in self.parts) + "\n"

    def authored(self):
        return "\n".join(text for authored, text in self.parts if authored)


def check_authored(parts):
    """Raise when this tool's own text holds a placeholder, an em dash or a British spelling."""
    text = parts.authored()
    bad = [word for word in FORBIDDEN if word in text]
    bad += [word for word in BRITISH if re.search(r"\b%s" % word, text, re.I)]
    if bad:
        raise rw_lib.RewriteError("the prompt text still holds: %s" % ", ".join(bad))


def _block(start, text, end):
    return "%s\n%s\n%s" % (start, text.rstrip("\n"), end)


# ---- standards ---------------------------------------------------------------

def policy_revision(ctx):
    return ctx.git.text("rev-parse", "--short=8", rw_lib.STANDARDS_REF).strip()


def standards(ctx):
    """{path: text} for the lesson guide and the checklist, read from origin/main."""
    out = {}
    for path in rw_lib.STANDARDS_FILES:
        text = ctx.git.show("%s:%s" % (rw_lib.STANDARDS_REF, path))
        if text is None:
            raise rw_lib.RewriteError("cannot read %s from %s; run git fetch" % (path, rw_lib.STANDARDS_REF))
        out[path] = text
    return out


def add_standards(ctx, parts):
    docs = standards(ctx)
    parts.add("## Standards\n\nThese are the current standards, from the repository's main branch (revision %s). "
              "They apply to everything below. The guide is read once here and is not repeated." % policy_revision(ctx))
    names = {"docs/content/lesson-style-guide.md": "LESSON STYLE GUIDE", "docs/content/content-checklist.md": "CONTENT CHECKLIST"}
    for path in rw_lib.STANDARDS_FILES:
        parts.add(_block("<<<<<<<< %s START" % names[path], docs[path], ">>>>>>>> %s END" % names[path]), authored=False)


# ---- relay steps -------------------------------------------------------------

def _issue(title, body):
    return "Create one Issue in `%s` titled `[relay] %s` with this body:\n\n```json\n%s\n```" % (
        rw_lib.RELAY_REPO, title, json.dumps(body))


def relay_steps(batch, file_ext, what, write_noun):
    """The 'How to hand in' section. what: 'lesson' or 'form'. write_noun: what the content field holds."""
    batch_id, lowered = batch["id"], batch["id"].lower()
    first = batch["lessons"][0]
    save = {"relay_version": 2, "action": "workspace_write_file", "workspace": rw_lib.WORKSPACE,
            "path": "%s/%s/%s%s" % (rw_lib.INBOX_REL, batch_id, first, file_ext), "content": "(%s)" % write_noun}
    handin = {"relay_version": 2, "action": "workspace_exec", "workspace": rw_lib.WORKSPACE,
              "argv": ["python3", "-I", rw_lib.HANDIN_REL, batch_id, "1"], "timeout_seconds": 300}
    push = {"relay_version": 2, "action": "git_push_current", "workspace": rw_lib.WORKSPACE}
    lines = [
        "## How to hand in",
        "",
        "You hand in through the terminal relay. Each relay request is one GitHub Issue in `%s`. "
        "Make the requests in this order, and make no other relay request." % rw_lib.RELAY_REPO,
        "",
        "The content of a saved file travels as one JSON string inside the request body. Every backslash in it "
        "must be doubled and every double quote escaped. A %s is full of LaTeX backslashes, so do not write that "
        "string by hand. Build the request as an object and serialize it with a JSON encoder." % what,
        "",
        "**Step 1. Save each %s.** %s" % (what, _issue("%s save %s" % (lowered, first), save)),
        "",
        "Do this once for every %s in this batch. Change only `path` (use the %s's own id as the file name, "
        "with the same folder and the extension `%s`) and `content`. Write all the files before step 2."
        % (what, what, file_ext),
        "",
        "**Step 2. Have them checked.** %s" % _issue("%s hand-in" % lowered, handin),
        "",
        "The first hand-in uses attempt `1`. For a later hand-in in this chat, change only the last argument, to "
        "`2` and then `3`.",
        "",
        "**Step 3. Read the result comment on the Issue from step 2.** Its first line is one of these words.",
        "",
        "- `ACCEPTED`: every %s you handed in was checked and committed. A line starting `COMMITTED` gives the "
        "commit. Go to step 4. If a line starts `NOT RECEIVED`, those %ss had no saved file: save them (step 1) "
        "and hand in again (step 2)." % (what, what),
        "- `REJECTED`: the comment lists numbered reasons under each %s id. If it also has a `COMMITTED` line, do "
        "step 4 first. Then fix exactly the listed reasons and nothing else, save only the rejected %ss again "
        "(step 1), and hand in again (step 2) with the next attempt number. A %s that is rejected twice is held."
        % (what, what, what),
        "- `HELD`, `STOPPED`, or `BAD REQUEST`: if there is a `COMMITTED` line, do step 4 first. Then stop. Do "
        "not hand in again and do not try other values. Tell the user the word, the %s ids named, and nothing "
        "else." % what,
        "",
        "**Step 4. Publish what was committed.** %s" % _issue("%s push" % lowered, push),
        "",
        "Do this once after every hand-in whose result has a `COMMITTED` line. Read its result comment. If the "
        "push fails, stop and tell the user.",
        "",
        "Rules for the relay:",
        "",
        "- Read no other Issue and open no other file, branch or repository.",
        "- Change no file other than the saved files above. Never run `git` yourself, except through step 4.",
        "- The check never prints %s text. Its reasons name rules, counts and line numbers. Fix the %s from "
        "those, using the %s you wrote." % (what, what, what),
        "- If a sign-in, usage limit or security prompt appears, stop and tell the user. Do not work around it.",
        "- When every %s in the batch is accepted and pushed, reply with the one word `done`." % what,
    ]
    return "\n".join(lines)


# ---- the rewrite prompt --------------------------------------------------------

REWRITE_RULES = """
1. Fix every item under "Fix these" in a lesson's brief. Each item has a quote, the problem, and a fix size.
   When you finish a lesson, check each item against your new text.
2. Add every item under "CSE teaching to add". Teach it inside the lesson's existing sections, in the lesson's
   style. A gap that asks for a Filipino section follows the guide's rules for Filipino-language teaching.
3. Fix an item under "Optional" only when you are editing that passage anyway.
4. Never remove a case, fact, or example that another exam in the brief's "Tagged exams" needs. You may add
   Civil Service Exam cases. You may not take away cases the other tagged exams use.
5. Keep the frontmatter id line exactly as it is. Keep every frontmatter key, in the same order. Change `title`,
   `summary`, or `estimatedMinutes` only when the new content needs it, and keep `estimatedMinutes` from 8 to 15.
6. Where a figure would help the student, add one marker on its own line, as one line:
   `<!-- ILLUSTRATION: what to draw, with the exact labels and values from the lesson -->`
   Do not draw anything and do not add images or links. Keep the markers that are already there unless the
   figure no longer fits.
7. Teaching text is plain English a Grade 5 student can read: short sentences, one to three sentences in a
   paragraph. Filipino-language lessons use simple Filipino at the same standard. Example questions use
   realistic exam wording.
8. Write no em dashes. Use a comma or a colon. Use American spelling: practice, color, behavior, analyze.
   Write "points", never "marks", and "questions", never "cards".
9. Write math between single dollar signs, as in `$x^2$`. Write `\\dfrac` for a fraction, never `\\frac`. The one
   exception is a fraction inside another fraction, which uses `\\frac`.
10. Never invent a fact or a figure. If you cannot confirm a hard-to-remember fact, leave it out. You may use
    web search to check a fact. Prefer official sources.
11. Write the whole lesson file each time, from the first `---` line to the last line. Do not write a patch,
    a summary, or a comment about your changes.
"""

ENFORCED = """
What the check enforces:

- The frontmatter `_id` line is unchanged and the file parses.
- The lesson is not much shorter than the current one (under 60% is rejected).
- No new definite style findings: em dashes, `\\frac` at the top level, tables, links, code blocks, a missing
  `**Solution:**` label, a wrong heading form, a changed frontmatter shape.
- No new structure, formula, device, or figure-marker findings. A marker must sit on a single line.
- Changes that match no brief item are not rejected. They are listed for the reader and the lead.
"""


def _lesson_blocks(ctx, parts, batch, briefs):
    total = len(batch["lessons"])
    for number, lesson_id in enumerate(batch["lessons"], 1):
        brief = briefs[lesson_id]
        path = brief["path"]
        text = ctx.git.show("HEAD:" + path)
        if text is None:
            raise rw_lib.RewriteError("lesson %s is not in the repository at this commit" % lesson_id)
        expected = batch.get("sha256", {}).get(lesson_id)
        if expected and l4lib.sha256_text(text) != expected:
            raise rw_lib.RewriteError("lesson %s changed after this batch was built" % lesson_id)
        parts.add("## Lesson %d of %d: `%s`\n\nSave file: `%s/%s/%s%s`\nTagged exams: %s"
                  % (number, total, lesson_id, rw_lib.INBOX_REL, batch["id"], lesson_id, batch["_ext"],
                     ", ".join(brief["exams"])))
        parts.add("### Brief\n\n" + _block(BRIEF_START, brief["text"], BRIEF_END), authored=False)
        yield lesson_id, brief, text


def rewrite_prompt(ctx, batch):
    batch = dict(batch, _ext=".md")
    briefs = briefs_mod.load_all(ctx)
    parts = Parts()
    parts.add("# Pantas CSE lesson rewrite, batch %s" % batch["id"])
    parts.add(
        "## Your job\n\n"
        "You rewrite %d lessons of the Pantas exam review app. Pantas prepares Filipino students for the Civil "
        "Service Exam (CSE) and for other entrance and scholarship exams. Every lesson comes with a brief that "
        "lists what to fix and what Civil Service Exam teaching to add. For each lesson you write the full new "
        "lesson file and hand it in through the terminal relay.\n\n"
        "The lessons are all from the topic `%s`.\n\n"
        "- This prompt holds everything you need: the standards, each lesson's brief, and each lesson's current "
        "text.\n"
        "- Use only this prompt and the relay requests under \"How to hand in\". Do not open any other file, "
        "issue, or pull request in any repository.\n"
        "- Every wording decision is yours. Do not ask the user anything. Your chat reply is not read by anyone. "
        "Your result is the hand-in." % (len(batch["lessons"]), batch["topic"]))
    add_standards(ctx, parts)
    parts.add("## Rules for the rewrite\n" + REWRITE_RULES)
    for lesson_id, brief, text in _lesson_blocks(ctx, parts, batch, briefs):
        parts.add("### Current lesson text\n\n" + _block(LESSON_START, text, LESSON_END), authored=False)
    parts.add(relay_steps(dict(batch), ".md", "lesson", "the whole lesson file"))
    parts.add(ENFORCED)
    check_authored(parts)
    return parts.text()


# ---- the read prompt -----------------------------------------------------------

def _rules_table(rule_ids):
    rows = ["| Id | Rule | Severity | How to check | Guide section |", "|---|---|---|---|---|"]
    for rule in l4lib.load_rules():
        if rule["id"] in rule_ids:
            rows.append("| %s | %s | %s | %s | %s |" % (rule["id"], rule["rule"], rule["severity"], rule["how"],
                                                         rule["source"]))
    return "\n".join(rows)


def read_prompt(ctx, batch):
    batch = dict(batch, _ext=".json")
    briefs = briefs_mod.load_all(ctx)
    prerequisites = ctx.prerequisites()
    parts = Parts()
    parts.add("# Pantas CSE lesson read, batch %s" % batch["id"])
    parts.add(
        "## Your job\n\n"
        "You are an independent reader of %d lessons of the Pantas exam review app. Another chat rewrote each "
        "lesson to fix the problems in its brief and to add Civil Service Exam teaching. You judge each rewritten "
        "lesson against the lesson standards, and you check every brief item against the rewritten text. You "
        "report findings. You change nothing.\n\n"
        "- This prompt holds everything you need: the standards, each lesson's brief, and each rewritten lesson.\n"
        "- Judge only from this prompt. Use only the relay requests under \"How to hand in\". Do not open any "
        "other file, issue, or pull request in any repository. You have not seen how the lessons were written, "
        "and the check depends on that.\n"
        "- Every verdict is yours. Do not ask the user anything. Your chat reply is not read by anyone. Your "
        "result is the hand-in." % len(batch["lessons"]))
    add_standards(ctx, parts)
    parts.add((rw_lib.RELAY_DIR / "l4" / "judging.md").read_text(encoding="utf-8"), authored=False)
    for lesson_id, brief, text in _lesson_blocks(ctx, parts, batch, briefs):
        pkt = readpacket.packet(lesson_id, text, brief["path"])
        record = ctx.accepted("rewrite", lesson_id) or {}
        parts.add("### Rewritten lesson text\n\n" + _block(LESSON_START, text, LESSON_END), authored=False)
        loose = readpacket.uncovered_changes(record)
        if loose:
            lines = ["### Changes that match no brief item\n\nA script could not match these changed passages to "
                     "any brief item or gap. Read them with extra care. Each starts at the lesson file line given.\n"]
            for change in loose:
                lines.append("- line %d (%s): %s" % (change["line"], change["kind"], " ".join(change["text"].split())))
            parts.add("\n".join(lines), authored=False)
        wanted = prerequisites.get(lesson_id, [])
        if wanted:
            blocks = []
            for other in wanted:
                if other in briefs:
                    other_text = ctx.git.show("HEAD:" + briefs[other]["path"])
                    if other_text:
                        blocks.append("#### Prerequisite lesson: %s\n\n%s" % (other, other_text))
            if blocks:
                parts.add("### Prerequisite lessons\n\n" + "\n\n".join(blocks), authored=False)
        candidates = readpacket.candidates_text(text, brief["path"])
        parts.add("### Script candidates\n\n" + (candidates or
                  "The script flagged nothing in this lesson that needs your confirmation."), authored=False)
        parts.add("### Rules on the form for this lesson\n\n" + _rules_table(pkt["rule_ids"]), authored=False)
        form_json = json.dumps(readpacket.blank_form(pkt, brief), indent=1, ensure_ascii=False)
        parts.add("### The form for `%s`\n\nFill this in. Keep every key. Do not add or remove rules or brief "
                  "items. Save it as `%s/%s/%s.json`.\n\n```json\n%s\n```"
                  % (lesson_id, rw_lib.INBOX_REL, batch["id"], lesson_id, form_json))
    parts.add(relay_steps(dict(batch), ".json", "form", "the whole form as JSON"))
    parts.add(
        "What the check enforces:\n\n"
        "- Every quote is at least 8 characters, copied exactly from the rewritten lesson, and not a bare heading.\n"
        "- Every `problem` and every accuracy `concern` is at least 20 characters. Every `note` is at least 15 "
        "characters, and a brief item note is at least 20.\n"
        "- `not_applicable` is allowed only on L03, L14, L21, L23, and L08 to L12.\n"
        "- Empty values are `[]` and `\"\"`, never `null`.\n"
        "- Do not reuse one `checked` text across several rules. Say what you checked for each rule.\n"
        "- Every brief item has a status, `fixed` or `not_fixed`, with a quote and a note.")
    check_authored(parts)
    return parts.text()
