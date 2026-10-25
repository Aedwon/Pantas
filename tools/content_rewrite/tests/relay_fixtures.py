"""A throwaway git repository with lessons, briefs and a fake origin, for the relay tests.

Nothing here touches the real worktree, GitHub, or the relay.
"""
import os
import subprocess
import sys
import tempfile
from pathlib import Path

RELAY = Path(__file__).resolve().parents[1] / "relay"
sys.path.insert(0, str(RELAY))
sys.dont_write_bytecode = True

import rw_lib  # noqa: E402

SUBJECT, TOPIC = "mathematics", "algebra"
SLUGS = ["alpha", "beta", "gamma", "delta", "epsilon"]

STYLE_GUIDE = "# Lesson style guide\n\nWrite for Grade 5. No em dashes.\n"
CHECKLIST = "# Content checklist\n\n| B06 | No em dashes |\n"


def lesson_id(slug):
    return "lesson-%s-%s" % (TOPIC, slug)


def lesson_path(slug):
    return "content/lessons/%s/%s/%s.md" % (SUBJECT, TOPIC, slug)


def lesson_text(slug, extra="", core=None):
    core = core or ("We use letters for numbers we do not know yet. A variable is one of these letters. "
                    "Add two variables by adding their coefficients.")
    return (
        '---\n_id: "%s"\ntitle: "Lesson %s"\nsummary: "Learn about %s."\nsubject: "subject-%s"\n'
        'topic: "topic-%s"\nestimatedMinutes: 10\nisActive: true\n---\n'
        "## Core Concept\n\n%s\n\n%s"
        "## Examples\n\n### #1: Adding\n\nWhat is $x + x$?\n\n**Solution:**\n\n1. Add the coefficients.\n"
        "2. The sum is $2x$.\n\n"
        "## Traps to Watch For\n\n### #1: Forgetting the coefficient\n\n> Count the letters you add.\n\n"
        "Students write $x + x = x^2$. That is a mistake.\n"
        % (lesson_id(slug), slug, slug, SUBJECT, TOPIC, core, extra))


def brief_text(slug, quote="A variable is one of these letters."):
    lid = lesson_id(slug)
    return (
        "# Brief: Lesson %s\n\nLesson id: `%s`\nLesson path: `%s`\n\nTagged exams: cse-professional, upcat\n\n"
        "Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.\n\n"
        "## Fix these\n\n### 1. `%s|L02|0`\n- Rule: L02\n- Fix size: small\n- Quote:\n> %s\n"
        "- Problem: The sentence about variables is too vague for a Grade 5 reader to follow.\n"
        "- Triage reason: vague.\n\n"
        "## CSE teaching to add\n\n### 1. `%s#7`\n- Facet: Coefficient arithmetic in civil service tests\n"
        "- Verdict: thin\n- Missing ideas:\n  - Coefficients combine when letters match, with a civil service "
        "style example.\n\n"
        "## Optional, fix only if editing that passage anyway\n\n"
        "- `%s|L03|0` (L03): The word simplify first appears without a one line meaning. Reason: minor.\n\n"
        "## Figures\n\nNone.\n\n## Rules cited\n\n| L02 | Grade 5 | Major | read | LSG |\n"
        % (slug, lid, lesson_path(slug), lid, quote, lid, lid))


