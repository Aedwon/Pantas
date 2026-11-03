#!/usr/bin/env python3
"""Build one rewrite brief per CET pilot lesson (plan 2026-11-03-cet-content-pilot, Task 1).

Run: python3 -I tools/content_rewrite/build_cet_briefs.py
Python 3.9, standard library only. Output is deterministic.

Inputs, all read with `git show`:
  the base revision                  the lesson file (its frontmatter _id)
  the audit revision, under docs/content/audit/coverage-r1/
    lesson-exam-tags.json            the tagged exams of each lesson
    topics/<subject>-<topic>-lessons.md   the `### <lesson id>` or `## <lesson id>` section, kept verbatim
    lesson-structure-data.json       the Level 3 verdict of each facet of the lesson, by exact lesson id
    requirement-teaching-findings.md      rows that name the lesson's topic as a provider

A lesson that does not resolve is reported and gets no brief. The script then exits 2.
A section is the one under the exact heading `### <lesson id>` or `## <lesson id>`. Nothing is matched by name.
When an id has no heading at any level in its topic file, the brief is built from the facets of that exact id in
lesson-structure-data.json and says so. An id found nowhere is reported and gets no brief.
"""
import argparse
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent / "relay"))

import rw_lib  # noqa: E402  (also puts the vendored l4 folder on the path)

import l4lib  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
PILOT_REL = "docs/content/rewrite/cet/pilot.json"
OUT_REL = "docs/content/rewrite/cet/briefs"
AUDIT_DIR = "docs/content/audit/coverage-r1"
# Pinned so the briefs do not change when either branch moves. Override with --base and --audit.
BASE_REF = "7032eec5b8fbdac51cef7e7b6dc7272d0e965f9a"   # origin/content/cse-rewrite-r1
AUDIT_REF = "ecbfa88b4e550fd5853d9ff74c1ae17425a1cdba"  # origin/docs/content-coverage-audit-r1
SCOPE_EXAMS = ("upcat", "dcat", "ustet", "acet")
ROW_CAP = 25
GAP_WORDS = ("thin", "named-only", "absent")

STRUCTURE_RE = re.compile(r"^Structure: (?P<verdict>[a-z-]+)\.")


class BriefError(Exception):
    pass


# ---- audit topic file ----------------------------------------------------------

def find_section_with_heading(md, lesson_id):
    """(heading, text) for the exact heading `### <lesson id>` or `## <lesson id>`, or None.

    The text runs to the next heading of the same or a higher level.
    """
    lines = md.split("\n")
    for marker in ("###", "##"):
        for number, line in enumerate(lines):
            if line.rstrip() == "%s %s" % (marker, lesson_id):
                end = len(lines)
                for later in range(number + 1, len(lines)):
                    head = re.match(r"(#{1,6}) ", lines[later])
                    if head and len(head.group(1)) <= len(marker):
                        end = later
                        break
                return "%s %s" % (marker, lesson_id), "\n".join(lines[number + 1:end]).strip("\n")
    return None


def find_section(md, lesson_id):
    found = find_section_with_heading(md, lesson_id)
    return found[1] if found else None


def where_id_appears(md, lesson_id):
    """Where the exact id shows up, for the report on a section that does not resolve."""
    found, others = [], []
    for number, line in enumerate(md.split("\n"), 1):
        if lesson_id not in line:
            continue
        if re.match(r"#{1,6} ", line) and re.search(r"(?<![\w-])%s(?![\w-])" % re.escape(lesson_id), line):
            found.append("line %d: %s" % (number, line.strip()))
        else:
            others.append(number)
    if others:
        found.append("%d other lines name the id, first at line %d" % (len(others), others[0]))
    return found


def id_in_a_heading(md, lesson_id):
    return any(row.startswith("line") and ": #" in row for row in where_id_appears(md, lesson_id))


def parse_section(section):
    """{"goal", "structure", "verdict"}: the Goal line and the Structure line of an audit section.

    The facet lines differ between topic files, so the facet verdicts come from lesson-structure-data.json.
    """
    goal = structure = verdict = None
    for line in section.split("\n"):
        # Some topic files write "**Learning goal:**" and "**Structure: retain.**" with bold labels.
        line = line.replace("**", "")
        if line.startswith("Learning goal:"):
            line = "Goal:" + line[len("Learning goal:"):]
        if line.startswith("Goal:") and goal is None:
            goal = line
        elif line.startswith("Structure:") and structure is None:
            structure = line
            match = STRUCTURE_RE.match(line)
            if not match:
                raise BriefError("the Structure line has no verdict word: %s" % line[:80])
            verdict = match.group("verdict")
    if goal is None:
        raise BriefError("the section has no Goal line")
    if structure is None:
        raise BriefError("the section has no Structure line")
    return {"goal": goal, "structure": structure, "verdict": verdict}


