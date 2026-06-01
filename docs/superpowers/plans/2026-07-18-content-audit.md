# Content Quality Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a complete, evidence-backed audit of all 151 lessons in `content/lessons/` — outline coverage vs CETs/DOST-SEI, mechanical defect sweeps, and a per-lesson judgment pass — reported in `docs/content/audit/` for user approval before any fixes.

**Architecture:** Three layers. Layer 0 diffs `tools/lesson_author/outline.json` against researched exam scopes. Layer 1 is five Python sweep scripts in `tools/audit/` that over-report mechanical defects into a TSV. Layer 2 is a human-judgment reading of every lesson, subject by subject, which also curates the TSV into findings files with IDs and severities.

**Tech Stack:** Python 3 stdlib only (run as `python3 tools/audit/<script>.py`), WebSearch for exam research, markdown reports.

## Global Constraints

- **Report-only.** The audit NEVER edits any file under `content/lessons/`. Fixes happen in later, separately approved phases.
- **No AI attribution in commits.** This project forbids Claude trailers/Co-Authored-By lines. Plain conventional commits only.
- Spec: `docs/superpowers/specs/2026-07-18-content-audit-design.md`. Benchmark exams: UPCAT, ACET, DLSUCET, USTET, DOST-SEI.
- Severity taxonomy (exact strings): `blocker`, `important`, `polish`.
- Finding ID format: `<SUBJ>-<TOPIC>-<NNN>` (e.g. `MATH-ALG-007`), numbered per topic in file order.
- Sweeps over-report by design. Curation may dismiss a sweep line only by logging it under a "Dismissed" heading with a reason — never silently.
- Every finding cites `file:line` evidence and a specific fix.
- Sweep TSV line format: `CLASS<TAB>severity<TAB>relpath:line<TAB>message`.
- Lesson corpus root: `content/lessons/`; 5 subjects, 18 topics, 151 files.

---

### Task 1: Audit harness — lib, fixtures, seeded test

**Files:**
- Create: `tools/audit/lib.py`
- Create: `tools/audit/fixtures/testsubj/testtopic/broken.md`
- Create: `tools/audit/fixtures/testsubj/testtopic/clean.md`
- Create: `tools/audit/test_sweeps.py`

**Interfaces:**
- Produces: `lib.iter_lessons(root=None) -> Iterator[Lesson]` where `Lesson` has `.path` (Path), `.rel` (str like `mathematics/algebra/quadratic-equations.md`), `.front` (dict of frontmatter strings), `.lines` (list of `(lineno, text)` body tuples, 1-indexed against the real file), `.sections` (dict section-name → list of `(lineno, text)`).
- Produces: `lib.examples(lesson) -> list[(title_lineno, title_str, [(lineno, text)])]` for each `### ` block inside the `Examples` section.
- Produces: `lib.finding(cls, severity, lesson, lineno, msg)` — prints one TSV line.
- Every sweep module (Tasks 2–6) exposes `run(root=None)` printing findings for the corpus at `root` (default: live corpus).

- [ ] **Step 1: Write `tools/audit/lib.py`**

```python
"""Shared lesson-corpus loader for audit sweeps."""
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "content" / "lessons"


@dataclass
class Lesson:
    path: Path
    rel: str
    front: dict
    lines: list
    sections: dict


def parse_lesson(path, root=None):
    root = Path(root) if root else ROOT
    text = path.read_text(encoding="utf-8").splitlines()
    front, body_start = {}, 0
    if text and text[0] == "---":
        for i in range(1, len(text)):
            if text[i] == "---":
                body_start = i + 1
                break
            m = re.match(r'(\w+):\s*"?(.*?)"?\s*$', text[i])
            if m:
                front[m.group(1)] = m.group(2)
    lines = [(i + 1, t) for i, t in enumerate(text[body_start:], start=body_start)]
    sections, current = {}, None
    for ln, t in lines:
        m = re.match(r"^## (.+)$", t)
        if m:
            current = m.group(1).strip()
            sections[current] = []
        elif current is not None:
            sections[current].append((ln, t))
    return Lesson(path=path, rel=str(path.relative_to(root)),
                  front=front, lines=lines, sections=sections)


def iter_lessons(root=None):
    root = Path(root) if root else ROOT
    for p in sorted(root.rglob("*.md")):
        yield parse_lesson(p, root)


def examples(lesson):
    blocks, cur = [], None
    for ln, t in lesson.sections.get("Examples", []):
        m = re.match(r"^### (.+)$", t)
        if m:
            cur = (ln, m.group(1).strip(), [])
            blocks.append(cur)
        elif cur is not None:
            cur[2].append((ln, t))
    return blocks


def finding(cls, severity, lesson, lineno, msg):
    print(f"{cls}\t{severity}\t{lesson.rel}:{lineno}\t{msg}")
```

