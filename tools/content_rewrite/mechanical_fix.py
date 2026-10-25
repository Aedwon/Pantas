"""Mechanical fixer for the CSE lessons (plan task P0.2). Dry run by default.

Fixes, per the lesson style guide and the content checklist:
  B06  em dashes become a colon or a comma, or are flagged needs-review.
  B08  plain numbers in prose become inline math, or are flagged needs-review.
  L20  example and trap heading format (only the cases the audit lists).
  L22  tables, links, code blocks, rules: listed only, never converted.

Nothing is written unless --apply is given with --i-reviewed naming lessons.
Apply changes only non-flagged edits in those lessons and is idempotent.

Usage:
  python3 -I tools/content_rewrite/mechanical_fix.py [--dry-run] --report out.json > diff.txt
  python3 -I tools/content_rewrite/mechanical_fix.py --apply --i-reviewed lesson-a,lesson-b

Python 3.9 standard library only.
"""
import argparse
import collections
import difflib
import hashlib
import json
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_INDEX = Path.home() / ".pantas-audit" / "level4-paste" / "index.json"
AUDIT_L4 = Path.home() / "Documents/Projects/Pantas-wt-content-coverage-audit-r1/docs/content/audit/coverage-r1/level4"
DEFAULT_MECH = AUDIT_L4 / "mechanical"
DEFAULT_TRIAGE = AUDIT_L4 / "paste/results/triage.jsonl"

DASH = "\u2014"
OPEN_QUOTE = "\u201c"
CLOSE_QUOTE = "\u201d"

MONTHS = ("January|February|March|April|May|June|July|August|September|October|November|December|"
          "Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec")
LABEL_WORDS = ("example|examples|gear|gears|row|rows|column|columns|quarter|month|letter|step|tool|figure|fig|table|"
               "part|trap|case|item|question|group|period|level|stage|phase|unit|chapter|page|line|point|day|week|"
               "grade|type|class|quadrant|option|choice|test|set|panel|box|pattern|number|no")
IDENT_KEYWORDS = (r"(?:R\.A\.|RA|P\.D\.|PD|B\.P\.|BP|E\.O\.|EO|Republic Act(?: No\.?)?|Presidential Decree(?: No\.?)?"
                  r"|Batas Pambansa(?: Blg\.?| Bilang)?|Executive Order(?: No\.?)?|Act No\.?|Commonwealth Act(?: No\.?)?"
                  r"|Memorandum Circular(?: No\.?)?|(?i:sections?|secs?\.|articles?|art\.|paragraphs?|par\.))")
IDENT_ITEM = r"(?:No\.?\s*)?\d+(?:\([A-Za-z0-9]+\))*[A-Za-z]?"
IDENT_SEP = r"(?:,?\s*(?:and|or)\s+|,\s*|\s+to\s+|\s+through\s+|\s*[-\u2013&]\s*)"
IDENT_RE = re.compile(r"(?<![A-Za-z.])" + IDENT_KEYWORDS + r"\s*(" + IDENT_ITEM + r"(?:" + IDENT_SEP + IDENT_ITEM + r")*)")

COMMA_STARTERS = re.compile(
    r"^(?:but|and|so|or|yet|which|who|whom|whose|while|because|although|though|since|not|then|instead|even|only|if|"
    r"when|where|whereas|just|still|also|rather|as|until|unless|such as|for example|for instance|including|like|"
    r"especially|often|usually|sometimes|never|always|except)\b")
INTRO_WORDS = {"is", "are", "was", "were", "means", "mean", "equals", "called", "named", "namely", "include",
               "includes", "following", "these", "this", "here", "are:"}
PUA_RE = re.compile("[\ue000-\uf8ff]")
URL_RE = re.compile(r"https?://[^\s)>\]]+")
FENCE_RE = re.compile(r"\s*(```|~~~)")
TABLE_RE = re.compile(r"\s*\|.*\|\s*$")
HR_RE = re.compile(r"\s*(-{3,}|\*{3,}|_{3,})\s*$")
LINK_RE = re.compile(r"\[[^\]]+\]\([^)]+\)")
HEADING_RE = re.compile(r"(#{1,6})\s+(.*\S)\s*$")
LIST_START_RE = re.compile(r"\s*(?:>\s*)*(?:[-*+]|\d+[.)])\s")
PREFIX_RE = re.compile(r"^\s*(?:>\s*)*(?:(?:[-*+]|\d+[.)])\s+)?")
MARKER_RE = re.compile(r"^\s*(?:>\s*)*(?:[-*+]\s+)?(?:\*\*)?(\d+)[.)]\s")
TERMINATOR_RE = re.compile(r"[.!?][\"\u201d)*]*\s+(?=[A-Z0-9\"\u201c*$])")
TOKEN_RE = re.compile(r"\d+(?:[,.:/]\d+)*")
THOUSANDS_RE = re.compile(r"^\d{1,3}(?:,\d{3})+(?:\.\d+)?$")
PLAIN_NUM_RE = re.compile(r"^\d+(?:\.\d+)?$")
TIME_RE = re.compile(r"^(\d{1,2}):(\d{2})$")
UNIT_AFTER_YEAR = re.compile(r"^\s+(?:pesos|peso|meters|metres|kilometers|km|kg|grams|people|students|items|units|dollars|"
                             r"years|days|members|votes|votes)\b")


