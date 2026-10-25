#!/usr/bin/env python3
"""The decisions of the CSE hand-in workflow, kept in Python so they can be tested.

Usage (the workflow calls these; every input comes from environment variables or files, never from the command
line, because a branch name is chosen by whoever opens the pull request):
  pr_guard.py guard    HEAD_REPO AUTHOR HEAD_REF BASE_REF LABELS   -> outputs run, batch; writes the ignored comment
  pr_guard.py decide   --exit-code N --head SHA --comments FILE --report FILE --out FILE
                                                                    -> outputs verdict, comment_id; writes the comment

guard   runs the hand-in only for a pull request from Aedwon/Pantas, opened by Aedwon, from a cse-inbox/<batch id>
        branch into the rewrite branch, and not held. Anything else is ignored.
decide  turns the check's exit code and report into the one bot comment, counts earlier rejections from that
        comment, and says what the workflow does next: merge, ask for a fix, or hold. The third rejection holds.
Python 3.9 standard library only.
"""
import argparse
import json
import os
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True

REPO = "Aedwon/Pantas"
AUTHOR = "Aedwon"
BASE_BRANCH = "content/cse-rewrite-r1"
BRANCH_PATTERN = re.compile(r"cse-inbox/([A-Z]{2}-\d{3})")
HELD_LABEL = "held"
BOT_LOGIN = "github-actions[bot]"
MAX_REJECTIONS = 3   # the third rejected head holds the pull request: two fixes are allowed
MARKER = re.compile(r"<!-- cse-handin-bot rejected=([0-9a-f,]*) -->")


# ---- who may hand in -----------------------------------------------------------

def evaluate(head_repo, author, head_ref, base_ref, labels, repo=REPO, user=AUTHOR):
    """(run, batch id, reason). The reasons are fixed texts: they never repeat what the pull request says."""
    if (head_repo or "").lower() != repo.lower():
        return False, "", "the pull request does not come from a branch in %s" % repo
    if (author or "").lower() != user.lower():
        return False, "", "only %s may hand in" % user
    if base_ref != BASE_BRANCH:
        return False, "", "the pull request does not go into %s" % BASE_BRANCH
    match = BRANCH_PATTERN.fullmatch(head_ref or "")
    if not match:
        return False, "", "the branch name is not cse-inbox/ followed by a batch id"
    if HELD_LABEL in (labels or []):
        return False, "", "the pull request is held and waits for the lead"
    return True, match.group(1), ""


def ignored_comment(reason):
    return "## IGNORED\n\nThe CSE hand-in check did not run: %s." % reason


# ---- the bot comment and the rejection count ----------------------------------

def parse_comments(text):
    """Comments from `gh api --paginate`, which may print several JSON arrays one after another."""
    decoder, index, comments = json.JSONDecoder(), 0, []
    text = text.strip()
    while index < len(text):
        value, end = decoder.raw_decode(text, index)
        comments.extend(value if isinstance(value, list) else [value])
        index = end
        while index < len(text) and text[index].isspace():
            index += 1
    return comments


def find_bot_comment(comments):
    """(comment id, [rejected head commits]) from the bot's comment, or (None, [])."""
    for comment in comments:
        if (comment.get("user") or {}).get("login") != BOT_LOGIN:
            continue
        match = MARKER.search(comment.get("body") or "")
        if match:
            return comment["id"], [sha for sha in match.group(1).split(",") if sha]
    return None, []


def decide(code, head, earlier, report):
    """What the workflow does for this run: {verdict, rejected, body}.

    verdict  accepted (merge), rejected (the chat fixes it), held (the third rejection, or an error that needs
             the lead). A commit that was rejected before counts once, so running the check again changes nothing.
    """
    rejected = list(earlier)
    body = list(report[2:]) if report[:1] and report[0].startswith("## ") else list(report)
    while body and not body[0].strip():
        body.pop(0)
    if code == 0:
        verdict, heading, footer = "accepted", "## ACCEPTED", "Checked commit `%s`." % head[:8]
    elif code == 1:
        if head not in rejected:
            rejected.append(head)
        if len(rejected) >= MAX_REJECTIONS:
            verdict, heading = "held", "## HELD"
            footer = ("This pull request was rejected %d times and is now held for the lead. Do not commit "
                      "again. The reasons of the last check are below." % len(rejected))
        else:
            verdict, heading = "rejected", "## REJECTED"
            footer = "Rejection %d of %d. Checked commit `%s`." % (len(rejected), MAX_REJECTIONS, head[:8])
    else:
        verdict, heading, footer = "held", "## ERROR", "The pull request is held for the lead. Do not commit again."
    lines = ["<!-- cse-handin-bot rejected=%s -->" % ",".join(rejected), heading, ""]
    if verdict == "held" and code == 1:
        lines += [footer, ""] + body
    else:
        lines += body + ["", footer]
    return {"verdict": verdict, "rejected": rejected, "body": "\n".join(lines).rstrip("\n") + "\n"}


# ---- command line --------------------------------------------------------------

def _outputs(**values):
    """Write step outputs. A value is a short fixed word or an id that matched a pattern, never free text."""
    lines = "".join("%s=%s\n" % (key, value) for key, value in values.items())
    target = os.environ.get("GITHUB_OUTPUT")
    if target:
        with open(target, "a", encoding="utf-8") as handle:
            handle.write(lines)
    sys.stdout.write(lines)


def cmd_guard(out_file):
    labels = json.loads(os.environ.get("LABELS") or "[]")
    run, batch, reason = evaluate(os.environ.get("HEAD_REPO"), os.environ.get("AUTHOR"), os.environ.get("HEAD_REF"),
                                  os.environ.get("BASE_REF"), labels)
    if not run:
        Path(out_file).write_text(ignored_comment(reason) + "\n", encoding="utf-8")
    _outputs(run="true" if run else "false", batch=batch)
    return 0


def cmd_decide(args):
    comments = parse_comments(Path(args.comments).read_text(encoding="utf-8")) if Path(args.comments).exists() else []
    comment_id, earlier = find_bot_comment(comments)
    report = Path(args.report).read_text(encoding="utf-8").splitlines()
    result = decide(args.exit_code, args.head, earlier, report)
    Path(args.out).write_text(result["body"], encoding="utf-8")
    _outputs(verdict=result["verdict"], comment_id=comment_id or "")
    return 0


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    guard = sub.add_parser("guard")
    guard.add_argument("--ignored-file", required=True)
    decide_parser = sub.add_parser("decide")
    decide_parser.add_argument("--exit-code", type=int, required=True)
    decide_parser.add_argument("--head", required=True)
    decide_parser.add_argument("--comments", required=True)
    decide_parser.add_argument("--report", required=True)
    decide_parser.add_argument("--out", required=True)
    args = parser.parse_args(argv[1:])
    return cmd_guard(args.ignored_file) if args.command == "guard" else cmd_decide(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