- [ ] **Step 2: Write the two fixture lessons**

`tools/audit/fixtures/testsubj/testtopic/broken.md` — seeds one defect per sweep class:

```markdown
---
_id: "lesson-testtopic-broken"
title: "Broken"
summary: "This lesson teaches you broken things."
subject: "subject-testsubj"
topic: "topic-testtopic"
estimatedMinutes: 9
isActive: true
---
## Core Concept

Nothing here teaches a formula.

## Examples

### #1: Missing Devices

Which of the following is the synonym of the underlined word?
The dog was *happy*.

**Solution:**

1. Use the distance formula below.

$$v = d/t$$

### #2: No Solution Label

Find $x$ in the figure shown above.
```

`tools/audit/fixtures/testsubj/testtopic/clean.md` — must trigger nothing in the device/formula/structure sweeps:

```markdown
---
_id: "lesson-testtopic-clean"
title: "Clean"
summary: "This lesson teaches you speed."
subject: "subject-testsubj"
topic: "topic-testtopic"
estimatedMinutes: 9
isActive: true
---
## Core Concept

Speed is distance divided by time:

$$v = \dfrac{d}{t}$$

## Examples

### #1: Basic

A car travels $10$ km in $2$ hours. Find the speed.

**Solution:**

1. Substitute into the formula.

$$v = \dfrac{10}{2} = 5$$
```

- [ ] **Step 3: Write the seeded test `tools/audit/test_sweeps.py`**

```python
"""Seeded tests: sweeps must catch known-bad fixtures and known live defects."""
import contextlib
import io
from pathlib import Path

import lib
import sweep_structure
import sweep_devices
import sweep_illustrations
import sweep_formulas

FIXTURES = Path(__file__).parent / "fixtures"
fails = []


def output(mod, root):
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        mod.run(root)
    return buf.getvalue()


def check(name, cond):
    print(("PASS" if cond else "FAIL"), name)
    if not cond:
        fails.append(name)


fx_dev = output(sweep_devices, FIXTURES)
check("fixture: underline without markup flagged", "underlin" in fx_dev and "broken.md" in fx_dev)
check("fixture: missing answer choices flagged", "no A)-D) choices" in fx_dev)
check("fixture: clean lesson silent in device sweep", "clean.md" not in fx_dev)
check("fixture: untaught formula flagged", "not taught" in output(sweep_formulas, FIXTURES))
check("fixture: missing Solution label flagged", "no **Solution:**" in output(sweep_structure, FIXTURES))
check("fixture: figure-dependent example flagged", "broken.md" in output(sweep_illustrations, FIXTURES))

live_dev = output(sweep_devices, None)
check("live seed: context-clues underline defect", "vocabulary/context-clues.md" in live_dev)
live_ill = output(sweep_illustrations, None)
check("live seed: figure-series prose-only examples", "figure-series.md" in live_ill)

raise SystemExit(1 if fails else 0)
```

- [ ] **Step 4: Run the test to verify it fails for the right reason**

Run: `cd tools/audit && python3 test_sweeps.py`
Expected: `ModuleNotFoundError: No module named 'sweep_structure'` (sweeps not written yet).

- [ ] **Step 5: Commit**

```bash
git add tools/audit/lib.py tools/audit/fixtures tools/audit/test_sweeps.py
git commit -m "tools(audit): add lesson loader, fixtures, and seeded sweep tests"
```

---

### Task 2: Structure sweep

**Files:**
- Create: `tools/audit/sweep_structure.py`

**Interfaces:**
- Consumes: `lib.iter_lessons`, `lib.examples`, `lib.finding` (Task 1 signatures).
- Produces: `run(root=None)` printing `STRUCT` findings.

- [ ] **Step 1: Write `tools/audit/sweep_structure.py`**

