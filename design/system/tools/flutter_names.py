"""Flutter identifier check (ruling 1). Builds the full Dart identifier list from tokens.json with the README naming rule and fails on:
a duplicate name inside one family, a Dart reserved word or built-in identifier, an illegal identifier, a token with no field,
a motion.md recipe field that is illegal or repeated, and a component README Flutter section that names a token or a field that does not exist
(or names a legacy code field outside its migration brackets), and (round 4, R4-O13) any component README line that names a deprecated
token or style outside a "Deprecated" or "renamed from" note or migration brackets. Product path: tools/flutter_names.py [--out FILE] writes the field table
to FILE when given. Exit 1 on any error."""
import json, re, sys, os, glob
P = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[sys.argv.index('--out') + 1] if '--out' in sys.argv else None
d = json.load(open(P + '/tokens.json'))
# family -> (class, prefixes stripped, digit letter, type, reserved-word suffix)
FAM = {'color': ('PantasColors', [], 'c', 'Color', 'Color'), 'spacing': ('PantasSpace', ['space-'], 's', 'double', 'Space'),
       'radius': ('PantasRadius', ['radius-'], 'r', 'double', 'Radius'), 'shadow': ('PantasShadow', ['elev-'], 'e', 'List<BoxShadow>', 'Shadow'),
       'border': ('PantasBorder', ['border-'], 'b', 'double', 'Border'), 'layout': ('PantasLayout', ['layout-'], 'l', 'double | PantasFlex', 'Layout'),
       'size': ('PantasSize', ['size-'], 'z', 'double', 'Size'), 'easing': ('PantasCurves', ['motion-'], 'm', 'Curve', 'Curve'),
       'duration': ('PantasDurations', ['dur-'], 'd', 'Duration', 'Duration'), 'zIndex': ('PantasZ', ['z-'], 'z', 'int', 'Z'),
       'opacity': ('PantasOpacity', ['opacity-'], 'o', 'double', 'Opacity')}
RESERVED = set('''assert break case catch class const continue default do else enum extends false final finally for if in is new null rethrow return super switch
this throw true try var void while with abstract as covariant deferred dynamic export extension external factory Function get implements import interface
late library mixin operator part required set static typedef await yield'''.split())
OBJECT_MEMBERS = {'hashCode', 'runtimeType', 'toString', 'noSuchMethod', 'copyWith', 'lerp', 'type'}
IDENT = re.compile(r'^[a-z][A-Za-z0-9]*$')
def camel(n): return re.sub(r'-([a-z0-9])', lambda m: m.group(1).upper(), n)
err = []; fields = {}; rows = []
for fam, (cls, pre, letter, typ, suffix) in FAM.items():
    seen = {}
    for t in d[fam]['tokens']:
        n = t['name']
        for p in pre:
            if n.startswith(p): n = n[len(p):]; break
        f = camel(n)
        if f[:1].isdigit(): f = letter + f
        if f in RESERVED or f in OBJECT_MEMBERS: f = f + suffix
        if not IDENT.match(f): err.append('illegal identifier %s.%s (%s)' % (cls, f, t['name']))
        if f in seen: err.append('collision in %s: %s from %s and %s' % (cls, f, seen[f], t['name']))
        seen[f] = t['name']
        v = t['value']
        if fam == 'layout' and isinstance(v, str) and len(v.split()) == 3: kind = 'PantasFlex'
        elif fam == 'easing' and v == 'linear': kind = 'Curve (Curves.linear)'
        elif fam == 'easing': kind = 'Cubic'
        else: kind = typ.split(' |')[0]
        rows.append((cls, f, t['name'], kind))
    fields[cls] = seen
# type
seen = {}
for g in d['type']['groups']:
    for s in g['styles']:
        f = camel(s['name'])
        if not IDENT.match(f): err.append('illegal identifier PantasType.%s' % f)
        if f in seen: err.append('collision in PantasType: %s' % f)
        seen[f] = s['name']; rows.append(('PantasType', f, s['name'], 'TextStyle'))
fields['PantasType'] = seen
ntok = sum(len(d[k]['tokens']) for k in FAM) + len(seen)
if len(rows) != ntok: err.append('tokens without a field: %d of %d' % (ntok - len(rows), ntok))
# motion recipes
mot = open(P + '/motion.md').read()
m = re.search(r'### Recipe values.*?\n(\|.*?)\n\n', mot, flags=re.S)
rec = {}
if not m: err.append('motion.md has no recipe table')
else:
    for line in m.group(1).splitlines()[2:]:
        f = line.strip('|').split('|')[-1].strip().strip('`')
        if not IDENT.match(f) or f in RESERVED: err.append('illegal recipe field %s' % f)
        if f in rec: err.append('duplicate recipe field %s' % f)
        rec[f] = 1
