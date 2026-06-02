"""De-shout lessons: convert ALL-CAPS emphasis words to normal case.

Preserves real acronyms, LaTeX ($...$, $$...$$), and ILLUSTRATION comments.
Re-capitalizes a de-shouted word when it starts a sentence, line, list item,
or blockquote. Bold/italic markers around a word are left intact.
"""
import re
import sys
from pathlib import Path

KEEP = {
    # geometry congruence / similarity
    "SSS", "SAS", "ASA", "AAS", "AAA", "SSA", "HL", "LL", "LA", "HA",
    # math
    "GCF", "LCM", "LCD", "SD", "FOIL", "SOH", "CAH", "TOA", "SI",
    "PEMDAS", "GEMDAS",
    # science
    "DNA", "RNA", "ATP", "ADP", "ABO", "CNS", "PNS", "UV", "XX", "XY",
    "PMAT", "ER", "STP", "VSEPR", "PH",
    # exams / orgs
    "CET", "CETS", "UPCAT", "ACET", "USTET", "DLSUCET", "NCAE", "NMAT",
    "DOST", "SEI", "KWF",
    # roman numerals
    "II", "III", "IV", "VI", "VII", "VIII", "IX", "XI", "XII",
}

TOKEN = re.compile(r"[A-Za-z]{2,}")
SENTENCE_LEAD = re.compile(r"(^|[.!?:]\s+|\n|>\s+|^\s*[-*]\s+|^\s*\d+\.\s+)$")


def protect(text):
    """Replace math and comments with placeholders so we don't touch them."""
    stash = []

    def stash_sub(m):
        stash.append(m.group(0))
        return f"\x00{len(stash) - 1}\x00"

    text = re.sub(r"\$\$.*?\$\$", stash_sub, text, flags=re.S)
    text = re.sub(r"\$[^$\n]*\$", stash_sub, text)
    text = re.sub(r"<!--.*?-->", stash_sub, text, flags=re.S)
    return text, stash


def restore(text, stash):
    return re.sub(r"\x00(\d+)\x00", lambda m: stash[int(m.group(1))], text)


def deshout_line(line):
    def repl(m):
        w = m.group(0)
        if w != w.upper() or w.upper() in KEEP or len(w) < 2:
            return w
        start = m.start()
        lead = line[:start]
        # capitalize if this token begins the line or follows sentence break
        if SENTENCE_LEAD.search(lead) or start == 0:
            return w[0] + w[1:].lower()
        return w.lower()
    return TOKEN.sub(repl, line)


def deshout(text):
    text, stash = protect(text)
    out = []
    in_front = False
    for i, line in enumerate(text.splitlines()):
        if i == 0 and line == "---":
            in_front = True
            out.append(line)
            continue
        if in_front:
            out.append(line)
            if line == "---":
                in_front = False
            continue
        if line.startswith("#"):  # headings keep their case
            out.append(line)
            continue
        out.append(deshout_line(line))
    return restore("\n".join(out) + ("\n" if text.endswith("\n") else ""), stash)


def main(paths):
    for p in paths:
        p = Path(p)
        new = deshout(p.read_text(encoding="utf-8"))
        p.write_text(new, encoding="utf-8")


if __name__ == "__main__":
    main(sys.argv[1:])