```python
"""Structure sweep: sections, Solution labels, frontmatter, notation, forbidden markup."""
import re

import lib

KNOWN = ["Core Concept", "Mnemonics & Memory Aids", "Examples",
         "Speed Tricks & Shortcuts", "Traps to Watch For"]
FRONT_KEYS = ["_id", "title", "summary", "subject", "topic",
              "estimatedMinutes", "isActive"]


def run(root=None):
    for les in lib.iter_lessons(root):
        if list(les.front) != FRONT_KEYS:
            lib.finding("STRUCT", "polish", les, 1,
                        f"frontmatter keys {list(les.front)} differ from required order {FRONT_KEYS}")
        mins = les.front.get("estimatedMinutes", "")
        if not mins.isdigit() or not 8 <= int(mins) <= 15:
            lib.finding("STRUCT", "polish", les, 1, f"estimatedMinutes={mins!r} outside 8-15")
        names = list(les.sections)
        if "Core Concept" not in names or "Examples" not in names:
            lib.finding("STRUCT", "important", les, 1, f"missing core sections; has {names}")
        for n in names:
            if n not in KNOWN:
                lib.finding("STRUCT", "polish", les, 1,
                            f"extra section {n!r} (allowed sparingly - review in judgment pass)")
        for ln, title, body in lib.examples(les):
            if not any(re.search(r"\*\*Solution:?\*\*", t) for _, t in body):
                lib.finding("STRUCT", "important", les, ln, f"example {title!r} has no **Solution:** label")
        for ln, t in les.lines:
            if re.search(r"\\frac\b", t):
                lib.finding("STRUCT", "polish", les, ln, "\\frac used (style guide requires \\dfrac)")
            if t.lstrip().startswith("|"):
                lib.finding("STRUCT", "important", les, ln, "table markup (forbidden by style guide)")
            if "](http" in t:
                lib.finding("STRUCT", "important", les, ln, "link (forbidden by style guide)")
            if t.startswith("```"):
                lib.finding("STRUCT", "important", les, ln, "code fence (forbidden by style guide)")
            if "![" in t:
                lib.finding("STRUCT", "important", les, ln, "image markup (forbidden by style guide)")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run the sweep standalone on the live corpus for a sanity read**

Run: `cd tools/audit && python3 sweep_structure.py | head -30`
Expected: TSV lines; spot-check two by opening the cited file:line and confirming the defect is real. If a check misfires systematically (e.g. every lesson flagged for frontmatter), fix the check, not the corpus.

- [ ] **Step 3: Commit**

```bash
git add tools/audit/sweep_structure.py
git commit -m "tools(audit): add structure sweep"
```

---

### Task 3: Referenced-device sweep

**Files:**
- Create: `tools/audit/sweep_devices.py`

**Interfaces:**
- Consumes: Task 1 lib signatures.
- Produces: `run(root=None)` printing `DEVICE` findings. Message strings `"no A)-D) choices"` and `"underlin"` are asserted by `test_sweeps.py` — keep them verbatim.

- [ ] **Step 1: Write `tools/audit/sweep_devices.py`**

