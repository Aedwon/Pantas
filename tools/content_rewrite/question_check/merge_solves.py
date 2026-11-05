"""Compare solver answers with the keys and write per-file results.

  python3 -I merge_solves.py --keys DIR/keys --answers ANSWERS --out RESULTS

Answers are <file-id>.json: [{"n": 1, "answer": "C", "confidence": "high",
"note": "..."}]. Writes RESULTS/<file-id>.json and RESULTS/mismatches.json
(every mismatch, low-confidence answer, invalid or missing answer).
"""
import argparse
import json
import sys
from pathlib import Path

LETTERS = "ABCDEFGHIJKLMNOP"
CONF = {"high", "medium", "low"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--keys", required=True)
    ap.add_argument("--answers", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    flagged, missing_files = [], []
    totals = dict(files=0, questions=0, match=0, mismatch=0, low=0, problem=0)

    for kpath in sorted(Path(a.keys).glob("*.json")):
        keyfile = json.loads(kpath.read_text(encoding="utf-8"))
        fid = keyfile["file_id"]
        apath = Path(a.answers) / f"{fid}.json"
        if not apath.exists():
            missing_files.append(fid)
            continue
        answers = {}
        for row in json.loads(apath.read_text(encoding="utf-8")):
            answers.setdefault(row.get("n"), row)
        results = []
        for kq in keyfile["questions"]:
            row = answers.get(kq["n"])
            reasons = []
            letter = conf = note = None
            if row is None:
                reasons.append("unanswered")
            else:
                letter = str(row.get("answer", "")).strip().upper()
                conf = str(row.get("confidence", "")).strip().lower()
                note = row.get("note")
                if letter not in LETTERS[: len(kq["order"])]:
                    reasons.append("invalid-answer")
                elif letter != kq["correct"]:
                    reasons.append("mismatch")
                if conf not in CONF:
                    reasons.append("invalid-confidence")
                elif conf == "low":
                    reasons.append("low-confidence")
            match = letter == kq["correct"]
            results.append(
                {
                    "n": kq["n"],
                    "id": kq["id"],
                    "key": kq["correct"],
                    "answer": letter,
                    "match": match,
                    "confidence": conf,
                    "note": note,
                }
            )
            totals["questions"] += 1
            totals["match"] += match
            if reasons:
                if "mismatch" in reasons:
                    totals["mismatch"] += 1
                if "low-confidence" in reasons:
                    totals["low"] += 1
                if set(reasons) & {"unanswered", "invalid-answer", "invalid-confidence"}:
                    totals["problem"] += 1
                flagged.append(
                    {
                        "file_id": fid,
                        "n": kq["n"],
                        "id": kq["id"],
                        "key": kq["correct"],
                        "answer": letter,
                        "confidence": conf,
                        "reasons": reasons,
                        "note": note,
                    }
                )
        extra = sorted(set(answers) - {kq["n"] for kq in keyfile["questions"]}, key=str)
        (out / f"{fid}.json").write_text(
            json.dumps(
                {"file_id": fid, "source": keyfile.get("source"), "results": results,
                 "unknown_answer_numbers": extra},
                indent=2, ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        totals["files"] += 1

    (out / "mismatches.json").write_text(
        json.dumps(
            {"totals": totals, "files_without_answers": missing_files, "flagged": flagged},
            indent=2, ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    print(json.dumps(totals), f"files without answers: {len(missing_files)}")


if __name__ == "__main__":
    main()