# ---------------------------------------------------------------- line masks

class State(object):
    def __init__(self):
        self.in_comment = False
        self.quote_open = False


def _find_close(line, start, token):
    i = start
    while i < len(line):
        if line[i] == "\\":
            i += 2
            continue
        if line.startswith(token, i):
            return i
        i += 1
    return -1


def mask_line(line, state):
    """Return (kinds, view, unbalanced). kinds[i] is None for plain prose or a protected kind.

    Kinds: comment, code, math, url, quote. The view replaces protected characters
    (except quote text) with NUL so regexes see only prose.
    """
    n = len(line)
    kinds = [None] * n
    unbalanced = False

    def mark(a, b, kind):
        for k in range(a, min(b, n)):
            kinds[k] = kind

    i = 0
    while i < n:
        if state.in_comment:
            j = line.find("-->", i)
            end = n if j < 0 else j + 3
            mark(i, end, "comment")
            i = end
            if j >= 0:
                state.in_comment = False
            continue
        c = line[i]
        if line.startswith("<!--", i):
            j = line.find("-->", i + 4)
            if j < 0:
                mark(i, n, "comment")
                state.in_comment = True
                i = n
            else:
                mark(i, j + 3, "comment")
                i = j + 3
            continue
        if c == "\\" and i + 1 < n:
            mark(i, i + 2, "quote" if state.quote_open else None)
            i += 2
            continue
        if c == "`":
            j = line.find("`", i + 1)
            if j > 0:
                mark(i, j + 1, "code")
                i = j + 1
                continue
        if line.startswith("$$", i):
            j = _find_close(line, i + 2, "$$")
            if j < 0:
                unbalanced = True
                mark(i, n, "math")
                break
            mark(i, j + 2, "math")
            i = j + 2
            continue
        if c == "$":
            j = _find_close(line, i + 1, "$")
            if j < 0:
                unbalanced = True
                mark(i, n, "math")
                break
            mark(i, j + 1, "math")
            i = j + 1
            continue
        m = URL_RE.match(line, i)
        if m:
            mark(m.start(), m.end(), "url")
            i = m.end()
            continue
        if c == "]" and line.startswith("](", i):
            j = line.find(")", i)
            if j > 0:
                mark(i + 2, j, "url")
                i = j
                continue
        if c == '"':
            state.quote_open = not state.quote_open
            kinds[i] = "quote"
        elif c == OPEN_QUOTE:
            state.quote_open = True
            kinds[i] = "quote"
        elif c == CLOSE_QUOTE:
            state.quote_open = False
            kinds[i] = "quote"
        else:
            kinds[i] = "quote" if state.quote_open else None
        i += 1
    view = "".join("\x00" if (kinds[k] not in (None, "quote")) else line[k] for k in range(n))
    return kinds, view, unbalanced


# ---------------------------------------------------------------- text helpers

def _words(text):
    return re.findall(r"[A-Za-z0-9$\\'\u2019-]+", text.replace("*", " "))


def _sentence_start(view, prefix_end, pos):
    start = prefix_end
    for m in TERMINATOR_RE.finditer(view, prefix_end, pos):
        start = m.end()
    return start


def _sentence_end(view, pos):
    m = TERMINATOR_RE.search(view, pos)
    return m.start() + 1 if m else len(view)


# ---------------------------------------------------------------- B06

def _dash_choice(view, prefix_end, d):
    """Return (kind, reason). kind is 'colon', 'comma' or 'review'."""
    sent_start = _sentence_start(view, prefix_end, d)
    pre = view[sent_start:d].rstrip()
    post = view[d + 1:].lstrip()
    pre_core = pre.rstrip("*")
    if not pre_core.strip("\x00 ") or not post.strip():
        return "review", "dash at the start or end of the text"
    if pre_core[-1] in ',;:.!?"\u201d)\'':
        return "review", "dash follows punctuation or a quotation"
    if post[0] in ',.;:)!?':
        return "review", "punctuation follows the dash"
    post_plain = post.lstrip("*").lstrip()
    if COMMA_STARTERS.match(post_plain):
        return "comma", ""
    words = _words(pre_core)
    if words and words[-1].lower() in INTRO_WORDS:
        return "colon", ""
    if len(words) <= 4 and sent_start == prefix_end:
        return "colon", ""
    return "review", "not clear whether the dash introduces an explanation or a side remark"