```python
"""Referenced-device sweep: every device a question mentions must actually exist."""
import re

import lib

CHOICE = re.compile(r"^\(?[A-D]\)")
QUESTION_CUES = re.compile(
    r"which of the following|select the (word|phrase|answer|option)|among the (following|choices)",
    re.I)
FIGURE_CUES = re.compile(
    r"\b(as )?shown (above|below)\b|\bthe (figure|diagram|illustration) (above|below|shows)\b",
    re.I)
ITALIC = re.compile(r"(?<!\*)\*[^*\s][^*]*\*(?!\*)")


def run(root=None):
    for les in lib.iter_lessons(root):
        body = "\n".join(t for _, t in les.lines if "ILLUSTRATION:" not in t)
        if re.search(r"underlin", body, re.I) and "<u>" not in body:
            for ln, t in les.lines:
                if re.search(r"underlin", t, re.I) and "ILLUSTRATION:" not in t:
                    lib.finding("DEVICE", "blocker", les, ln,
                                "mentions underlining but file has no <u> markup "
                                "(markdown cannot underline)")
        for ln, title, blk in lib.examples(les):
            joined = "\n".join(t for _, t in blk)
            has_choices = any(CHOICE.match(t.strip()) for _, t in blk)
            for l, t in blk:
                if QUESTION_CUES.search(t) and not has_choices:
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} says choose-from-options but lists no A)-D) choices")
                if re.search(r"\bbold-?faced?\b", t, re.I) and "**" not in joined:
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} mentions a boldfaced word but has no bold markup")
                if re.search(r"\bitalicized\b", t, re.I) and not ITALIC.search(joined):
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} mentions an italicized word but has no italics")
                if FIGURE_CUES.search(t) and "ILLUSTRATION:" not in joined:
                    lib.finding("DEVICE", "important", les, l,
                                f"example {title!r} refers to a figure but has no ILLUSTRATION placeholder")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run on live corpus, spot-verify two findings**

Run: `cd tools/audit && python3 sweep_devices.py`
Expected: includes a `blocker` line for `language-proficiency/vocabulary/context-clues.md` (known seed). Open two other cited lines and confirm each defect is real.

- [ ] **Step 3: Commit**

```bash
git add tools/audit/sweep_devices.py
git commit -m "tools(audit): add referenced-device sweep"
```

---

### Task 4: Illustration sweep

**Files:**
- Create: `tools/audit/sweep_illustrations.py`

**Interfaces:**
- Consumes: Task 1 lib signatures.
- Produces: `run(root=None)` printing `ILLUS` findings.

- [ ] **Step 1: Write `tools/audit/sweep_illustrations.py`**

```python
"""Illustration sweep: visual topics need a placeholder in every figure-dependent example."""
import re

import lib

ALWAYS = {
    "reasoning/spatial-abstract-reasoning",
    "reasoning/mechanical-technical-reasoning",
    "mathematics/geometry",
    "testsubj/testtopic",
}
CUES = re.compile(
    r"\b(figure|diagram|graph|triangle|rectangle|circle|angle|gear|pulley|lever|"
    r"circuit|wave|vector|rotat\w*|fold\w*|shaded?|plot|number line|bar chart|pie chart)\b",
    re.I)


def run(root=None):
    for les in lib.iter_lessons(root):
        parts = les.rel.split("/")
        topic = "/".join(parts[:2]) if len(parts) >= 3 else ""
        body = "\n".join(t for _, t in les.lines)
        if topic in ALWAYS and "ILLUSTRATION:" not in body:
            lib.finding("ILLUS", "important", les, 1,
                        "visual-topic lesson has zero ILLUSTRATION placeholders")
        for ln, title, blk in lib.examples(les):
            joined = "\n".join(t for _, t in blk)
            needs = topic in ALWAYS or CUES.search(joined)
            if needs and "ILLUSTRATION:" not in joined:
                lib.finding("ILLUS", "important", les, ln,
                            f"example {title!r} is figure-dependent but has no placeholder in its block")


if __name__ == "__main__":
    run()
```

Note: `CUES` will over-report (a word problem may mention "circle" without needing art). That is intended; the judgment pass dismisses false positives with logged reasons.

- [ ] **Step 2: Run on live corpus, verify the known seed**

Run: `cd tools/audit && python3 sweep_illustrations.py | grep spatial`
Expected: findings for the examples of all five `spatial-abstract-reasoning` lessons, including `figure-series.md`.

- [ ] **Step 3: Commit**

```bash
git add tools/audit/sweep_illustrations.py
git commit -m "tools(audit): add per-example illustration sweep"
```

---

### Task 5: Formula-completeness sweep

**Files:**
- Create: `tools/audit/sweep_formulas.py`

**Interfaces:**
- Consumes: Task 1 lib signatures.
- Produces: `run(root=None)` printing `FORMULA` findings. Message must contain `"not taught"` (asserted by tests).

- [ ] **Step 1: Write `tools/audit/sweep_formulas.py`**

```python
"""Formula-completeness sweep: formulas used in solutions must be taught before Examples.

Heuristic: a display equation inside an example that contains '=' and two or
more distinct single-letter variables is treated as a formula; its variables
must all appear among the variables of display equations in teaching sections.
Over-reports by design; judgment pass curates.
"""
import re

import lib

CMD = re.compile(r"\\[a-zA-Z]+")
SINGLE = re.compile(r"(?<![a-zA-Z])[a-zA-Z](?![a-zA-Z])")


