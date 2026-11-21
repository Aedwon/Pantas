"""Build lesson-fit packets: the lesson plus the full question file.

  python3 -I build_fit_packets.py --out DIR [--files PATH ...]

Without --files, every CET question file is used. Writes
DIR/fit/<file-id>.md.
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import qloader as L  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--files", nargs="*")
    a = ap.parse_args()

    out = Path(a.out) / "fit"
    out.mkdir(parents=True, exist_ok=True)
    paths = sorted(L.resolve_files(a.files)) if a.files else L.cet_files()
    n = missing = 0
    for path in paths:
        fid = L.file_id(path)
        rel = path.relative_to(L.QUESTIONS)
        lesson = (L.LESSONS / rel).with_suffix(".md")
        if lesson.exists():
            lesson_text = lesson.read_text(encoding="utf-8").rstrip()
        else:
            lesson_text = "(no lesson file found at this path)"
            missing += 1
        body = (
            f"# Lesson-fit packet {fid}\n\n"
            f"## Lesson ({L.rel_repo(lesson)})\n\n{lesson_text}\n\n"
            f"## Question file ({L.rel_repo(path)})\n\n```yaml\n"
            f"{path.read_text(encoding='utf-8').rstrip()}\n```\n"
        )
        (out / f"{fid}.md").write_text(body, encoding="utf-8")
        n += 1
    print(f"fit packets {n}; lessons missing {missing}")


if __name__ == "__main__":
    main()