def lesson_record(data, subject, topic, lesson_id):
    """The record of one lesson in lesson-structure-data.json, found by exact subject, topic and id."""
    for record in data["topicRecords"]:
        if record["subject"] == subject and record["topic"] == topic:
            for lesson in record["lessons"]:
                if lesson["id"] == lesson_id:
                    return lesson
    raise BriefError("lesson-structure-data.json has no record of the lesson under %s/%s" % (subject, topic))


def lesson_facets(data, subject, topic, lesson_id):
    """The facets of one lesson from lesson-structure-data.json, found by exact subject, topic and id."""
    lesson = lesson_record(data, subject, topic, lesson_id)
    if not lesson["skills"]:
        raise BriefError("lesson-structure-data.json lists no facets for the lesson")
    return [{"name": s["name"], "teaching": s["teachingVerdict"], "examples": s["exampleVerdict"],
             "refs": list(s["requirementRefs"]), "limits": list(s["limitations"])}
            for s in lesson["skills"]]


# ---- requirement rows ----------------------------------------------------------

def parse_rows(md):
    """Every row of requirement-teaching-findings.md, in file order."""
    rows, exam = [], None
    for number, line in enumerate(md.split("\n"), 1):
        if line.startswith("## "):
            exam = line[3:].strip()
            continue
        if not line.startswith("| ") or line.startswith("| Source record") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip()[1:-1].split(" | ")]
        if len(cells) != 4 or exam is None:
            raise BriefError("requirement row at line %d does not have 4 cells under an exam heading" % number)
        providers = re.search(r"providers: (.*)$", cells[3])
        gaps = {word: 0 for word in GAP_WORDS}
        if cells[2].startswith("Observed local facets:"):
            for word in GAP_WORDS:
                found = re.search(r"(?<![\w-])%s=(\d+)" % re.escape(word), cells[2])
                gaps[word] = int(found.group(1)) if found else 0
        rows.append({"exam": exam, "id": cells[0].strip(), "statement": cells[1], "finding": cells[2],
                     "providers": providers.group(1).split(", ") if providers else [], "gaps": gaps})
    return rows


def select_rows(rows, topic, tags, cap=ROW_CAP):
    """(rows to show, number of matching rows).

    A row matches when its exam is a tagged one among SCOPE_EXAMS, the topic is one of its providers, and the
    Level 3 finding counts a thin, named-only or absent facet. Inside an exam the rows with the most such facets
    come first, then file order. The cap is shared by round robin over the exams, so one exam cannot fill it.
    """
    per_exam = []
    for exam in SCOPE_EXAMS:
        if exam not in tags:
            continue
        matched = [(index, row) for index, row in enumerate(rows)
                   if row["exam"] == exam and topic in row["providers"] and sum(row["gaps"].values()) > 0]
        matched.sort(key=lambda pair: (-sum(pair[1]["gaps"].values()), pair[0]))
        per_exam.append([row for _, row in matched])
    total = sum(len(group) for group in per_exam)
    taken = [0] * len(per_exam)
    chosen = 0
    while chosen < min(cap, total):
        for position, group in enumerate(per_exam):
            if taken[position] < len(group) and chosen < cap:
                taken[position] += 1
                chosen += 1
    shown = []
    for position, group in enumerate(per_exam):
        shown.extend(group[:taken[position]])
    return shown, total


def class_tail(statement):
    """The evidence text as the audit wrote it: the last bracket of the accepted statement and what follows it."""
    if "[" not in statement:
        return ""
    return statement[statement.rindex("["):].strip()


# ---- brief ---------------------------------------------------------------------