def display_eqs(lines):
    return re.findall(r"\$\$(.+?)\$\$", "\n".join(t for _, t in lines), re.S)


def letters(eq):
    return set(SINGLE.findall(CMD.sub(" ", eq)))


def run(root=None):
    for les in lib.iter_lessons(root):
        taught = set()
        for name, body in les.sections.items():
            if name != "Examples":
                for eq in display_eqs(body):
                    taught |= letters(eq)
        for ln, title, blk in lib.examples(les):
            for eq in display_eqs(blk):
                ls = letters(eq)
                if "=" in eq and len(ls) >= 2 and not ls <= taught:
                    lib.finding("FORMULA", "important", les, ln,
                                f"example {title!r} uses formula vars {sorted(ls)} not taught before Examples")


if __name__ == "__main__":
    run()
```

- [ ] **Step 2: Run seeded tests — all sweeps now exist**

Run: `cd tools/audit && python3 test_sweeps.py`
Expected: exit 0, all `PASS` lines, including both live seeds (`context-clues.md`, `figure-series.md`). If any FAIL, fix the sweep (or, if a live seed moved, re-verify the corpus file) before continuing.

- [ ] **Step 3: Commit**

```bash
git add tools/audit/sweep_formulas.py
git commit -m "tools(audit): add formula-completeness sweep; seeded tests pass"
```

---

### Task 6: AI-tell sweep, data files, run_all

**Files:**
- Create: `tools/audit/data/ai_phrases.txt`
- Create: `tools/audit/data/caps_whitelist.txt`
- Create: `tools/audit/sweep_ai_tells.py`
- Create: `tools/audit/run_all.py`

**Interfaces:**
- Consumes: Task 1 lib signatures; sweep modules from Tasks 2–5.
- Produces: `run_all.py` writes every sweep's output to `docs/content/audit/sweep-results.tsv` and prints severity totals.

- [ ] **Step 1: Write `tools/audit/data/ai_phrases.txt`** (one phrase per line; matched case-insensitively; counts only — curation decides which occurrences are genuinely tells)

```text
it's important to note
it is important to note
delve
crucial
furthermore
moreover
additionally,
in conclusion
plays a vital role
plays a key role
in today's world
generally speaking
to some extent
keep in mind that
simply put
that being said
serves as a
acts as a
not only
seamless
comprehensive
```

- [ ] **Step 2: Write `tools/audit/data/caps_whitelist.txt`** (legitimate all-caps tokens; one per line)

```text
DNA
RNA
ATP
ADP
ER
DOST
SEI
UPCAT
ACET
USTET
DLSUCET
NCAE
NMAT
PEMDAS
GEMDAS
SOH
CAH
TOA
GCF
LCM
LCD
POV
STP
SI
II
III
IV
FOIL
CET
PH
AM
PM
```

- [ ] **Step 3: Write `tools/audit/sweep_ai_tells.py`**

```python
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
```

- [ ] **Step 4: Write `tools/audit/run_all.py`**

```python
"""Run every sweep and write combined results to docs/content/audit/sweep-results.tsv."""
import contextlib
import io
from pathlib import Path

import sweep_structure
import sweep_devices
import sweep_illustrations
import sweep_formulas
import sweep_ai_tells

OUT = Path(__file__).resolve().parents[2] / "docs" / "content" / "audit" / "sweep-results.tsv"
SWEEPS = (sweep_structure, sweep_devices, sweep_illustrations, sweep_formulas, sweep_ai_tells)