def _dash_edits(line, kinds, view, unbalanced, prefix_end):
    """Return (edits, reviews). An edit is (start, end, replacement, note)."""
    positions = [i for i, ch in enumerate(line) if ch == DASH]
    edits, reviews = [], []
    if not positions:
        return edits, reviews

    def review(p, reason, suggestion=None):
        item = {"rule": "B06", "col": p, "reason": reason}
        if suggestion:
            item["suggestion"] = suggestion
        reviews.append(item)

    plain = []
    for p in positions:
        if kinds[p] is not None:
            review(p, "em dash inside %s" % kinds[p])
        elif unbalanced:
            review(p, "line has an unmatched dollar sign")
        else:
            plain.append(p)
    used = set()
    k = 0
    while k + 1 < len(plain):
        d1, d2 = plain[k], plain[k + 1]
        between = view[d1 + 1:d2]
        sent_start = _sentence_start(view, prefix_end, d1)
        pre_words = _words(view[sent_start:d1])
        inner_words = _words(between)
        post = view[d2 + 1:].lstrip()
        if (not TERMINATOR_RE.search(between + " ") and 1 <= len(inner_words) <= 12 and len(pre_words) >= 2
                and post and post[0] not in ',.;:)!?'):
            edits.append(_span_edit(line, d1, ", "))
            edits.append(_span_edit(line, d2, ", "))
            used.update([d1, d2])
            k += 2
        else:
            k += 1
    for p in plain:
        if p in used:
            continue
        kind, reason = _dash_choice(view, prefix_end, p)
        if kind == "review":
            review(p, reason)
        else:
            edits.append(_span_edit(line, p, ": " if kind == "colon" else ", "))
    return edits, reviews


def _span_edit(line, p, repl):
    a = p
    while a > 0 and line[a - 1] in " \t":
        a -= 1
    b = p + 1
    while b < len(line) and line[b] in " \t":
        b += 1
    return (a, b, repl, "B06")


# ---------------------------------------------------------------- B08

def _identifier_spans(view):
    spans = set()
    for m in IDENT_RE.finditer(view):
        for t in TOKEN_RE.finditer(view, m.start(1), m.end(1)):
            spans.add(t.start())
    return spans


def _classify_number(view, kinds, m, ident_starts):
    """Return ('fix', replacement_span_end, replacement) | ('skip', reason) | ('review', reason)."""
    s, e = m.start(), m.end()
    tok = m.group(0)
    before, after = view[:s], view[e:]
    if kinds[s] == "quote":
        return ("skip", "quoted passage")
    if before.endswith("#"):
        return ("skip", "hash reference")
    if MARKER_RE.match(view) and MARKER_RE.match(view).start(1) == s:
        return ("skip", "list marker")
    if re.search(r"(?:\u20b1|Php|PHP|PhP)\s?$", before) or re.search(r"(?<![A-Za-z])P$", before):
        return ("review", "currency amount")
    if before.endswith("\x00") or after.startswith("\x00"):
        return ("review", "number touches math, code or a comment")
    if before[-1:].isalpha() and not before.endswith("-"):
        return ("skip", "letters and digits together")
    if s in ident_starts:
        return ("skip", "statute or section identifier")
    if before.endswith("-") and before[-2:-1].isalpha():
        if before.endswith("-to-"):
            pass
        else:
            return ("review", "number in a hyphenated name")
    if before.endswith("-") and not before[-2:-1].isalnum():
        return ("review", "possible minus sign or range")
    if before[-1:].isdigit():
        return ("review", "digits split by a sign")
    if re.match(r"[Dd]\b", after) and tok in ("2", "3"):
        return ("skip", "dimension term (2D, 3D)")
    if after[:1].isalpha():
        if re.match(r"(?:st|nd|rd|th)\b", after):
            return ("review", "ordinal suffix on a number")
        return ("review", "digits fused to letters")
    if re.search(r"(?:%s)\.?\s+$" % MONTHS, before) or re.match(r"(?:st|nd|rd|th)?\s+(?:of\s+)?(?:%s)\b" % MONTHS, after):
        return ("review", "date")
    tm = TIME_RE.match(tok)
    if tm and int(tm.group(1)) <= 24 and int(tm.group(2)) < 60:
        return ("skip", "time")
    if re.match(r"\s?(?:a\.m\.|p\.m\.|am\b|pm\b|AM\b|PM\b|o'clock)", after):
        return ("skip", "time")
    if re.search(r"[:/]", tok):
        return ("review", "ratio, fraction or date written with a separator")
    if re.search(r"(?<![A-Za-z])(?:%s)\s+$" % LABEL_WORDS, before, re.I):
        return ("review", "label number (for example Example 1, Gear 2)")
    if before.endswith("(") and after.startswith(")"):
        return ("review", "enumerator in parentheses")
    if re.search(r"[+\u00b1\u00d7\u00f7=<>]\s*$", before) or re.match(r"\s*[+\u00b1\u00d7\u00f7=<>]", after):
        return ("review", "arithmetic written in prose")
    if re.search(r"\s[-\u2212\u2013]\s*$", before) or re.match(r"\s[-\u2212\u2013]\s", after):
        return ("review", "arithmetic written in prose")
    if re.match(r"\s?[-\u2013\u2212]\d", after):
        return ("review", "number range")
    if re.match(r"\s*\u00b0", after):
        return ("review", "degree sign needs unit notation")
    if re.match(r"\d{4}$", tok) and 1000 <= int(tok) <= 2099 and not before.endswith(","):
        if UNIT_AFTER_YEAR.match(after):
            return ("review", "four-digit number that may be a quantity")
        return ("skip", "year")
    if "," in tok and not THOUSANDS_RE.match(tok):
        return ("review", "digits joined by commas")
    if tok.count(".") > 1:
        return ("review", "dotted number")
    if not (THOUSANDS_RE.match(tok) or PLAIN_NUM_RE.match(tok)):
        return ("review", "unusual number form")
    if after.startswith("%"):
        return ("fix", e + 1, "$%s\\%%$" % tok)
    return ("fix", e, "$%s$" % tok)


