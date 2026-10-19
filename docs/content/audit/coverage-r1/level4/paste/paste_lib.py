"""Paste mode for the Level 4 lesson audit.

Aedwon pastes one packet into a ChatGPT web chat by hand and pastes the reply
back. There is no relay, no dispatcher and no second reader (decision D4), so
only role A is expected. The checks are the existing ones: handin.process()
and form.py. This module only adapts the prompt, finds the JSON in a reply,
keeps the paste run's own state, and calls handin.process().

Python 3.9 standard library only.
"""
import json
import os
import re
import sys
import threading
import time
from pathlib import Path

PASTE_DIR = Path(__file__).resolve().parent
LEVEL4_DIR = PASTE_DIR.parent
if str(LEVEL4_DIR) not in sys.path:  # python3 -I does not add the script's folder
    sys.path.insert(0, str(LEVEL4_DIR))

import handin  # noqa: E402
import l4lib  # noqa: E402

ROLE = "A"
SCOPE_FILE = PASTE_DIR / "scope.txt"
# The paste run keeps its own state so it never touches a relay run's state.
STATE_DIR = Path(os.environ.get("PANTAS_L4_PASTE_STATE",
                                str(Path.home() / ".pantas-audit" / "level4-paste")))
PACKET_ID = re.compile(r"L4-\d{4}")
RESULT_WORDS = {0: "ACCEPTED", 1: "REJECTED", 2: "HELD", 3: "STOPPED", 64: "BAD REQUEST"}
STATES = ("todo", "accepted", "rejected", "held")


class PasteError(Exception):
    pass


# ---- scope ------------------------------------------------------------------

def read_scope(path=None):
    """Packet ids from scope.txt, in file order, without duplicates."""
    ids = []
    for number, line in enumerate(Path(path or SCOPE_FILE).read_text(encoding="utf-8").splitlines(), 1):
        entry = line.split("#", 1)[0].strip()
        if not entry:
            continue
        if not PACKET_ID.fullmatch(entry):
            raise PasteError("scope.txt line %d is not a packet id like L4-1055" % number)
        if entry not in ids:
            ids.append(entry)
    return ids


# ---- prompt adaptation ------------------------------------------------------

# The hand-in section runs from START to END. Inside it, the relay steps (from
# START to KEEP, and from CUT to END) are replaced. The bullets between KEEP
# and CUT say what the check enforces; they are rules the chat needs, so they stay.
START = "\n## How to hand in\n"
KEEP = "\nWhat the check enforces:\n"
CUT = "\nMake no other relay request."
END = "\n## The form\n"
# Two sentences outside that section that send the chat to the relay.
OUTSIDE = (
    (", apart from the relay instructions\n  your assignment names.", "."),
    ("You finish by handing in one form. Your chat reply is not read by anyone.",
     "You finish by replying with the completed form as one JSON code block, as set out under How to hand in."),
)
NEW_HAND_IN = (
    "Your role is `{role}` and this is attempt {attempt}. Put `{role}` in the form's `role` field.\n\n"
    "You may use web search to check hard-to-remember facts for rule B01. Prefer official and primary "
    "sources, and put the source URL in the finding's `problem` text. Search does not change rule L11: "
    "it stays `needs_source_check` or `not_applicable` as the rules say.\n\n"
    "When you finish, reply with only the completed form as one JSON code block, and nothing else. "
    "The form must be valid JSON: lessons contain LaTeX, so every backslash must be doubled and every "
    "double quote inside a text value escaped.\n\n"
    "If the reply is rejected, you will get a numbered list of reasons. Fix exactly those, then reply "
    "again with only the corrected form as one JSON code block. You get one retry after a rejection.\n"
)
# After adaptation, none of these may remain anywhere in the prompt.
FORBIDDEN = ("relay", "handin.py", "workspace_exec", "workspace_write_file", "[relay]")


def _once(text, marker):
    if text.count(marker) != 1:
        raise PasteError("the packet cannot be adapted safely: expected exactly one %r, found %d"
                         % (marker.strip(), text.count(marker)))
    return text.index(marker)