def render_brief(title, lesson_id, path, tags, heading, section, info, goal_text, facets, shown, total, all_rows, topic_file, base_ref,
                audit_ref):
    scope = [e for e in SCOPE_EXAMS if e in tags]
    by_id = {}
    for row in all_rows:
        by_id.setdefault(row["id"], row)
    out = ["# Brief: %s" % title, "",
           "Lesson id: `%s`" % lesson_id,
           "Lesson path: `%s`" % path, "",
           "Tagged exams (as the audit writes them): %s" % (", ".join(tags) or "(none)"),
           "Exams used for the requirement rows below: %s" % (", ".join(scope) or "(none of upcat, dcat, ustet, acet)"),
           "",
           "Standing rule: a rewrite may add teaching, but no case that another tagged exam needs is removed.",
           "",
           "Sources: lesson at base revision %s; audit revision %s, %s, and "
           "`%s/lesson-structure-data.json` and `%s/requirement-teaching-findings.md`."
           % (base_ref, audit_ref,
              "`%s/topics/%s`, section `%s`" % (AUDIT_DIR, topic_file, heading) if section is not None
              else "`%s/topics/%s` (which has no section for this lesson)" % (AUDIT_DIR, topic_file),
              AUDIT_DIR, AUDIT_DIR),
           "",
           "## Audit findings for this lesson", "",
           ] + (["Verbatim from the audit section. Its line references point into the audit's pinned corpus, not into "
                 "this branch.", "", section.strip("\n"), ""] if section is not None else
                ["NO TOPIC SECTION. The topic artifact `%s` has no heading for this lesson id at any level. The "
                 "findings below come from the facets of this exact id in lesson-structure-data.json. The artifact's "
                 "general findings may discuss this lesson by name; they are not matched here." % topic_file, "",
                 "Goal: %s" % goal_text, ""])

    out += ["## Thin, named-only or absent items", "",
            "From the audit's lesson-structure-data.json, by exact lesson id. Teaching verdict first, then the "
            "verdict on the examples.", ""]
    gaps = [f for f in facets if f["teaching"] in GAP_WORDS]
    refs = []
    if not gaps:
        out += ["None. Every facet is explained.", ""]
    for facet in gaps:
        line = "- %s: %s; examples %s." % (facet["name"], facet["teaching"], facet["examples"])
        if facet["limits"]:
            line += " Limits: %s." % "; ".join(l.rstrip(".") for l in facet["limits"])
        out.append(line + " Requirement refs: %s." % (", ".join(facet["refs"]) or "none"))
        refs += [r for r in facet["refs"] if r not in refs]
    if gaps:
        out.append("")
    thin_examples = [f for f in facets if f["teaching"] == "explained" and f["examples"] in ("thin", "none")]
    if thin_examples:
        out += ["Explained, but the examples are thin or missing:", ""]
        for facet in thin_examples:
            line = "- %s: examples %s." % (facet["name"], facet["examples"])
            if facet["limits"]:
                line += " Limits: %s." % "; ".join(l.rstrip(".") for l in facet["limits"])
            out.append(line + " Requirement refs: %s." % (", ".join(facet["refs"]) or "none"))
            refs += [r for r in facet["refs"] if r not in refs]
        out.append("")
    if refs:
        out += ["Evidence class, as the audit writes it in the accepted statement of each ref above "
                "(the last bracket and what follows it):", ""]
        for ref in refs:
            row = by_id.get(ref)
            if row is None:
                out.append("- %s: no row in requirement-teaching-findings.md. Class: not given." % ref)
            else:
                out.append("- %s: %s" % (ref, class_tail(row["statement"]) or "no bracket in the statement. Class: not given."))
        out.append("")

    out += ["## Split or reorder candidate", ""]
    if info is None:
        out += ["None attached. The audit has no section for this lesson, so no Structure verdict can be tied to its "
                "exact id. The pilot makes no splits or reorders in any case.", ""]
    elif info["verdict"] == "retain":
        out += ["The audit recommends keeping the structure.", "", info["structure"], ""]
    else:
        out += ["NOT TO APPLY. Record it only. The run makes no splits or reorders. If the lesson runs over about "
                "3,000 words, report it as a split candidate.", "", info["structure"], ""]

    out += ["## Requirement rows", "",
            "Rows of the audit's requirement-teaching-findings.md whose providers include `%s`, for the tagged "
            "exams among upcat, dcat, ustet and acet, whose Level 3 finding counts thin, named-only or absent "
            "facets. The counts cover every provider of the row, not only this topic. Within an exam, rows with "
            "more such facets come first; the cap of %d is shared across exams. Source record ids and evidence "
            "class words are as the audit wrote them." % (topic_file.replace("-lessons.md", ""), ROW_CAP), "",
            "Matching rows: %d. Shown: %d." % (total, len(shown)), ""]
    if not shown:
        out += ["None.", ""]
    current = None
    for row in shown:
        if row["exam"] != current:
            current = row["exam"]
            out += ["### %s" % current, ""]
        out += ["- %s" % row["id"],
                "  - Accepted statement: %s" % row["statement"],
                "  - Level 3 finding: %s" % row["finding"]]
        out.append("")
    return "\n".join(out).rstrip("\n") + "\n"