def git(root, *args, check=True):
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@example.com",
               GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@example.com")
    proc = subprocess.run(["git"] + list(args), cwd=str(root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    if check and proc.returncode:
        raise RuntimeError("git %s: %s" % (" ".join(args), proc.stderr.decode()))
    return proc.stdout.decode()


class Repo:
    """A repo on branch content/cse-rewrite-r1 with a bare origin that has main and the branch."""

    def __init__(self, slugs=SLUGS):
        self.tmp = tempfile.TemporaryDirectory()
        base = Path(self.tmp.name)
        self.origin = base / "origin.git"
        self.root = base / "work"
        self.state = base / "state"
        self.root.mkdir()
        git(base, "init", "-q", "--bare", str(self.origin))
        git(self.root, "init", "-q", "-b", "main")
        # CI runners have no global git identity, and the hand-in commits.
        git(self.root, "config", "user.name", "Fixture")
        git(self.root, "config", "user.email", "fixture@example.invalid")
        git(self.root, "remote", "add", "origin", str(self.origin))
        self.write(".gitignore", "tools/content_rewrite/relay/inbox/\n")
        self.write("docs/content/lesson-style-guide.md", STYLE_GUIDE)
        self.write("docs/content/content-checklist.md", CHECKLIST)
        git(self.root, "add", "-A")
        git(self.root, "commit", "-q", "-m", "main")
        git(self.root, "push", "-q", "origin", "main")
        git(self.root, "checkout", "-q", "-b", rw_lib.BRANCH)
        for slug in slugs:
            self.write(lesson_path(slug), lesson_text(slug))
            self.write("%s/%s.md" % (rw_lib.BRIEFS_REL, lesson_id(slug)), brief_text(slug))
        self.write("%s/new-lessons.md" % rw_lib.BRIEFS_REL, "# New lessons\n")
        git(self.root, "add", "-A")
        git(self.root, "commit", "-q", "-m", "lessons")
        git(self.root, "push", "-q", "origin", rw_lib.BRANCH)
        git(self.root, "fetch", "-q", "origin")
        self.ctx = rw_lib.Ctx(root=self.root, state_dir=self.state)

    def write(self, rel, text):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def inbox(self, batch_id, name, text):
        path = self.root / rw_lib.INBOX_REL / batch_id / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8") if isinstance(text, str) else path.write_bytes(text)

    def head(self):
        return git(self.root, "rev-parse", "HEAD").strip()

    def remote_head(self):
        return git(self.origin, "rev-parse", rw_lib.BRANCH).strip()

    def cleanup(self):
        self.tmp.cleanup()


# ---- helpers for rewrites and read forms --------------------------------------

def rewritten(slug):
    """A clean rewrite of the fixture lesson that fixes its brief item and adds a figure marker."""
    return lesson_text(
        slug,
        extra="<!-- ILLUSTRATION: number line with x and 2x marked -->\n\n",
        core=("We use letters for numbers we do not know yet. A variable is one letter that stands for a number. "
              "Add two variables by adding their coefficients, which are the numbers in front."))


def accept_rewrite(repo, batch_id, slugs=None, fakes=None):
    """Hand in clean rewrites for every lesson of a rewrite batch. Returns handin.process's result."""
    import handin
    batch = repo.ctx.batch(batch_id)
    for lid in batch["lessons"]:
        slug = lid.replace("lesson-%s-" % TOPIC, "")
        repo.inbox(batch_id, lid + ".md", rewritten(slug))
    return handin.process(batch_id, "1", repo.ctx)


def good_form(repo, lesson_id_, status="fixed"):
    """A read form that passes: every rule judged, every brief item given a status."""
    import briefs as briefs_mod
    import readpacket
    brief = briefs_mod.load_all(repo.ctx)[lesson_id_]
    text = repo_git_show(repo, brief["path"])
    pkt = readpacket.packet(lesson_id_, text, brief["path"])
    form = readpacket.blank_form(pkt, brief)
    import l4lib
    rules = {r["id"]: r for r in l4lib.load_rules()}
    for number, rule_id in enumerate(pkt["rule_ids"]):
        entry = form["rules"][rule_id]
        if rule_id in ("L03", "L14", "L21", "L23", "L08", "L09", "L10", "L12", "L11"):
            entry["verdict"] = "not_applicable"
            entry["note"] = "This rule has nothing to judge in a lesson like this one."
        else:
            entry["verdict"] = "pass"
            entry["checked"] = ["Checked rule %s number %d against the lesson text and found it holds." % (rule_id, number)]
            entry["note"] = ""
    for item_id in form["brief_items"]:
        form["brief_items"][item_id] = {"status": status, "quote": "A variable is one letter that stands for a number.",
                                        "note": "Read the rewritten sentence and it now fixes the problem."}
    return form


def repo_git_show(repo, path):
    return git(repo.root, "show", "HEAD:" + path)
