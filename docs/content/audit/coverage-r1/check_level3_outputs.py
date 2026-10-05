"""Read-only validation of Level3 topic evidence and complete lesson accounting."""
from pathlib import Path
from collections import Counter
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parent
CORPUS = Path('/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2')
REPO = ROOT.parents[3]
manifest = json.loads((ROOT / 'structure-input-manifest.json').read_text())
requirements = {x['id'] for x in json.loads((ROOT / 'requirement-map.json').read_text())['rows']}
expected = manifest['lessons']
errors = []
complete, pending, all_lessons, edges = [], [], {}, {}

def evidence_walk(obj, where):
    if isinstance(obj, dict):
        if 'path' in obj and 'lines' in obj:
            p, lines = obj['path'], obj['lines']
            source = CORPUS / p
            if not p.startswith('content/lessons/') or not source.is_file():
                errors.append(f'{where}: invalid lesson evidence path {p}')
            elif not isinstance(lines, list) or len(lines) != 2 or not all(isinstance(v, int) for v in lines) or not 1 <= lines[0] <= lines[1] <= len(source.read_text().splitlines()):
                errors.append(f'{where}: invalid evidence lines {p}:{lines}')
        if 'requirementRefs' in obj:
            for ref in obj['requirementRefs']:
                if ref not in requirements:
                    errors.append(f'{where}: unknown requirement {ref}')
        for k, v in obj.items():
            evidence_walk(v, where + '/' + k)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            evidence_walk(v, where + '/' + str(i))

for t in manifest['topics']:
    path = REPO / t['output']
    if not path.exists():
        pending.append(t['key'] + ':NOT_STARTED')
        continue
    blocks = re.findall(r'```json\s*\n(.*?)\n```', path.read_text(), re.S)
    if len(blocks) != 1:
        errors.append(t['key'] + ': need exactly one JSON appendix')
        continue
    try:
        data = json.loads(blocks[0])
    except json.JSONDecodeError as ex:
        errors.append(t['key'] + ': invalid JSON ' + str(ex))
        continue
    if data.get('status') != 'COMPLETE':
        pending.append(t['key'] + ':' + data.get('status', 'missing state'))
        continue
    complete.append(t['key'])
    if data.get('corpusCommit') != manifest['corpusCommit'] or data.get('policyCommit') not in manifest.get('compatiblePolicyCommits', [manifest['policyCommit']]) or data.get('level') != 3:
        errors.append(t['key'] + ': identity mismatch')
    lessons = data.get('lessons', [])
    counts = Counter(l.get('id') for l in lessons)
    if set(counts) != set(t['lessonIds']) or any(v != 1 for v in counts.values()):
        errors.append(t['key'] + ': assigned ID accounting mismatch')
    for lesson in lessons:
        lid = lesson.get('id')
        if lid not in expected:
            errors.append(t['key'] + ': unknown lesson ' + str(lid))
            continue
        exp = expected[lid]
        if lesson.get('path') != exp['path'] or lesson.get('sha256') != exp['sha256'] or lesson.get('readLines') != [1, exp['lines']]:
            errors.append(lid + ': read identity mismatch')
        if hashlib.sha256((CORPUS / exp['path']).read_bytes()).hexdigest() != exp['sha256']:
            errors.append(lid + ': corpus input changed')
        required = ['goal', 'skills', 'examApplicability', 'structure', 'prerequisites', 'prerequisiteStatus', 'missingFoundations', 'figureDependencies', 'availability', 'practice']
        for k in required:
            if k not in lesson:
                errors.append(lid + ': missing field ' + k)
        deps = lesson.get('prerequisites', [])
        edges[lid] = []
        for dep in deps:
            target = dep.get('lessonId')
            if target not in expected or target == lid:
                errors.append(lid + ': missing/self prerequisite ' + str(target))
            else:
                edges[lid].append(target)
            if not dep.get('consumerEvidence') or not dep.get('foundationEvidence'):
                errors.append(lid + ': missing both-end prerequisite evidence')
        if deps and lesson.get('prerequisiteStatus') != 'links-found':
            errors.append(lid + ': prerequisite status conflicts with links')
        if not deps and lesson.get('prerequisiteStatus') == 'links-found':
            errors.append(lid + ': links-found with no links')
        all_lessons[lid] = lesson
    evidence_walk(data, t['key'])

visiting, visited = set(), set()
def visit(lid):
    if lid in visiting:
        errors.append('dependency cycle through ' + lid)
        return
    if lid in visited:
        return
    visiting.add(lid)
    for target in edges.get(lid, []):
        visit(target)
    visiting.remove(lid)
    visited.add(lid)
for lid in edges:
    visit(lid)
print(json.dumps({'level': 3, 'completeTopics': len(complete), 'expectedTopics': len(manifest['topics']), 'completeLessons': len(all_lessons), 'expectedLessons': len(expected), 'complete': complete, 'pending': pending, 'errors': errors, 'gateReady': not errors and len(all_lessons) == len(expected)}, indent=2))
raise SystemExit(1 if errors else 0)
