"""Shared paths, state and git helpers for the CSE rewrite relay tools (plan P0.4).

Python 3.9 standard library only. Every script in this folder is run as
`python3 -I script.py`, which does not put the script's folder on the import
path, so each script starts with `import rw_lib` after adding this folder.
"""
import datetime
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # a stray __pycache__ would count as a change in the worktree

RELAY_DIR = Path(__file__).resolve().parent
L4_DIR = RELAY_DIR / "l4"
for _folder in (str(RELAY_DIR), str(L4_DIR)):
    if _folder not in sys.path:
        sys.path.insert(0, _folder)

import l4lib  # noqa: E402  (vendored; see l4/SOURCE.txt)

BRANCH = "content/cse-rewrite-r1"
REMOTE_BRANCH = "origin/" + BRANCH
WORKSPACE = "Pantas-wt-cse-rewrite-r1"
INBOX_REL = "tools/content_rewrite/relay/inbox"
BRIEFS_REL = "docs/content/rewrite/briefs"
READS_REL = "docs/content/rewrite/reads"
HANDIN_REL = "tools/content_rewrite/relay/handin.py"
LESSON_ROOT_REL = "content/lessons"
RELAY_REPO = "Aedwon/chatgpt-terminal-relay"
STANDARDS_REF = "origin/main"
STANDARDS_FILES = ("docs/content/lesson-style-guide.md", "docs/content/content-checklist.md")

MAX_REJECTIONS = 2   # per lesson, then the lesson is held
MAX_UNREADABLE = 5   # a form that is not valid JSON is a transport slip, so it gets more tries
DELETED = "deleted"

json_load = l4lib.load_json
json_save = l4lib.save_json
sha256_text = l4lib.sha256_text


class RewriteError(Exception):
    pass


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")


def default_root():
    """The worktree these tools live in: tools/content_rewrite/relay/rw_lib.py is three folders deep."""
    return Path(os.environ.get("PANTAS_REWRITE_ROOT") or RELAY_DIR.parents[2])


def default_state():
    return Path(os.environ.get("PANTAS_REWRITE_STATE", str(Path.home() / ".pantas-rewrite")))


class Git:
    """Runs git in one worktree. Tests replace it with a fake that has the same methods."""

    def __init__(self, root):
        self.root = Path(root)

    def run(self, *args, check=True):
        """Output bytes. A failure raises RewriteError without the output, which can hold file names."""
        env = dict(os.environ, GIT_TERMINAL_PROMPT="0", LC_ALL="C")
        proc = subprocess.run(["git"] + list(args), cwd=str(self.root), stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, env=env)
        if check and proc.returncode != 0:
            raise RewriteError("git %s failed" % " ".join(args[:2]))
        return proc.stdout

    def text(self, *args, check=True):
        return self.run(*args, check=check).decode("utf-8", "surrogateescape")

    def ok(self, *args):
        env = dict(os.environ, GIT_TERMINAL_PROMPT="0", LC_ALL="C")
        return subprocess.run(["git"] + list(args), cwd=str(self.root), stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, env=env).returncode == 0

    def show(self, spec):
        """File content at a ref ("HEAD:path"), or None when there is none."""
        proc = subprocess.run(["git", "show", spec], cwd=str(self.root), stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL, env=dict(os.environ, GIT_TERMINAL_PROMPT="0"))
        return proc.stdout.decode("utf-8") if proc.returncode == 0 else None