def _number_edits(line, kinds, view, prefix_end):
    edits, reviews, skips = [], [], []
    ident = _identifier_spans(view)
    consumed = set()
    for m in TOKEN_RE.finditer(view):
        if m.start() in consumed:
            continue
        if any(kinds[k] not in (None, "quote") for k in range(m.start(), m.end())):
            continue
        res = _classify_number(view, kinds, m, ident)
        if res[0] == "fix":
            edits.append((m.start(), res[1], res[2], "B08"))
        elif res[0] == "skip":
            skips.append((m.start(), res[1]))
        else:
            reviews.append({"rule": "B08", "col": m.start(), "reason": res[1], "token": m.group(0)})
            if res[1] in ("number range", "possible minus sign or range"):
                nxt = TOKEN_RE.search(view, m.end() + 1)
                if nxt and nxt.start() - m.end() <= 2:
                    consumed.add(nxt.start())
    return edits, reviews, skips


# ---------------------------------------------------------------- L20

def _heading_fixes(lines, first_body, only_lines):
    """Return (edits, reviews) for example and trap headings.

    edits: {line_index: new_line}. only_lines restricts to line numbers (1-based) the audit lists.
    """
    edits, reviews = {}, []
    section = None
    expected = 0
    for idx in range(first_body, len(lines)):
        line = lines[idx]
        m = HEADING_RE.match(line)
        if not m:
            continue
        number = idx + 1
        level, text = len(m.group(1)), m.group(2)
        if level == 2:
            section, expected = text, 0
            continue
        if level != 3 or section not in ("Examples", "Traps to Watch For"):
            continue
        expected += 1
        if only_lines is not None and number not in only_lines:
            continue
        good = re.match(r"#(\d+): \S", text)
        if good:
            if int(good.group(1)) != expected:
                new = "### #%d: %s" % (expected, text[good.end(1) + 2:].lstrip())
                edits[idx] = new
            continue
        variant = re.match(r"#(\d+)(?:[.):]|\s+-)?\s+(\S.*)$", text)
        if variant and int(variant.group(1)) == expected:
            edits[idx] = "### #%d: %s" % (expected, variant.group(2))
        else:
            reviews.append({"rule": "L20", "line": number, "text": line.strip()[:200],
                            "reason": "heading does not use the form '### #N: Title'; expected #%d" % expected,
                            "occurrences": 1})
    return edits, reviews


