"""AI-tell inventory: per-lesson pattern counts feeding the de-AI rewrite pass."""
import re
from pathlib import Path

import lib

DATA = Path(__file__).parent / "data"
PHRASES = [p.strip() for p in (DATA / "ai_phrases.txt").read_text().splitlines() if p.strip()]
WHITELIST = {w.strip() for w in (DATA / "caps_whitelist.txt").read_text().splitlines() if w.strip()}


def run(root=None):
    for les in lib.iter_lessons(root):
        body = "\n".join(t for _, t in les.lines if "ILLUSTRATION:" not in t)
        prose = re.sub(r"\$\$.*?\$\$", " ", body, flags=re.S)
        prose = re.sub(r"\$[^$\n]*\$", " ", prose)
        caps = [w for w in re.findall(r"\b[A-Z]{2,}\b", prose) if w not in WHITELIST]
        emdash = prose.count("—")
        notjust = len(re.findall(r"\bnot (just|only|merely)\b[^.]{0,80}\bbut\b", prose, re.I))
        stock = sum(len(re.findall(re.escape(p), prose, re.I)) for p in PHRASES)
        testm = len(re.findall(r"test-?makers", prose, re.I))
        opener = les.front.get("summary", "").startswith("This lesson teaches you")
        if caps or emdash or notjust or stock or testm or opener:
            lib.finding("AI-TELL", "polish", les, 0,
                        f"caps={len(caps)} emdash={emdash} notjust={notjust} "
                        f"stock={stock} testmakers={testm} stock_summary={opener} "
                        f"caps_words={sorted(set(caps))[:8]}")


if __name__ == "__main__":
    run()