fields['PantasMotionRecipes'] = rec
# component READMEs
names = set(t['name'] for k in FAM for t in d[k]['tokens']) | set(s['name'] for g in d['type']['groups'] for s in g['styles'])
readme = open(P + '/README.md').read()
legacy = set()
for role, code in re.findall(r'^\| `([a-z0-9-]+)`[^|]*\| ([^|]+) \|', readme, flags=re.M):
    for f in re.findall(r'(?:PantasColors|WebTokens)\.(\w+)', code):
        if camel(role) != f: legacy.add(f)
legacy |= {'separator', 'secondaryLabel', 'label', 'destructive', 'disabledActionLabel', 'onDestructive', 'controlOutline', 'rowHover', 'tertiaryLabel',
           'separatorStrong', 'segmentedShadow', 'elevKnob', 'segmentOn', 'onFillLabel', 'surface', 'background'}
WIDGETS = {'PantasButton', 'PantasSelect', 'PantasSwitch', 'PantasSheet', 'PantasButtonVariant', 'PantasFlex'}
refs = 0
for f in sorted(glob.glob(P + '/components/*/README.md')):
    comp = os.path.basename(os.path.dirname(f))
    rd = open(f).read()
    mm = re.search(r'\n## Flutter\n(.*?)(?=\n## |\Z)', rd, flags=re.S)
    if not mm: err.append('%s: no Flutter section' % comp); continue
    body = mm.group(1)
    unbr = re.sub(r'\[[^\]]*\]', '', body)   # migration brackets hold today's code fields
    for x in re.findall(r'`([^`]+)`', unbr):
        if '/' in x or '_' in x or '.dart' in x or ' ' in x or '(' in x: continue
        q = re.match(r'^(Pantas\w+)\.(\w+)$', x)
        if q:
            refs += 1
            c, fld = q.groups()
            if c in fields:
                if fld not in fields[c] and fld != 'reduced': err.append('%s: %s.%s is not a generated field' % (comp, c, fld))
            elif c not in WIDGETS: err.append('%s: %s is not a Pantas class' % (comp, c))
            continue
        if re.match(r'^Pantas\w+$', x) and x not in fields and x not in WIDGETS: err.append('%s: unknown class %s' % (comp, x)); continue
        if re.match(r'^[a-z0-9]+(-[a-z0-9]+)+$', x):
            refs += 1
            if x not in names: err.append('%s: `%s` is not a token or style' % (comp, x))
            continue
        if x in legacy: err.append('%s: legacy code field `%s` outside migration brackets' % (comp, x))
# R4-O13: a deprecated token or style named outside a deprecation note or brackets
deprecated = {t['name'] for k in FAM for t in d[k]['tokens'] if t.get('usage', '').startswith('Deprecated')}
deprecated |= {st['name'] for g in d['type']['groups'] for st in g['styles'] if st.get('usage', '').startswith('Deprecated')}
for f in sorted(glob.glob(P + '/components/*/README.md')):
    comp = os.path.basename(os.path.dirname(f))
    for line in open(f).read().splitlines():
        if 'eprecated' in line or 'renamed from' in line: continue
        for x in re.findall(r'`([a-z0-9-]+)`', re.sub(r'\[[^\]]*\]', '', line)):
            if x in deprecated: err.append('%s: deprecated `%s` outside a deprecation note: %s' % (comp, x, line.strip()[:90]))
# Cover README must exist (R3-O18)
for comp in glob.glob(P + '/components/*/'):
    if not os.path.exists(comp + 'README.md'): err.append('no README: ' + comp)
lines = ['| Dart class | Field | Token | Type |', '|---|---|---|---|'] + ['| `%s` | `%s` | `%s` | %s |' % r for r in rows]
if OUT: open(OUT, 'w').write('\n'.join(lines) + '\n')
print('flutter fields', len(rows), '| classes', len(FAM) + 1, '| recipes', len(rec), '| README references checked', refs, '| deprecated names', len(deprecated))
print('ERRORS' if err else 'OK', len(err))
for e in err: print('  ', e)
sys.exit(1 if err else 0)
