"""Build blind-solve packets and answer keys for CET question files.

  python3 -I build_packets.py --out DIR [--files PATH ...] [--all-cet]

Writes DIR/packets/<file-id>.md (stems, passages, shuffled choices only),
DIR/keys/<file-id>.json (kept apart: order, seed, correct letter) and
DIR/skipped.json (questions identical to the CSE blind-solve commit).
"""
import argparse
import hashlib
import json
import random
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import qloader as L  # noqa: E402

LETTERS = "ABCDEFGHIJKLMNOP"
# Choices that refer to the others by position stay last, in authored order.
PINNED = re.compile(r"\b(all|none|both|neither)\s+of\s+(the\s+)?(above|these|them)\b|\bof the above\b", re.I)


def seed_for(qid):
    return int.from_bytes(hashlib.sha256(qid.encode()).digest()[:4], "big")


def shuffled_order(q):
    n = len(q["choices"])
    pinned = [i for i, c in enumerate(q["choices"]) if PINNED.search(c["text"])]
    free = [i for i in range(n) if i not in pinned]
    seed = seed_for(q["id"])
    random.Random(seed).shuffle(free)
    return seed, free + pinned


def figure_text(spec):
    def num(v):
        if isinstance(v, dict):
            return {k: num(x) for k, x in v.items()}
        if isinstance(v, list):
            return [num(x) for x in v]
        if isinstance(v, str):
            if L.INT_RE.match(v):
                return int(v)
            if L.FLOAT_RE.match(v):
                return float(v)
        return v
    return json.dumps(num(spec), ensure_ascii=False, sort_keys=False)


def render_packet(fid, items, passages):
    out = [f"# Questions {fid}", ""]
    out.append(
        "Answer each question with the single best choice. "
        "Choices are labeled A, B, C and so on."
    )
    out.append("")
    shown = {}
    for n, (q, order) in enumerate(items, 1):
        out.append(f"## {n}")
        out.append("")
        pid = q.get("passage")
        if pid:
            label = shown.get(pid)
            if label is None:
                label = shown[pid] = len(shown) + 1
                p = passages[pid]
                title = f" ({p['title']})" if p.get("title") else ""
                out.append(f"Passage {label}{title}:")
                out.append("")
                out.append(p["body"].strip())
                out.append("")
            else:
                out.append(f"Refer to Passage {label} above.")
                out.append("")
        if q.get("figureSpec"):
            out.append(
                "Figure data (the figure itself is not shown; this describes it): "
                + figure_text(q["figureSpec"])
            )
            out.append("")
        out.append(q["stem"].strip())
        out.append("")
        for pos, idx in enumerate(order):
            out.append(f"{LETTERS[pos]}. {q['choices'][idx]['text']}")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--files", nargs="*")
    ap.add_argument("--all-cet", action="store_true")
    a = ap.parse_args()
    if not a.files and not a.all_cet:
        ap.error("give --files or --all-cet")

    out = Path(a.out)
    (out / "packets").mkdir(parents=True, exist_ok=True)
    (out / "keys").mkdir(parents=True, exist_ok=True)

    paths = L.cet_files() if a.all_cet else []
    if a.files:
        for p in L.resolve_files(a.files):
            if p not in paths:
                paths.append(p)
    paths = sorted(paths)

    cse = L.cse_signatures()
    skipped = {}
    n_scope = n_skip = n_solve = n_pinned = n_files = 0
    for path in paths:
        data = L.load(path)
        if not L.is_cet(data["meta"]):
            print(f"warning: not a CET file, ignored: {path}", file=sys.stderr)
            continue
        fid = L.file_id(path)
        n_files += 1
        items, key_rows = [], []
        for q in data["questions"]:
            n_scope += 1
            sig = L.signature(q, data["passages"])
            if sig in cse.get(q["id"], ()):
                skipped.setdefault(fid, []).append(q["id"])
                n_skip += 1
                continue
            seed, order = shuffled_order(q)
            if any(PINNED.search(c["text"]) for c in q["choices"]):
                n_pinned += 1
            items.append((q, order))
            correct_idx = next(i for i, c in enumerate(q["choices"]) if c["correct"])
            key_rows.append(
                {
                    "n": len(items),
                    "id": q["id"],
                    "seed": seed,
                    "order": order,
                    "correct": LETTERS[order.index(correct_idx)],
                }
            )
            n_solve += 1
        if not items:
            continue
        (out / "packets" / f"{fid}.md").write_text(
            render_packet(fid, items, data["passages"]), encoding="utf-8"
        )
        (out / "keys" / f"{fid}.json").write_text(
            json.dumps(
                {"file_id": fid, "source": L.rel_repo(path), "questions": key_rows},
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
    (out / "skipped.json").write_text(
        json.dumps(
            {"commit": L.CSE_COMMIT, "total": n_skip, "by_file": skipped}, indent=2
        )
        + "\n",
        encoding="utf-8",
    )
    print(
        f"files {n_files}; questions in scope {n_scope}; skipped {n_skip}; "
        f"to solve {n_solve}; with pinned last choice {n_pinned}"
    )


if __name__ == "__main__":
    main()