def _unwarned_traps(lines, first_body):
    """Mirror the audit's L20 check: traps with no one-line blockquote warning (not automated)."""
    out = []
    section = None
    open_trap = None
    for idx in range(first_body, len(lines)):
        line = lines[idx]
        m = HEADING_RE.match(line)
        if m and len(m.group(1)) == 2:
            if open_trap and not open_trap[2]:
                out.append(open_trap)
            open_trap = None
            section = m.group(2)
        elif m and len(m.group(1)) == 3 and section in ("Examples", "Traps to Watch For"):
            if open_trap and not open_trap[2]:
                out.append(open_trap)
            open_trap = [idx + 1, line.strip()[:200], False] if section == "Traps to Watch For" else None
        elif open_trap and line.lstrip().startswith(">"):
            open_trap[2] = True
    if open_trap and not open_trap[2]:
        out.append(open_trap)
    return [{"line": a, "text": b} for a, b, _ in out]


# ---------------------------------------------------------------- whole lesson

def analyze(text, only_l20_lines=None):
    """Return a result dict. result['new_text'] is the text with all non-flagged edits applied."""
    lines = text.split("\n")
    result = {"changes": [], "review": [], "skipped": collections.Counter(), "l22": [], "l20_unautomated": [],
              "counts": collections.Counter(), "events": collections.defaultdict(list), "new_text": text,
              "error": None}
    if "\r" in text:
        result["error"] = "file has carriage returns; skipped"
        return result
    if not lines or lines[0].strip() != "---":
        result["error"] = "no frontmatter; skipped"
        return result
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        result["error"] = "frontmatter not closed; skipped"
        return result

    for i in range(1, end):
        if DASH in lines[i]:
            result["review"].append({"rule": "B06", "line": i + 1, "text": lines[i].strip()[:200],
                                     "reason": "em dash in frontmatter", "occurrences": 1})
            result["events"][i + 1].append(("review", "B06", "frontmatter"))

    result["other"] = []
    for i, ln in enumerate(lines):
        if PUA_RE.search(ln):
            result["other"].append({"line": i + 1, "kind": "stray private-use characters (citation marker?)",
                                    "text": ln.strip()[-120:]})
    new_lines = list(lines)
    state = State()
    in_fence = False
    in_display = False
    table_block = None

    def close_table():
        nonlocal table_block
        if table_block:
            result["l22"].append(table_block)
            table_block = None

    for idx in range(end + 1, len(lines)):
        line = lines[idx]
        number = idx + 1
        if FENCE_RE.match(line):
            close_table()
            in_fence = not in_fence
            result["l22"].append({"kind": "code block", "start": number, "end": number, "text": line.strip()[:120]})
            if DASH in line:
                _add_review(result, number, line, {"rule": "B06", "col": line.index(DASH),
                                                   "reason": "em dash in a code block"})
            continue
        if in_fence:
            if DASH in line:
                _add_review(result, number, line, {"rule": "B06", "col": line.index(DASH),
                                                   "reason": "em dash in a code block"})
            result["skipped"]["code block"] += 1
            continue
        stripped = line.strip()
        if not state.in_comment and stripped == "$$":
            in_display = not in_display
            continue
        if in_display:
            if DASH in line:
                _add_review(result, number, line, {"rule": "B06", "col": line.index(DASH),
                                                   "reason": "em dash inside display math"})
            continue
        if not stripped:
            state.quote_open = False
            close_table()
            continue

        is_heading = bool(HEADING_RE.match(line)) and not state.in_comment
        is_table = bool(TABLE_RE.match(line)) and not state.in_comment
        if is_heading or is_table or LIST_START_RE.match(line):
            state.quote_open = False
        kinds, view, unbalanced = mask_line(line, state)

        if is_table:
            if table_block is None:
                table_block = {"kind": "table", "start": number, "end": number, "rows": 0, "text": line.strip()[:120]}
            table_block["end"] = number
            table_block["rows"] += 1
        else:
            close_table()
        if LINK_RE.search(view):
            result["l22"].append({"kind": "link", "start": number, "end": number, "text": line.strip()[:120]})
        if HR_RE.match(line) and not state.in_comment:
            result["l22"].append({"kind": "horizontal rule", "start": number, "end": number, "text": stripped})

        prefix_end = PREFIX_RE.match(line).end()
        edits, reviews = [], []
        if is_heading or is_table:
            if DASH in line:
                for p in [i for i, ch in enumerate(line) if ch == DASH]:
                    reviews.append({"rule": "B06", "col": p,
                                    "reason": "em dash in a %s" % ("heading" if is_heading else "table row")})
            if re.search(r"\d", line):
                reason = "heading" if is_heading else "table row"
                result["skipped"][reason] += 1
                result["events"][number].append(("skip", "B08", reason))
        else:
            d_edits, d_reviews = _dash_edits(line, kinds, view, unbalanced, prefix_end)
            edits += d_edits
            reviews += d_reviews
            if unbalanced:
                if re.search(r"\d", line):
                    reviews.append({"rule": "B08", "col": 0, "reason": "line has an unmatched dollar sign"})
            else:
                n_edits, n_reviews, n_skips = _number_edits(line, kinds, view, prefix_end)
                if any(r["reason"] == "arithmetic written in prose" for r in n_reviews):
                    for a, b, repl, rule in n_edits:
                        reviews.append({"rule": "B08", "col": a, "token": line[a:b],
                                        "reason": "number on a line with arithmetic written in prose"})
                    n_edits = []
                edits += n_edits
                reviews += n_reviews
                for col, reason in n_skips:
                    result["skipped"][reason] += 1
                    result["events"][number].append(("skip", "B08", reason))
        for r in reviews:
            _add_review(result, number, line, r)
        if edits:
            edits.sort(key=lambda e: e[0], reverse=True)
            new = line
            for a, b, repl, rule in edits:
                new = new[:a] + repl + new[b:]
                result["counts"][rule] += 1
                result["events"][number].append(("fix", rule, repl.strip()))
            new_lines[idx] = new
            result["changes"].append({"line": number, "rules": sorted(set(e[3] for e in edits)),
                                      "before": line, "after": new})

    # L20 headings (after B06/B08, which skip headings)
    h_edits, h_reviews = _heading_fixes(lines, end + 1, only_l20_lines)
    for idx, new in h_edits.items():
        if new != lines[idx]:
            result["counts"]["L20"] += 1
            result["events"][idx + 1].append(("fix", "L20", new))
            result["changes"].append({"line": idx + 1, "rules": ["L20"], "before": lines[idx], "after": new})
            new_lines[idx] = new
    for r in h_reviews:
        result["review"].append(r)
        result["counts"]["review:L20"] += 1
    result["l20_unautomated"] = _unwarned_traps(lines, end + 1)
    close_table()
    result["changes"].sort(key=lambda c: c["line"])
    result["new_text"] = "\n".join(new_lines)
    return result