class Ctx:
    """Where things are: the worktree, the state folder and git."""

    def __init__(self, root=None, state_dir=None, git=None):
        self.root = Path(root or default_root())
        self.state = Path(state_dir or default_state())
        self.git = git or Git(self.root)

    # -- paths
    def inbox_dir(self, batch_id):
        return self.root / INBOX_REL / batch_id

    def state_file(self, *parts):
        return self.state.joinpath(*parts)

    # -- batches
    def load_batches(self):
        path = self.state_file("batches.json")
        if not path.exists():
            return {"order": [], "batches": {}}
        return json_load(path)

    def save_batches(self, data):
        json_save(self.state_file("batches.json"), data)

    def batch(self, batch_id):
        return self.load_batches()["batches"].get(batch_id)

    # -- accepted work, one record per lesson and kind
    def accepted_path(self, kind, lesson_id):
        return self.state_file("accepted", kind, lesson_id + ".json")

    def accepted(self, kind, lesson_id):
        path = self.accepted_path(kind, lesson_id)
        return json_load(path) if path.exists() else None

    def accepted_all(self, kind):
        folder = self.state_file("accepted", kind)
        if not folder.is_dir():
            return {}
        return {path.stem: json_load(path) for path in sorted(folder.glob("*.json"))}

    # -- rejections
    def rejections(self, batch_id, lesson_id):
        data = self._rejections()
        entry = data.get("%s/%s" % (batch_id, lesson_id), {})
        return entry.get("r", 0), entry.get("u", 0)

    def _rejections(self):
        path = self.state_file("rejections.json")
        return json_load(path) if path.exists() else {}

    def add_rejection(self, batch_id, lesson_id, readable):
        data = self._rejections()
        entry = data.setdefault("%s/%s" % (batch_id, lesson_id), {"r": 0, "u": 0})
        entry["r" if readable else "u"] += 1
        json_save(self.state_file("rejections.json"), data)
        return entry["r" if readable else "u"]

    def is_held(self, batch_id, lesson_id):
        rejected, unreadable = self.rejections(batch_id, lesson_id)
        return rejected >= MAX_REJECTIONS or unreadable >= MAX_UNREADABLE

    # -- marks and events
    def copied(self):
        path = self.state_file("copied.json")
        return json_load(path) if path.exists() else {}

    def mark_copied(self, batch_id):
        data = self.copied()
        data[batch_id] = now()
        json_save(self.state_file("copied.json"), data)

    def event(self, **fields):
        fields["at"] = now()
        path = self.state_file("events.jsonl")
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(str(path), "a", encoding="utf-8") as handle:
            handle.write(json.dumps(fields) + "\n")

    def stop(self, reason, batch_id):
        json_save(self.state_file("stop.json"), {"at": now(), "reason": reason, "batch": batch_id})

    def stopped(self):
        return self.state_file("stop.json").exists()

    def events(self):
        path = self.state_file("events.jsonl")
        if not path.exists():
            return []
        return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]

    def prerequisites(self):
        """Optional {lesson id: [prerequisite lesson ids]}, copied by the lead into the state folder."""
        path = self.state_file("prerequisites.json")
        return json_load(path) if path.exists() else {}


# ---- lesson files ------------------------------------------------------------

def topic_of(path):
    """'subject/topic' for content/lessons/<subject>/<topic>/<slug>.md, else ''."""
    parts = Path(path).parts
    if len(parts) >= 5 and parts[0] == "content" and parts[1] == "lessons":
        return "%s/%s" % (parts[2], parts[3])
    return ""


def path_parts(path):
    """(subject dir, topic dir, slug) as the mechanical checks expect, or None."""
    parts = Path(path).parts
    if len(parts) == 5 and parts[0] == "content" and parts[1] == "lessons":
        return parts[2], parts[3], Path(parts[4]).stem
    return None


def lesson_rel(path):
    """Path relative to content/lessons, as the audit sweeps expect it."""
    return str(Path(path).relative_to(LESSON_ROOT_REL))


def clean_text(raw):
    """Decode a saved lesson: strict UTF-8, LF line ends, exactly one final newline."""
    text = raw.decode("utf-8")
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text.rstrip("\n") + "\n"


def is_filipino(path, text):
    if "filipino" in str(path).lower():
        return True
    return bool(re.search(r"^#{2,3} .*Filipino", text, re.M))


def short(sha):
    return sha[:8]


def file_sha(path):
    try:
        return hashlib.sha256(Path(path).read_bytes()).hexdigest()
    except OSError:
        return DELETED