def build_all(pilot, show, base_ref, audit_ref):
    """(briefs {lesson id: markdown}, problems [str]). `show(ref, path)` returns file text or None."""
    cache = {}

    def audit(rel):
        path = "%s/%s" % (AUDIT_DIR, rel)
        if path not in cache:
            cache[path] = show(audit_ref, path)
        return cache[path]

    briefs, problems = {}, []
    tags_text = audit("lesson-exam-tags.json")
    tag_lessons = {}
    if tags_text is None:
        return briefs, ["audit file lesson-exam-tags.json not found at %s" % audit_ref]
    for entry in json.loads(tags_text)["lessons"]:
        tag_lessons[entry["metadata__id"]] = entry
    data_text = audit("lesson-structure-data.json")
    if data_text is None:
        return briefs, ["audit file lesson-structure-data.json not found at %s" % audit_ref]
    structure_data = json.loads(data_text)
    rows_text = audit("requirement-teaching-findings.md")
    if rows_text is None:
        return briefs, ["audit file requirement-teaching-findings.md not found at %s" % audit_ref]
    all_rows = parse_rows(rows_text)

    for item in pilot:
        label = item["lesson"]
        parts = label.split("/")
        if len(parts) != 3:
            problems.append("%s: pilot entry is not subject/topic/slug" % label)
            continue
        path = "content/lessons/%s.md" % label
        text = show(base_ref, path)
        if text is None:
            problems.append("%s: no lesson file at %s in the base revision" % (label, path))
            continue
        try:
            lesson_id = l4lib.parse_lesson(text)["frontmatter"].get("_id")
        except l4lib.L4Error as err:
            problems.append("%s: the lesson does not parse (%s)" % (label, err))
            continue
        entry = tag_lessons.get(lesson_id)
        if entry is None:
            problems.append("%s: frontmatter _id %s is not in lesson-exam-tags.json" % (label, lesson_id))
            continue
        if entry["path"] != path or (entry["subject"], entry["topic"], entry["slug"]) != tuple(parts):
            problems.append("%s: %s is listed in lesson-exam-tags.json at %s, not this path"
                            % (label, lesson_id, entry["path"]))
            continue
        topic_file = "%s-%s-lessons.md" % (parts[0], parts[1])
        topic_md = audit("topics/" + topic_file)
        if topic_md is None:
            problems.append("%s: %s: topic file topics/%s not found" % (label, lesson_id, topic_file))
            continue
        found = find_section_with_heading(topic_md, lesson_id)
        heading = section = info = None
        if found is None:
            if id_in_a_heading(topic_md, lesson_id):
                where = where_id_appears(topic_md, lesson_id)
                problems.append("%s: %s: the id is a heading in topics/%s at a level other than ## or ###: %s"
                                % (label, lesson_id, topic_file, "; ".join(where)))
                continue
            # No heading at any level: the facets of this exact id in lesson-structure-data.json carry the findings.
        else:
            heading, section = found
            try:
                info = parse_section(section)
            except BriefError as err:
                problems.append("%s: %s: %s" % (label, lesson_id, err))
                continue
        try:
            facets = lesson_facets(structure_data, parts[0], parts[1], lesson_id)
            goal_text = lesson_record(structure_data, parts[0], parts[1], lesson_id).get("goal", "")
        except BriefError as err:
            problems.append("%s: %s: %s" % (label, lesson_id, err))
            continue
        tags = list(entry.get("provisionalExamTags") or [])
        topic = "%s-%s" % (parts[0], parts[1])
        shown, total = select_rows(all_rows, topic, tags)
        title = entry.get("metadata_title") or lesson_id
        briefs[lesson_id] = render_brief(title, lesson_id, path, tags, heading, section, info, goal_text, facets, shown, total,
                                         all_rows, topic_file, base_ref, audit_ref)
    return briefs, problems


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--pilot", default=str(ROOT / PILOT_REL))
    ap.add_argument("--out", default=str(ROOT / OUT_REL))
    ap.add_argument("--base", default=BASE_REF)
    ap.add_argument("--audit", default=AUDIT_REF)
    args = ap.parse_args(argv)
    with open(args.pilot, encoding="utf-8") as handle:
        pilot = json.load(handle)["lessons"]
    git = rw_lib.Git(ROOT)

    def show(ref, path):
        return git.show("%s:%s" % (ref, path))

    briefs, problems = build_all(pilot, show, args.base, args.audit)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    for lesson_id, text in sorted(briefs.items()):
        (out_dir / (lesson_id + ".md")).write_text(text, encoding="utf-8")
    print("briefs written: %d of %d" % (len(briefs), len(pilot)))
    for lesson_id, text in sorted(briefs.items()):
        shown = re.search(r"Matching rows: (\d+)\. Shown: (\d+)\.", text)
        section = text.split("## Audit findings for this lesson")[1].split("## Thin, named-only or absent items")[0]
        source = "no topic section, facets only" if "NO TOPIC SECTION" in section else "section %d words" % len(section.split())
        gaps = text.split("## Thin, named-only or absent items")[1].split("## Split or reorder candidate")[0]
        print("  %s: %s, gap lines %d, rows %s of %s"
              % (lesson_id, source, len(re.findall(r"^- .+: (?:thin|named-only|absent);", gaps, re.M)),
                 shown.group(2), shown.group(1)))
    if problems:
        print("UNRESOLVED (%d). No brief was written for these:" % len(problems))
        for problem in problems:
            print("  " + problem)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
