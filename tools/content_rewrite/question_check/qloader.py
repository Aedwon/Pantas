"""Shared loader and scope helpers for the CET question check.

PyYAML is not available, so this is a small indentation based YAML reader.
It started from the loader in tools/audit/sweep_questions.py (CSE branch),
which only read the hand-written block style. The question corpus also holds
PyYAML-dumped files (sequences at the key's indent, wrapped quoted scalars),
so this version is a general reader for the subset the corpus uses: mappings,
sequences, plain, single-quoted, double-quoted and block (| and >) scalars,
and flow lists. Anything else raises, so a new shape fails loudly.

Scripts run with `python3 -I`, so they must add this folder to sys.path
themselves before importing this module.
"""
import json
import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
QUESTIONS = REPO / "content" / "questions"
LESSONS = REPO / "content" / "lessons"
CET_EXAMS = {"upcat", "acet", "dlsucet", "ustet"}
CSE_COMMIT = "975d2564f"

KEY_RE = re.compile(r"^([A-Za-z_][\w-]*):(?:\s+(.*))?$")
INT_RE = re.compile(r"^-?\d+$")
FLOAT_RE = re.compile(r"^-?\d+\.\d+$")


class YamlError(Exception):
    pass


def _indent(line):
    return len(line) - len(line.lstrip(" "))


def _is_skippable(line):
    s = line.strip()
    return not s or s.startswith("#") or s == "---"


