"""Script checks for the rules no chat judges.

A finding is definite when the text itself settles it (an em dash, a table).
It is a candidate when the pattern needs a reader to confirm it ("marks" can
be a score or a punctuation mark). Candidates are reported apart from
definite findings and are never counted as failures by this script.

Vendored from the Level 4 audit (docs/content/audit/coverage-r1/level4/mechanical.py on
docs/content-coverage-audit-r1 at ecbfa88b). Only the command line entry point was removed;
see SOURCE.txt.
"""
import json
import re

import l4lib

FRONTMATTER_KEYS = ["_id", "title", "summary", "subject", "topic", "estimatedMinutes", "isActive"]
QUOTED_KEYS = ("_id", "title", "summary", "subject", "topic")
BASE_TITLES = ["Core Concept", "Mnemonics & Memory Aids", "Examples", "Speed Tricks & Shortcuts", "Traps to Watch For"]
SUBJECT_TITLES = {
    "science": ["Exam Strategies", "Key Terms"],
    "language-proficiency": ["Common Confusions", "Usage Notes"],
    "reading-comprehension": ["Reading Strategies"],
}
BRITISH = ("colour", "practise", "behaviour", "analyse", "grey", "centre", "organise", "favour", "honour",
           "labour", "neighbour", "metre", "litre", "defence", "licence", "travelled", "modelling", "programme",
           "catalogue", "recognise", "realise", "emphasise", "summarise", "memorise", "minimise", "maximise")
BANNED_WORDS = ("FSRS", "stability", "retention", "retrievability", "algorithm")
ACRONYMS = set("SALN VSEPR IUPAC PAGASA GEMDAS PEMDAS UPCAT NDRRMC NIPAS FOIL DENR COMELEC NASA DOST SOAP COOH "
               "DCAT ACET USTET PUPCET BODMAS MDAS HTML YYYY ABCD ABAB".split())
ROMAN = re.compile(r"^[IVXLCDM]+$")


def _finding(rule, line, text, problem, candidate=False):
    return {"rule": rule, "line": line, "text": text.strip()[:200], "problem": problem, "candidate": candidate}


def _mask(line, pattern):
    return re.sub(pattern, lambda match: " " * len(match.group(0)), line)


def _prose_lines(parsed):
    """Body lines with comments and math blanked, so prose checks see only prose."""
    lines = parsed["body"].split("\n")
    out = []
    in_display = False
    in_comment = False
    for offset, line in enumerate(lines):
        text = line
        if in_comment:
            if "-->" in text:
                text = " " * (text.index("-->") + 3) + text[text.index("-->") + 3:]
                in_comment = False
            else:
                text = ""
        text = _mask(text, r"<!--.*?-->")
        if "<!--" in text:
            text = text[:text.index("<!--")]
            in_comment = True
        if text.strip().startswith("$$") and text.strip().endswith("$$") and len(text.strip()) > 3:
            text = ""
        elif text.strip() == "$$":
            in_display = not in_display
            text = ""
        elif in_display:
            text = ""
        text = _mask(text, r"\$\$.*?\$\$")
        text = _mask(text, r"\$[^$\n]+\$")
        out.append((parsed["body_first_line"] + offset, line, text))
    return out


def top_level_fracs(math):
    """Positions of \\frac that are not inside another fraction's argument."""
    hits = []
    stack = []
    pending = [0]
    i = 0
    while i < len(math):
        if math.startswith("\\dfrac", i) or math.startswith("\\tfrac", i):
            pending[-1] = 2
            i += 6
        elif math.startswith("\\frac", i):
            if not any(stack):
                hits.append(i)
            pending[-1] = 2
            i += 5
        elif math[i] == "{":
            is_argument = pending[-1] > 0
            if is_argument:
                pending[-1] -= 1
            stack.append(is_argument)
            pending.append(0)
            i += 1
        elif math[i] == "}":
            if stack:
                stack.pop()
                pending.pop()
            i += 1
        else:
            i += 1
    return hits