def adapt_prompt(packet_text, role=ROLE, attempt=1):
    """The packet with its hand-in instructions replaced for a chat that cannot use the relay."""
    for old, _new in OUTSIDE:
        _once(packet_text, old)
    start, keep = _once(packet_text, START), _once(packet_text, KEEP)
    cut, end = _once(packet_text, CUT), _once(packet_text, END)
    if not start < keep < cut < end:
        raise PasteError("the packet cannot be adapted safely: hand-in markers are out of order")
    text = packet_text
    for old, new in OUTSIDE:
        text = text.replace(old, new)
    # Offsets moved by the replacements above, so find the markers again.
    start, keep, cut, end = (text.index(marker) for marker in (START, KEEP, CUT, END))
    bullets = text[keep + 1:cut].strip("\n")
    section = "\n## How to hand in\n\n" + NEW_HAND_IN.format(role=role, attempt=attempt) + "\n" + bullets + "\n"
    adapted = text[:start] + section + text[end:]
    # Only the parts this function wrote or edited are checked: a lesson may use any word.
    leftover = [word for word in FORBIDDEN if word in (text[:start] + section).lower()]
    if leftover:
        raise PasteError("the packet cannot be adapted safely: %s still appears after the hand-in section "
                         "was replaced" % ", ".join(leftover))
    return adapted


# ---- finding the JSON in a reply --------------------------------------------

FENCE = re.compile(r"```[ \t]*([A-Za-z0-9_-]*)[ \t]*\r?\n(.*?)```", re.DOTALL)


def extract_json(reply):
    """(text, None) for the first JSON object found in a chat reply, else (None, message).

    Tries fenced blocks (json fences first), then the whole reply, then the
    span from the first { to the last }. The text is returned unchanged.
    """
    if not isinstance(reply, str) or not reply.strip():
        return None, "Nothing was pasted."
    fences = FENCE.findall(reply)
    candidates = [body for lang, body in fences if lang.lower() == "json"]
    candidates += [body for lang, body in fences if lang.lower() != "json"]
    candidates.append(reply)
    if "{" in reply and "}" in reply:
        candidates.append(reply[reply.index("{"):reply.rindex("}") + 1])
    first_error = None
    for candidate in candidates:
        try:
            value = json.loads(candidate)
        except ValueError as exc:
            first_error = first_error or exc
            continue
        if isinstance(value, dict):
            return candidate.strip(), None
    if first_error is not None and "{" in reply:
        return None, ("The reply holds something that looks like a form, but it is not valid JSON (%s). "
                      "Ask the chat to reply again with only the form as one JSON code block." % first_error)
    return None, "No JSON form was found in that reply. Ask the chat to reply with only the form as one JSON code block."


# ---- the paste run's state --------------------------------------------------

def reply_for_chat(lines):
    """Text Aedwon can paste back into the same chat after a rejection."""
    reasons = [line for line in lines[1:]]
    return ("Your form was rejected. Fix exactly these, then reply with only the corrected form as one "
            "JSON code block, and nothing else:\n" + "\n".join(reasons))


def no_stray_changes(queue):
    """A web chat cannot write to this machine, so there is nothing to compare against."""
    return []