class _Parser:
    def __init__(self, text):
        self.lines = text.split("\n")
        self.i = 0

    # --- navigation -------------------------------------------------
    def _peek(self):
        """Index of the next meaningful line, or None."""
        j = self.i
        while j < len(self.lines) and _is_skippable(self.lines[j]):
            j += 1
        return j if j < len(self.lines) else None

    # --- values -----------------------------------------------------
    def parse_node(self, parent_indent):
        j = self._peek()
        if j is None:
            return None
        line = self.lines[j]
        ind = _indent(line)
        if ind <= parent_indent and not (
            ind == parent_indent and line.lstrip().startswith("- ")
        ):
            return None
        self.i = j
        if line.lstrip().startswith("- ") or line.strip() == "-":
            return self.parse_seq(ind)
        return self.parse_map(ind)

    def parse_seq(self, ind):
        out = []
        while True:
            j = self._peek()
            if j is None:
                break
            line = self.lines[j]
            if _indent(line) != ind or not (
                line[ind:].startswith("- ") or line[ind:].rstrip() == "-"
            ):
                break
            rest = line[ind + 1 :]
            stripped = rest.lstrip(" ")
            offset = ind + 1 + (len(rest) - len(stripped))
            if not stripped:
                self.i = j + 1
                out.append(self.parse_node(ind))
            elif KEY_RE.match(stripped):
                # inline mapping: first key sits at `offset`
                self.lines[j] = " " * offset + stripped
                self.i = j
                out.append(self.parse_map(offset))
            else:
                self.lines[j] = " " * offset + stripped
                self.i = j
                out.append(self.parse_scalar_at(offset, ind))
        return out

    def parse_map(self, ind):
        out = {}
        while True:
            j = self._peek()
            if j is None:
                break
            line = self.lines[j]
            if _indent(line) != ind:
                break
            m = KEY_RE.match(line[ind:])
            if not m:
                if line[ind:].startswith("- "):
                    break
                raise YamlError(f"line {j + 1}: cannot read {line!r}")
            key, rest = m.group(1), (m.group(2) or "")
            rest = self._strip_comment(rest)
            if rest == "":
                self.i = j + 1
                out[key] = self.parse_node(ind)
            else:
                self.i = j
                out[key] = self.parse_value(rest, ind, j, line.index(rest, ind))
        return out

    @staticmethod
    def _strip_comment(rest):
        rest = rest.strip()
        if rest and rest[0] in "'\"|>[":
            return rest
        return re.sub(r"\s+#.*$", "", rest)

    def parse_scalar_at(self, offset, seq_indent):
        line = self.lines[self.i]
        rest = line[offset:]
        return self.parse_value(rest.rstrip(), seq_indent, self.i, offset)

    def parse_value(self, rest, parent_indent, j, col):
        c = rest[0]
        if c in "|>":
            return self._block(rest, parent_indent, j)
        if c in "'\"":
            return self._quoted(j, col)
        if c == "[":
            self.i = j + 1
            return self._flow_list(rest)
        if c == "{":
            raise YamlError(f"line {j + 1}: flow mappings are not supported")
        # plain scalar, may continue on deeper-indented lines
        parts = [rest]
        k = j + 1
        while k < len(self.lines):
            nxt = self.lines[k]
            if not nxt.strip():
                # blank line inside a plain scalar only if more text follows
                look = k
                while look < len(self.lines) and not self.lines[look].strip():
                    look += 1
                if look < len(self.lines) and _indent(self.lines[look]) > parent_indent:
                    parts.extend([""] * (look - k))
                    k = look
                    continue
                break
            if _indent(nxt) > parent_indent and not nxt.lstrip().startswith("#"):
                parts.append(nxt.strip())
                k += 1
            else:
                break
        self.i = k
        return self._scalar(self._fold(parts))

    @staticmethod
    def _fold(parts):
        out = parts[0]
        pending_blank = 0
        for p in parts[1:]:
            if p == "":
                pending_blank += 1
            else:
                out += ("\n" * pending_blank) if pending_blank else " "
                out += p
                pending_blank = 0
        return out

    @staticmethod
    def _scalar(s):
        s = s.strip()
        if s in ("true", "True"):
            return True
        if s in ("false", "False"):
            return False
        if s in ("null", "~", ""):
            return None
        return s

    def _block(self, header, parent_indent, j):
        m = re.match(r"^([|>])([+-]?)(\d?)\s*(#.*)?$", header)
        if not m:
            raise YamlError(f"line {j + 1}: bad block header {header!r}")
        style, chomp = m.group(1), m.group(2)
        k = j + 1
        body = []
        block_indent = None
        while k < len(self.lines):
            ln = self.lines[k]
            if not ln.strip():
                body.append("")
                k += 1
                continue
            ind = _indent(ln)
            if block_indent is None:
                if ind <= parent_indent:
                    break
                block_indent = ind
            if ind < block_indent:
                break
            body.append(ln[block_indent:].rstrip("\r"))
            k += 1
        # trailing blank lines belong to chomping, not the content
        trailing = 0
        while body and body[-1] == "":
            body.pop()
            trailing += 1
        self.i = k
        if style == "|":
            text = "\n".join(body)
        else:
            text = self._fold_block(body)
        if not body:
            return ""
        if chomp == "-":
            return text
        if chomp == "+":
            return text + "\n" * (1 + trailing)
        return text + "\n"

    @staticmethod
    def _fold_block(body):
        out = ""
        for idx, ln in enumerate(body):
            if idx == 0:
                out = ln
            elif ln == "":
                out += "\n"
            elif body[idx - 1] == "":
                out += ln
            else:
                out += " " + ln
        return out

    def _quoted(self, j, col):
        """Read a single or double quoted scalar that may wrap lines."""
        first = self.lines[j][col:]
        quote = first[0]
        buf = first[1:]
        k = j
        raw = []
        while True:
            end = self._find_close(buf, quote)
            if end is not None:
                raw.append(buf[:end])
                break
            raw.append(buf)
            k += 1
            if k >= len(self.lines):
                raise YamlError(f"line {j + 1}: unterminated quoted scalar")
            buf = self.lines[k]
        self.i = k + 1
        parts = [raw[0].rstrip() if len(raw) > 1 else raw[0]]
        for p in raw[1:]:
            parts.append(p.strip())
        text = self._fold(parts) if len(raw) > 1 else raw[0]
        return self._unescape(text, quote)

    @staticmethod
    def _find_close(buf, quote):
        i = 0
        while i < len(buf):
            ch = buf[i]
            if quote == "'":
                if ch == "'":
                    if buf[i + 1 : i + 2] == "'":
                        i += 2
                        continue
                    return i
            else:
                if ch == "\\":
                    i += 2
                    continue
                if ch == '"':
                    return i
            i += 1
        return None

    @staticmethod
    def _unescape(text, quote):
        if quote == "'":
            return text.replace("''", "'")
        out = []
        i = 0
        simple = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "/": "/",
                  "0": "\0", " ": " ", "a": "\a", "b": "\b", "e": "\x1b", "f": "\f", "v": "\v"}
        while i < len(text):
            ch = text[i]
            if ch != "\\":
                out.append(ch)
                i += 1
                continue
            nxt = text[i + 1 : i + 2]
            if nxt in simple:
                out.append(simple[nxt])
                i += 2
            elif nxt in ("x", "u", "U"):
                n = {"x": 2, "u": 4, "U": 8}[nxt]
                out.append(chr(int(text[i + 2 : i + 2 + n], 16)))
                i += 2 + n
            elif nxt == "\n":
                i += 2
            else:
                raise YamlError(f"unknown escape \\{nxt} in {text[:40]!r}")
        return "".join(out)

    def _flow_list(self, rest):
        if not rest.endswith("]"):
            raise YamlError(f"multi-line flow list not supported: {rest!r}")
        inner = rest[1:-1]
        items, cur, quote = [], "", None
        for ch in inner:
            if quote:
                cur += ch
                if ch == quote:
                    quote = None
            elif ch in "'\"":
                quote = ch
                cur += ch
            elif ch == ",":
                items.append(cur)
                cur = ""
            else:
                cur += ch
        if cur.strip():
            items.append(cur)
        out = []
        for it in items:
            it = it.strip()
            if it and it[0] in "'\"":
                out.append(self._unescape(it[1:-1], it[0]))
            else:
                out.append(it)
        return out