def _add_review(result, number, line, r):
    """Add a needs-review item; items on the same line with the same reason merge."""
    result["counts"]["occurrences:" + r["rule"]] += 1
    for item in reversed(result["review"]):
        if item["line"] != number:
            break
        if item["rule"] == r["rule"] and item["reason"] == r["reason"]:
            item["occurrences"] += 1
            if "token" in r:
                item.setdefault("tokens", []).append(r["token"])
            result["events"][number].append(("review", r["rule"], r["reason"]))
            return
    item = {"rule": r["rule"], "line": number, "text": line.strip()[:200], "reason": r["reason"], "occurrences": 1}
    if "token" in r:
        item["tokens"] = [r["token"]]
    result["review"].append(item)
    result["counts"]["review:" + r["rule"]] += 1
    result["events"][number].append(("review", r["rule"], r["reason"]))


# ---------------------------------------------------------------- CLI plumbing

def sha256_text(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def read_lesson(path):
    """Read without newline translation so a carriage return is seen, not hidden."""
    with open(str(path), encoding="utf-8", newline="") as fh:
        return fh.read()


def load_scope(index_path, root):
    index = json.loads(Path(index_path).read_text(encoding="utf-8"))
    scope = []
    for entry in index.values():
        scope.append({"lesson_id": entry["lesson_id"], "source": entry["source"],
                      "path": Path(root) / entry["source"], "index_sha": entry.get("lesson_sha256")})
    scope.sort(key=lambda s: s["lesson_id"])
    return scope


def _mech_lines(mech_dir, lesson_id):
    f = Path(mech_dir) / ("%s.json" % lesson_id) if mech_dir else None
    if not f or not f.exists():
        return None
    return json.loads(f.read_text(encoding="utf-8"))["findings"]


def _l20_listed(findings):
    if findings is None:
        return None
    return set(f["line"] for f in findings if f["rule"] == "L20" and "heading" in f["problem"])


def crosscheck_mechanical(res, findings):
    """Compare this tool's view with the audit's mechanical results for one lesson."""
    if findings is None:
        return None
    mine = {"B06": set(), "table": set(), "B08": set(), "trap": set()}
    for ln, evs in res["events"].items():
        for kind, rule, reason in evs:
            if rule == "B06":
                mine["B06"].add(ln)
            if rule == "B08":
                mine["B08"].add(ln)
    for r in res["review"]:
        if r["rule"] == "B06":
            mine["B06"].add(r["line"])
    for block in res["l22"]:
        if block["kind"] == "table":
            mine["table"].update(range(block["start"], block["end"] + 1))
    mine["trap"] = set(t["line"] for t in res["l20_unautomated"])
    theirs = {"B06": set(), "table": set(), "B08": set(), "trap": set()}
    for f in findings:
        if f["rule"] == "B06":
            theirs["B06"].add(f["line"])
        elif f["rule"] == "L22" and f["problem"] == "table":
            theirs["table"].add(f["line"])
        elif f["rule"] == "B08" and f["candidate"]:
            theirs["B08"].add(f["line"])
        elif f["rule"] == "L20" and "blockquote" in f["problem"]:
            theirs["trap"].add(f["line"])
    out = {}
    for key in mine:
        missing = sorted(theirs[key] - mine[key])
        extra = sorted(mine[key] - theirs[key]) if key != "B08" else []
        if missing or extra:
            out[key] = {"audit_only_lines": missing, "tool_only_lines": extra}
    return out


def crosscheck_triage(results, triage_path, scope_ids):
    """For each triage row on B06 or B08, record what this tool did on the row's line."""
    rows = []
    with open(str(triage_path), encoding="utf-8") as fh:
        for raw in fh:
            raw = raw.strip()
            if raw:
                row = json.loads(raw)
                if row["lesson"] in scope_ids and row["rule"] in ("B06", "B08"):
                    rows.append(row)
    summary = collections.defaultdict(collections.Counter)
    unmatched = collections.Counter()
    for row in rows:
        res = results.get(row["lesson"])
        if res is None:
            continue
        head = row["quote"].split("\n")[0].strip()[:40]
        outcome = None
        for ln, line in res["lines"].items():
            if head and head in line:
                evs = [e for e in res["events"].get(ln, []) if e[1] == row["rule"]]
                if evs:
                    kinds = sorted(set(e[0] if e[0] != "skip" else "skip:" + e[2] for e in evs))
                    outcome = "+".join(kinds)
                    break
                outcome = outcome or "no-action"
        if outcome is None:
            unmatched[row["verdict"]] += 1
            outcome = "line-not-found"
        summary["%s/%s" % (row["rule"], row["verdict"])][outcome] += 1
    return {k: dict(v) for k, v in sorted(summary.items())}


def run(args):
    scope = load_scope(args.index, args.root)
    wanted = None
    if args.lessons:
        wanted = set(x.strip() for x in args.lessons.split(",") if x.strip())
        scope = [s for s in scope if s["lesson_id"] in wanted]
    results = {}
    report = {"tool": "mechanical_fix.py", "mode": "apply" if args.apply else "dry-run",
              "policy_commit": args.policy_commit, "lesson_count": len(scope), "lessons": {}, "totals": {}}
    totals = collections.Counter()
    skipped_total = collections.Counter()
    l22_total = collections.Counter()
    cross = {}
    out = sys.stdout
    clean = 0
    for s in scope:
        text = read_lesson(s["path"])
        listed = _l20_listed(_mech_lines(args.mechanical_dir, s["lesson_id"])) if args.mechanical_dir else None
        res = analyze(text, listed)
        res["lines"] = {i + 1: l for i, l in enumerate(text.split("\n"))}
        results[s["lesson_id"]] = res
        entry = {"path": s["source"], "sha256": sha256_text(text), "index_sha_match": sha256_text(text) == s["index_sha"],
                 "error": res["error"],
                 "proposed": {k: v for k, v in sorted(res["counts"].items())
                              if not k.startswith(("review:", "occurrences:"))},
                 "needs_review_count": len(res["review"]),
                 "skipped": dict(res["skipped"]),
                 "changes": res["changes"], "needs_review": res["review"],
                 "l22": res["l22"], "l20_unautomated": res["l20_unautomated"],
                 "other_findings": res.get("other", [])}
        report["lessons"][s["lesson_id"]] = entry
        for k, v in entry["proposed"].items():
            if not k.startswith("occurrences:"):
                totals["proposed:" + k] += v
        for r in res["review"]:
            totals["needs-review items:" + r["rule"]] += 1
            totals["needs-review occurrences:" + r["rule"]] += r.get("occurrences", 1)
        skipped_total.update(res["skipped"])
        for b in res["l22"]:
            l22_total[b["kind"]] += (b["rows"] if b["kind"] == "table" else 1)
            l22_total[b["kind"] + " blocks"] += 1
        totals["l20_unautomated"] += len(res["l20_unautomated"])
        cc = crosscheck_mechanical(res, _mech_lines(args.mechanical_dir, s["lesson_id"])) if args.mechanical_dir else None
        if cc:
            cross[s["lesson_id"]] = cc
        if res["error"]:
            out.write("== %s: %s\n" % (s["lesson_id"], res["error"]))
            continue
        if not (res["changes"] or res["review"] or res["l22"] or res["l20_unautomated"] or res.get("other")):
            clean += 1
            continue
        out.write("== %s (%s)\n" % (s["lesson_id"], s["source"]))
        if res["new_text"] != text:
            diff = difflib.unified_diff(text.split("\n"), res["new_text"].split("\n"),
                                        fromfile="a/" + s["source"], tofile="b/" + s["source"], lineterm="", n=0)
            out.write("\n".join(diff) + "\n")
        else:
            out.write("(no proposed changes)\n")
        if res["review"]:
            out.write("needs-review (%d):\n" % len(res["review"]))
            for r in res["review"]:
                out.write("  %s line %d: %s | %s\n" % (r["rule"], r["line"], r["reason"], r["text"][:140]))
        if res["l20_unautomated"]:
            out.write("L20 not automated (trap needs an authored warning): lines %s\n" % ", ".join(
                str(t["line"]) for t in res["l20_unautomated"]))
        if res.get("other"):
            out.write("other findings: %s\n" % "; ".join(
                "line %d %s" % (o["line"], o["kind"]) for o in res["other"]))
        if res["l22"]:
            out.write("L22 listed (not converted): %s\n" % ", ".join(
                "%s %d-%d" % (b["kind"], b["start"], b["end"]) for b in res["l22"]))
        out.write("\n")
    report["totals"] = {"by_rule": dict(sorted(totals.items())), "skipped": dict(sorted(skipped_total.items())),
                        "l22": dict(sorted(l22_total.items())), "lessons_with_nothing": clean}
    report["crosscheck_mechanical"] = cross
    if args.triage and Path(args.triage).exists():
        report["crosscheck_triage"] = crosscheck_triage(results, args.triage, set(s["lesson_id"] for s in scope))
    for res in results.values():
        res.pop("lines", None)
    if args.report:
        Path(args.report).parent.mkdir(parents=True, exist_ok=True)
        with open(args.report, "w", encoding="utf-8") as fh:
            json.dump(report, fh, indent=1, ensure_ascii=True)
            fh.write("\n")
    sys.stderr.write("lessons: %d, nothing to do: %d\n" % (len(scope), clean))
    sys.stderr.write("totals: %s\n" % json.dumps(report["totals"]["by_rule"], sort_keys=True))
    if args.apply:
        return apply_changes(scope, results, args)
    return 0


def apply_changes(scope, results, args):
    named = [x.strip() for x in (args.i_reviewed or "").split(",") if x.strip()]
    ids = set(s["lesson_id"] for s in scope)
    unknown = [x for x in named if x not in ids]
    if not named or unknown:
        sys.stderr.write("refused: --apply needs --i-reviewed with in-scope lesson ids%s\n"
                         % ((" (unknown: %s)" % ", ".join(unknown)) if unknown else ""))
        return 2
    written = 0
    for s in scope:
        if s["lesson_id"] not in named:
            continue
        res = results[s["lesson_id"]]
        if res["error"]:
            sys.stderr.write("skipped %s: %s\n" % (s["lesson_id"], res["error"]))
            continue
        old = read_lesson(s["path"])
        if res["new_text"] == old:
            continue
        tmp = s["path"].with_name(s["path"].name + ".tmp")
        tmp.write_bytes(res["new_text"].encode("utf-8"))
        os.replace(str(tmp), str(s["path"]))
        written += 1
    sys.stderr.write("applied non-flagged changes to %d lesson file(s)\n" % written)
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--dry-run", action="store_true", help="default; print diffs and write the report")
    p.add_argument("--apply", action="store_true", help="write non-flagged changes; needs --i-reviewed")
    p.add_argument("--i-reviewed", default="", help="comma-separated lesson ids the lead reviewed")
    p.add_argument("--report", help="path for the JSON summary")
    p.add_argument("--index", default=str(DEFAULT_INDEX))
    p.add_argument("--root", default=str(REPO_ROOT), help="worktree root that holds the lesson sources")
    p.add_argument("--lessons", default="", help="limit to these lesson ids")
    p.add_argument("--mechanical-dir", default=str(DEFAULT_MECH) if DEFAULT_MECH.exists() else "")
    p.add_argument("--triage", default=str(DEFAULT_TRIAGE) if DEFAULT_TRIAGE.exists() else "")
    p.add_argument("--policy-commit", default="")
    args = p.parse_args(argv)
    if args.apply and args.dry_run:
        sys.stderr.write("choose --dry-run or --apply, not both\n")
        return 2
    if args.apply and not args.i_reviewed:
        sys.stderr.write("refused: --apply needs --i-reviewed <lesson-id,...>\n")
        return 2
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