class LessonList:
    """The Level 4 lesson list. A second list type (Level 5 question sets) can sit beside it."""

    key = "lessons"
    label = "Level 4 lessons"

    def __init__(self, state_dir=None, packets_dir=None, lesson_text=None, changes=no_stray_changes):
        self.state_dir = Path(state_dir or STATE_DIR)
        self.packets_dir = Path(packets_dir or (LEVEL4_DIR / "packets"))
        self.lesson_text = lesson_text or handin._lesson_text
        self.changes = changes
        self.lock = threading.Lock()
        self.index = l4lib.load_json(self.state_dir / "index.json")
        self.queue_path = self.state_dir / "queue.json"

    # -- reading state
    def _queue(self):
        return l4lib.load_json(self.queue_path)

    def ids(self):
        return list(self._queue()["order"])

    def _name(self, packet_id, queue):
        return "%s-%s-%s" % (packet_id, ROLE, queue["expected"][packet_id]["attempt"])

    def state_of(self, packet_id, queue=None):
        queue = queue or self._queue()
        name = self._name(packet_id, queue)
        if (self.state_dir / "forms" / ("%s.json" % name)).exists():
            return "accepted"
        rejected = self.state_dir / "forms" / "rejected"
        rejections = sum(1 for _ in rejected.glob("%s-r*.bin" % name))
        unreadable = sum(1 for _ in rejected.glob("%s-u*.bin" % name))
        if rejections >= handin.MAX_REJECTIONS or unreadable >= handin.MAX_UNREADABLE:
            return "held"
        return "rejected" if rejections or unreadable else "todo"

    def _last_path(self, packet_id):
        return self.state_dir / "last" / ("%s.json" % packet_id)

    def view(self):
        queue = self._queue()
        items, counts = [], {state: 0 for state in STATES}
        for packet_id in queue["order"]:
            state = self.state_of(packet_id, queue)
            counts[state] += 1
            last = None
            if self._last_path(packet_id).exists() and state != "todo":
                last = l4lib.load_json(self._last_path(packet_id))
            entry = self.index[packet_id]
            items.append({"id": packet_id, "title": entry["title"], "subject": entry["subject"], "state": state,
                          "attempt": queue["expected"][packet_id]["attempt"], "last": last})
        return {"key": self.key, "label": self.label, "total": len(items), "counts": counts, "items": items,
                "stopped": (self.state_dir / "stop.json").exists()}

    def _known(self, packet_id):
        if packet_id not in self._queue()["expected"]:
            raise PasteError("that packet is not in this run")

    # -- the prompt
    def prompt(self, packet_id):
        self._known(packet_id)
        queue = self._queue()
        text = (self.packets_dir / ("%s.md" % packet_id)).read_text(encoding="utf-8")
        return adapt_prompt(text, ROLE, queue["expected"][packet_id]["attempt"])

    # -- the check
    def check(self, packet_id, reply):
        """Run one pasted reply through handin.process(). Returns a dict for the page."""
        self._known(packet_id)
        text, problem = extract_json(reply)
        if text is None:
            return {"code": None, "word": "NOT CHECKED", "lines": [problem + " This did not use up an attempt."],
                    "reply": ""}
        with self.lock:
            queue = self._queue()
            attempt = queue["expected"][packet_id]["attempt"]
            inbox = self.state_dir / "inbox"
            inbox.mkdir(parents=True, exist_ok=True)
            inbox_file = inbox / ("%s-%s-%s.json" % (packet_id, ROLE, attempt))
            inbox_file.write_text(text, encoding="utf-8")
            try:
                code, lines = handin.process(packet_id, ROLE, attempt, state_dir=self.state_dir, inbox_dir=inbox,
                                             changes=self.changes, lesson_text=self.lesson_text)
            finally:
                if inbox_file.exists():  # process() leaves it when it answers before reading the form
                    inbox_file.unlink()
            result = {"code": code, "word": RESULT_WORDS.get(code, "STOPPED"), "lines": lines,
                      "reply": reply_for_chat(lines) if code == 1 else ""}
            l4lib.save_json(self._last_path(packet_id), result)
            return result

    # -- a new chat after a hold
    def start_over(self, packet_id):
        """Next attempt for a held packet. The old forms are moved aside, never deleted."""
        self._known(packet_id)
        with self.lock:
            queue = self._queue()
            if self.state_of(packet_id, queue) != "held":
                raise PasteError("only a held packet can be started over")
            attempt = queue["expected"][packet_id]["attempt"]
            aside = self.state_dir / "forms" / "discarded" / ("%s-attempt-%d" % (packet_id, attempt))
            aside.mkdir(parents=True, exist_ok=True)
            forms = self.state_dir / "forms"
            for path in list((forms / "rejected").glob("%s-*.bin" % packet_id)):
                path.rename(aside / path.name)
            if self._last_path(packet_id).exists():
                self._last_path(packet_id).rename(aside / "last.json")
            queue["expected"][packet_id]["attempt"] = attempt + 1
            l4lib.save_json(self.queue_path, queue)


def timestamp():
    return time.strftime("%Y%m%d-%H%M%S")