def _check_text(parsed):
    findings = []
    body_lines = parsed["body"].split("\n")
    for offset, line in enumerate(body_lines):
        number = parsed["body_first_line"] + offset
        if "—" in line:
            findings.append(_finding("B06", number, line, "em dash"))
        if "\\(" in line or "\\[" in line:
            findings.append(_finding("B08", number, line, "math written with \\( or \\[ instead of dollar signs"))
        for math in re.findall(r"\$\$.*?\$\$|\$[^$\n]+\$", line) or ([line] if "\\frac" in line else []):
            if top_level_fracs(math):
                findings.append(_finding("B08", number, line, "\\frac at top level; use \\dfrac"))
                break
    for number, line, prose in _prose_lines(parsed):
        if line.lstrip().startswith("#"):
            continue
        lowered = prose.lower()
        for word in BRITISH:
            if re.search(r"\b%s\w*\b" % word, lowered):
                findings.append(_finding("B07", number, line, "possible British spelling: %s" % word, True))
        if re.search(r"\bmarks?\b", lowered):
            findings.append(_finding("B09", number, line, "\"mark\" may be used for a score", True))
        if re.search(r"\bcards?\b", lowered):
            findings.append(_finding("B09", number, line, "\"card\" may be used for a question", True))
        for word in BANNED_WORDS:
            if re.search(r"\b%s\b" % word.lower(), lowered):
                findings.append(_finding("B10", number, line, "word reserved from student text: %s" % word, True))
        for word in re.findall(r"\b[A-Z]{4,}\b", prose):
            if word not in ACRONYMS and not ROMAN.match(word):
                findings.append(_finding("L13", number, line, "possible all-capitals emphasis: %s" % word, True))
        stripped = re.sub(r"^\s*(\d+\.|[-*>])\s+", "", prose)
        if re.search(r"(?<![\w#])\d+(?![\w])", stripped):
            findings.append(_finding("B08", number, line, "number in prose outside inline math", True))
    return findings


def _check_formatting(parsed):
    findings = []
    in_fence = False
    for number, line, prose in _prose_lines(parsed):
        if re.match(r"\s*(```|~~~)", line):
            findings.append(_finding("L22", number, line, "code block"))
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if re.match(r"\s*\|.*\|\s*$", line):
            findings.append(_finding("L22", number, line, "table"))
        if re.search(r"\[[^\]]+\]\([^)]+\)", prose):
            findings.append(_finding("L22", number, line, "link"))
        if re.match(r"\s*(-{3,}|\*{3,}|_{3,})\s*$", line):
            findings.append(_finding("L22", number, line, "horizontal rule"))
    return findings


def _check_sections(parsed, subject):
    findings = []
    allowed = BASE_TITLES + SUBJECT_TITLES.get(subject, [])
    section = None
    expected = 0
    trap_open = None
    lines = parsed["body"].split("\n")

    def close_trap():
        if trap_open and not trap_open[2]:
            findings.append(_finding("L20", trap_open[0], trap_open[1], "trap has no one-line blockquote warning"))

    for offset, line in enumerate(lines):
        number = parsed["body_first_line"] + offset
        heading = re.match(r"(#{2,3}) +(.*\S)\s*$", line)
        if heading and len(heading.group(1)) == 2:
            close_trap()
            trap_open = None
            section = heading.group(2)
            expected = 0
            if section not in allowed:
                findings.append(_finding("L16", number, line, "section title is not one the guide names", True))
        elif heading and section in ("Examples", "Traps to Watch For"):
            close_trap()
            trap_open = None
            expected += 1
            numbered = re.match(r"#(\d+): \S", heading.group(2))
            if not numbered:
                findings.append(_finding("L20", number, line, "heading does not use the form \"### #N: Title\""))
            elif int(numbered.group(1)) != expected:
                findings.append(_finding("L20", number, line, "heading number is out of sequence; expected #%d" % expected))
            if section == "Traps to Watch For":
                trap_open = [number, line, False]
        elif trap_open and line.lstrip().startswith(">"):
            trap_open[2] = True
    close_trap()
    return findings


def _check_frontmatter(parsed, path_parts):
    findings = []
    front = parsed["frontmatter"]
    raw = parsed["raw_frontmatter"]

    def add(problem):
        findings.append(_finding("L24", 1, "frontmatter", problem))

    if list(front) != FRONTMATTER_KEYS:
        add("keys are %s; expected %s in this order" % (", ".join(front), ", ".join(FRONTMATTER_KEYS)))
    for key in QUOTED_KEYS:
        value = raw.get(key, "")
        if key in raw and not (len(value) >= 2 and value[0] == '"' and value[-1] == '"'):
            add("%s is not double-quoted" % key)
    if path_parts:
        subject, topic, slug = path_parts
        for key, expected in (("_id", "lesson-%s-%s" % (topic, slug)), ("subject", "subject-%s" % subject),
                              ("topic", "topic-%s" % topic)):
            if key in front and front[key] != expected:
                add("%s is %s; the file's place in the corpus gives %s" % (key, json.dumps(front[key]), json.dumps(expected)))
    minutes = front.get("estimatedMinutes")
    if "estimatedMinutes" in front and not (isinstance(minutes, int) and not isinstance(minutes, bool) and 8 <= minutes <= 15):
        add("estimatedMinutes is %s; the guide allows 8 to 15" % json.dumps(minutes))
    if "isActive" in front and front["isActive"] is not True:
        add("isActive is not true")
    return findings


def check_lesson(text, path_parts=None):
    """path_parts: (subject dir, topic dir, file slug), or None to skip path checks."""
    parsed = l4lib.parse_lesson(text)
    subject = path_parts[0] if path_parts else str(parsed["frontmatter"].get("subject", "")).replace("subject-", "")
    return (_check_text(parsed) + _check_formatting(parsed) + _check_sections(parsed, subject)
            + _check_frontmatter(parsed, path_parts))