def main():
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        for mod in SWEEPS:
            mod.run()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(buf.getvalue())
    lines = buf.getvalue().splitlines()
    print(f"{len(lines)} findings -> {OUT}")
    for sev in ("blocker", "important", "polish"):
        print(f"  {sev}: {sum(1 for l in lines if l.split(chr(9))[1] == sev)}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 5: Run everything against the live corpus**

Run: `cd tools/audit && python3 test_sweeps.py && python3 run_all.py`
Expected: tests exit 0; run_all prints total findings and per-severity counts, and `docs/content/audit/sweep-results.tsv` exists. Skim 10 random TSV lines and confirm each cites a real defect or a curatable over-report.

- [ ] **Step 6: Commit**

```bash
git add tools/audit docs/content/audit/sweep-results.tsv
git commit -m "tools(audit): add AI-tell sweep and run_all; capture baseline sweep results"
```

---

### Task 7: Layer 0 — exam benchmarks and outline coverage diff

**Files:**
- Create: `docs/content/audit/benchmarks/upcat.md`
- Create: `docs/content/audit/benchmarks/acet.md`
- Create: `docs/content/audit/benchmarks/dlsucet.md`
- Create: `docs/content/audit/benchmarks/ustet.md`
- Create: `docs/content/audit/benchmarks/dost-sei.md`
- Create: `docs/content/audit/00-overview.md` (draft — outline-coverage section only; Task 13 completes it)

**Interfaces:**
- Consumes: `tools/lesson_author/outline.json` (subjects → topics → lessons → sections).
- Produces: per-exam benchmark checklists that Tasks 8–12 read as the exhaustiveness yardstick; outline-coverage findings with IDs `OUTLINE-NNN`.

- [ ] **Step 1: Research each exam's scope with WebSearch**

For each of UPCAT, ACET, DLSUCET, USTET, DOST-SEI run searches like `"<exam> subtests coverage topics 2025 2026"` and `"<exam> reviewer scope"`. Prefer official university/DOST-SEI pages and established reviewer publishers; note that DLSUCET and USTET scopes shifted in recent years (DLSU moved to using other measures some years — verify current state rather than assuming).

- [ ] **Step 2: Write one benchmark file per exam**

Each `docs/content/audit/benchmarks/<exam>.md` contains: the subtests, the topics tested under each subtest (as a flat checklist), quirks worth teaching (e.g. UPCAT right-minus-wrong scoring if still current), and a `Sources` list of markdown links. Any scope item not confirmed by a source is marked `(unverified)` — never silently asserted.

- [ ] **Step 3: Diff `outline.json` against the union of benchmark checklists**

Read `tools/lesson_author/outline.json` in full. For every benchmark topic, find the outline lesson(s) covering it; for every outline lesson, find the exam(s) needing it. Record in `docs/content/audit/00-overview.md`:

```markdown
# Content Audit — Overview

Spec: ../../superpowers/specs/2026-07-18-content-audit-design.md

## Outline coverage vs benchmark exams

### Missing from outline
- OUTLINE-001 [important] <exam(s)>: <topic not covered by any outline lesson> — proposed lesson: <title, target topic folder>

### Covered but thin
- OUTLINE-0NN [important] <lesson>: <benchmark sub-skill with no dedicated treatment>

### In outline but tested by no benchmark exam
- OUTLINE-0NN [polish] <lesson> — candidate to deprioritize (flag only; deletion needs approval)
```

- [ ] **Step 4: Commit**

```bash
git add docs/content/audit/benchmarks docs/content/audit/00-overview.md
git commit -m "audit: add exam benchmark checklists and outline coverage diff"
```

---

### Tasks 8–12: Layer 2 — judgment pass, one task per subject

Five identical tasks; only the subject changes. Order: **Task 8 Mathematics, Task 9 Science, Task 10 Language Proficiency, Task 11 Reading Comprehension, Task 12 Reasoning.**

**Files (per task):**
- Create: `docs/content/audit/<subject-slug>.md` (e.g. `mathematics.md`)
- Read: every lesson under `content/lessons/<subject-slug>/`, `docs/content/audit/sweep-results.tsv`, `docs/content/audit/benchmarks/*.md`, `docs/content/lesson-style-guide.md`

**Interfaces:**
- Consumes: sweep TSV lines for the subject; benchmark checklists (Task 7).
- Produces: a findings file whose IDs (`MATH-ALG-001` style) Task 13 aggregates. Topic codes: first letters of the topic slug, 3–4 caps (e.g. ALG, ARI, GEO, TRI, PRE, STA; BIO, CHE, PHY, EAS; GRA, VOC, LAP; COM, TXT; LOG, SPA, MEC).

- [ ] **Step 1: Extract this subject's sweep findings**

Run: `grep -P "\t[^\t]*\t<subject-slug>/" docs/content/audit/sweep-results.tsv > /tmp/subject-sweep.tsv` (use the scratchpad dir, not /tmp, when executing). Every line must end up either curated into a finding or listed under "Dismissed" with a reason.

- [ ] **Step 2: Read every lesson in the subject, one topic at a time, applying this checklist per lesson**

1. **Correctness:** re-derive every worked computation and stated fact; verify each example has exactly one defensible answer; flag questions that contain their own answer (appositives, glosses).
2. **Self-containment of questions:** every referenced device exists (beyond what sweeps catch — e.g. a passage the question needs, plausible distractors); solution steps reference only taught material.
3. **Exhaustiveness:** diff the lesson against the benchmark checklists — which tested sub-skills or standard question forms are absent?
4. **Self-teachability:** undefined terms, missing prerequisites (name the prerequisite lesson), difficulty ramp jumps, missing Filipino terms where exams use them.
5. **Template fit:** note where the five-section Math template misfits; accumulate into a per-subject template proposal at the end of the findings file.
6. **Illustration judgment:** figures the topic conventionally needs that neither prose nor placeholders provide; vague existing placeholders an artist could not draw from.
7. **Sweep curation:** confirm or dismiss each sweep line for this lesson.

- [ ] **Step 3: Write `docs/content/audit/<subject-slug>.md`**

```markdown
# <Subject> — Audit Findings

## <topic-slug>

### <ID> [<severity>] <file> — <one-line defect>
Evidence: `<file>:<line>` — "<short quote>"
Fix: <specific action>

## Template fit — proposal for <subject>
<sections to keep/rename/add/drop, with rationale from findings above>

## Dismissed sweep lines
- `<TSV line>` — <reason it is a false positive>
```

- [ ] **Step 4: Checkpoint commit after each topic within the subject** (audit survives context loss)

```bash
git add docs/content/audit/<subject-slug>.md
git commit -m "audit(<subject-slug>): findings through <topic-slug>"
```

- [ ] **Step 5: Final commit for the subject once all topics are done and every sweep line is curated or dismissed**

```bash
git add docs/content/audit/<subject-slug>.md
git commit -m "audit(<subject-slug>): complete judgment pass"
```

---

### Task 13: Overview roll-up and handoff

**Files:**
- Modify: `docs/content/audit/00-overview.md` (extends the Task 7 draft)

**Interfaces:**
- Consumes: all five subject findings files, sweep-results.tsv, benchmark files.

- [ ] **Step 1: Verify completeness before summarizing**

Run: `cd tools/audit && python3 test_sweeps.py && python3 run_all.py` (results unchanged — audit made no content edits). Then confirm every TSV line appears in exactly one subject file (as finding or dismissed): spot-check 10 lines with grep.

- [ ] **Step 2: Complete `00-overview.md`**

Append these sections, each drawing only on recorded findings:

- **Totals:** findings per severity per subject (a small table is fine in docs).
- **Top blockers:** every `blocker`, one line each, linked to its subject file.
- **Template reform:** the five per-subject template proposals, consolidated; note the app has no dependency on section names.
- **Style guide v2 outline:** the guide-mandated AI tells to drop (ALL-CAPS emphasis, uniform trap openers, "This lesson teaches you…" summaries, em-dash habits), plus the underline-rendering convention decision.
- **De-AI rewrite scope:** lessons ranked by AI-tell score from the sweep.
- **Recommended fix order:** restate spec phases 1–5 with estimated lesson counts per phase from actual findings.

- [ ] **Step 3: Commit**

```bash
git add docs/content/audit/00-overview.md
git commit -m "audit: complete overview roll-up"
```

- [ ] **Step 4: Present to the user**

Report totals, the top blockers, and the recommended fix order. Ask which severities/phases to approve for fixing. Fix execution is a separate plan — do not begin edits to `content/lessons/` in this one.

---

## Self-Review

- **Spec coverage:** Layer 0 → Task 7; layer 1 sweeps (devices, formulas, illustrations, AI tells, structure) → Tasks 2–6; layer 2 checks 1–5 → Tasks 8–12 checklist items 1–6; deliverable format with IDs/severities → Tasks 7–13; seeded-test requirement → Tasks 1 and 5; "rerun returns zero for fixed classes" → rerunnable `run_all.py`; report-only rule → Global Constraints and Task 13 Step 4. No gaps found.
- **Placeholder scan:** all code complete; benchmark file contents are research outputs by nature, with required structure and sourcing rules specified.
- **Type consistency:** `run(root=None)`, `lib.finding` signature, TSV format, and test-asserted message strings (`"no A)-D) choices"`, `"not taught"`, `"no **Solution:**"`) match across tasks.