def parse_yaml(text):
    p = _Parser(text)
    value = p.parse_node(-1)
    return value


def count_question_ids(text):
    """Independent count of question `id:` entries, by text pattern alone."""
    lines = text.split("\n")
    start = None
    for idx, ln in enumerate(lines):
        if ln.startswith("questions:"):
            start = idx + 1
            break
    if start is None:
        return 0
    seg = []
    for ln in lines[start:]:
        if ln and not ln.startswith((" ", "-", "#")):
            break
        seg.append(ln)
    ind = None
    n = 0
    for ln in seg:
        m = re.match(r"^( *)- id:\s", ln)
        if m:
            if ind is None:
                ind = len(m.group(1))
            if len(m.group(1)) == ind:
                n += 1
    return n


def _norm_question(q):
    choices = []
    for c in q.get("choices") or []:
        choices.append(
            {
                "text": "" if c.get("text") is None else str(c["text"]),
                "correct": c.get("correct") is True,
                "rationale": c.get("rationale"),
            }
        )
    return {
        "id": str(q.get("id")),
        "type": q.get("type"),
        "difficulty": q.get("difficulty"),
        "stem": q.get("stem") if q.get("stem") is not None else "",
        "choices": choices,
        "explanation": q.get("explanation"),
        "passage": q.get("passage"),
        "figure": q.get("figure"),
        "figureSpec": q.get("figureSpec"),
    }


def load_text(text):
    doc = parse_yaml(text)
    if not isinstance(doc, dict):
        raise YamlError("root is not a mapping")
    meta = doc.get("meta") or {}
    exams = meta.get("exams") or []
    if isinstance(exams, str):
        exams = [exams]
    meta = dict(meta)
    meta["exams"] = [str(e) for e in exams]
    passages = {}
    for p in doc.get("passages") or []:
        passages[str(p["id"])] = {"title": p.get("title"), "body": p.get("body", "")}
    questions = [_norm_question(q) for q in (doc.get("questions") or [])]
    return {"meta": meta, "passages": passages, "questions": questions}


def load(path):
    text = Path(path).read_text(encoding="utf-8")
    data = load_text(text)
    expected = count_question_ids(text)
    if len(data["questions"]) != expected:
        raise YamlError(
            f"{path}: parsed {len(data['questions'])} questions but the text "
            f"has {expected} question id entries"
        )
    return data


def file_id(path):
    """subject__topic__slug from a content/questions/<s>/<t>/<slug>.yaml path."""
    rel = Path(path).resolve().relative_to(QUESTIONS)
    parts = list(rel.parts)
    parts[-1] = Path(parts[-1]).stem
    return "__".join(parts)


def rel_repo(path):
    return str(Path(path).resolve().relative_to(REPO))


def all_question_files():
    return sorted(QUESTIONS.rglob("*.yaml"))


def is_cet(meta):
    return bool(CET_EXAMS.intersection(meta["exams"]))


def cet_files():
    out = []
    for p in all_question_files():
        data = load(p)
        if is_cet(data["meta"]):
            out.append(p)
    return out


def resolve_files(names):
    out = []
    for n in names:
        p = Path(n)
        if not p.is_absolute():
            p = (REPO / n) if (REPO / n).exists() else Path.cwd() / n
        out.append(p.resolve())
    return out


def signature(q, passages):
    """What must be byte-identical for a question to count as already solved."""
    passage = passages.get(q["passage"]) if q.get("passage") else None
    return json.dumps(
        {
            "stem": q["stem"],
            "choices": [(c["text"], c["correct"]) for c in q["choices"]],
            "passage": passage["body"] if passage else None,
            "figureSpec": q.get("figureSpec"),
        },
        sort_keys=True,
        ensure_ascii=False,
    )


def cse_signatures():
    """{question id: set(signature)} from the CSE-tagged question files at CSE_COMMIT."""
    names = subprocess.run(
        ["git", "-C", str(REPO), "ls-tree", "-r", "--name-only", CSE_COMMIT, "content/questions"],
        check=True, capture_output=True, text=True,
    ).stdout.split()
    names = [n for n in names if n.endswith(".yaml")]
    proc = subprocess.run(
        ["git", "-C", str(REPO), "cat-file", "--batch"],
        input="".join(f"{CSE_COMMIT}:{n}\n" for n in names).encode(),
        check=True, capture_output=True,
    )
    buf = proc.stdout
    sigs = {}
    pos = 0
    for n in names:
        eol = buf.index(b"\n", pos)
        header = buf[pos:eol].decode().split()
        size = int(header[2])
        body = buf[eol + 1 : eol + 1 + size].decode("utf-8")
        pos = eol + 1 + size + 1
        data = load_text(body)
        # Only the CSE-tagged files were blind-solved on October 26.
        if not any(e.startswith("cse-") for e in data["meta"]["exams"]):
            continue
        for q in data["questions"]:
            sigs.setdefault(q["id"], set()).add(signature(q, data["passages"]))
    return sigs
