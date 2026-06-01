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
