"""Pantas token validator. Product path: tools/validate.py. History: r2 validate.py, round 3 validate_r3.py (the round 3 inline data
properties allowed). Checks names, values, aliases, family sizes, bundle var() resolution and the primitive distance rule (R2-O21)."""
import json,re,sys,os
P=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))+'/'
d=json.load(open(P+'tokens.json'))
err=[]
NAME=re.compile(r'^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$')
HEX=re.compile(r'^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$')
FN=re.compile(r'^(rgb|rgba|hsl|hsla|oklch|oklab|lab|lch|color)\([0-9 .,%/a-z-]*\)$')
names=[]
colors={t['name']:t for t in d['color']['tokens']}
fams=[k for k,v in d.items() if isinstance(v,dict) and 'tokens' in v]
others=[k for k in fams if k not in ('color','shadow')]
if len([k for k in fams if k not in ('color','type','spacing','radius','shadow')])>12: err.append('too many families')
for k in fams:
    toks=d[k]['tokens']
    if k!='color' and len(toks)>60: err.append('%s has %d tokens'%(k,len(toks)))
    for t in toks:
        n=t['name']; names.append(n)
        if not NAME.match(n): err.append('bad name '+n)
        if len(t.get('usage',''))>1000: err.append('usage long '+n)
        if 'usage' not in t: err.append('no usage '+n)
dups={n for n in names if names.count(n)>1}
if dups: err.append('dups %s'%dups)
if len(colors)>600: err.append('too many colors')
def okc(v):
    return bool(HEX.match(v) or FN.match(v) or (v.startswith('{') and v.endswith('}')))
def res(n,theme,depth=0,seen=()):
    if depth>16: return None
    t=colors.get(n)
    if not t: return None
    v=t['value'] if isinstance(t['value'],str) else t['value'].get(theme, t['value'].get('light'))
    if v.startswith('{'):
        m=v[1:-1]
        if m==n or m in seen: return None
        return res(m,theme,depth+1,seen+(n,))
    return v
for n,t in colors.items():
    vals=[t['value']] if isinstance(t['value'],str) else list(t['value'].values())
    for v in vals:
        if not okc(v): err.append('bad color %s %s'%(n,v))
        if v.startswith('{') and v[1:-1] not in colors: err.append('alias missing %s -> %s'%(n,v))
    for th in ('light','dark'):
        if res(n,th) is None: err.append('unresolvable %s %s'%(n,th))
LEN=re.compile(r'^(-?[0-9.]+(px|rem|em|%)?|0)$')
OTH=re.compile(r'^[A-Za-z0-9 #%(),./+_-]{1,200}$')
for k in fams:
    if k in ('color',): continue
    for t in d[k]['tokens']:
        vals=[t['value']] if isinstance(t['value'],str) else list(t['value'].values())
        for v in vals:
            if k in ('spacing','radius') and not LEN.match(v): err.append('bad len %s %s'%(t['name'],v))
            if k=='shadow' and ('var(' in v or len(v)>400): err.append('bad shadow '+t['name'])
            if k not in ('spacing','radius','shadow') and not OTH.match(v): err.append('bad other %s %r'%(t['name'],v))
            if v.count('(')!=v.count(')'): err.append('parens '+t['name'])
st=[s for g in d['type']['groups'] for s in g['styles']]
if len(st)>80: err.append('too many styles')
if len(d['type']['groups'])>12: err.append('too many groups')
sn=[s['name'] for s in st]
if len(sn)!=len(set(sn)): err.append('dup styles')
for s in st:
    if not NAME.match(s['name']): err.append('bad style name')
    if not LEN.match(s['fontSize']): err.append('bad fs '+s['name'])
    lh=s.get('lineHeight')
    if lh is None: err.append('no lineHeight '+s['name'])
    if s.get('family',None) and s['family'] not in d['type']['families']: err.append('bad fam '+s['name'])
print('families',fams)
print('counts',{k:len(d[k]['tokens']) for k in fams}, 'styles',len(st))
print('ERRORS' if err else 'OK',err)
if err: sys.exit(1)
# all var(--x) in bundle.css resolve
css=re.sub(r'/\*.*?\*/','',open(P+'components/bundle.css').read(),flags=re.S)
sn2=[x['name'] for g in d['type']['groups'] for x in g['styles']]
gen=set(names)|{'font-'+k for k in d['type']['families']}|{'type-'+n for n in sn2}|{'tracking-'+n for n in sn2}|{'value','reader-scale','zoom','pan-x','pan-y','dir','i','n','reveal-delay','h','p','active-top','active-height','x'}
used=set(re.findall(r'var\(--([A-Za-z0-9_.-]+)',css))
local=set(re.findall(r'--([A-Za-z0-9_-]+)\s*:',css))
missing=sorted(u for u in used if u not in gen and u not in local)
print('bundle var() missing:',missing)
if missing: sys.exit(1)
# ---- round 2: primitive distance rule (R2-O21) ----
import math
def lab(h):
    h = h.lstrip('#')[:6]; rgb = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    rgb = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    x = (rgb[0]*0.4124 + rgb[1]*0.3576 + rgb[2]*0.1805) / 0.95047; y = rgb[0]*0.2126 + rgb[1]*0.7152 + rgb[2]*0.0722; z = (rgb[0]*0.0193 + rgb[1]*0.1192 + rgb[2]*0.9505) / 1.08883
    f = lambda t: t ** (1/3) if t > 0.008856 else 7.787*t + 16/116
    return 116*f(y) - 16, 500*(f(x) - f(y)), 200*(f(y) - f(z))
def de2000(a, b):
    L1, a1, b1 = lab(a); L2, a2, b2 = lab(b)
    C1 = math.hypot(a1, b1); C2 = math.hypot(a2, b2); Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb**7 / (Cb**7 + 25**7)))
    a1p, a2p = a1*(1+G), a2*(1+G); C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360; h2p = math.degrees(math.atan2(b2, a2p)) % 360
    dL = L2 - L1; dC = C2p - C1p
    dh = 0 if C1p*C2p == 0 else (h2p - h1p if abs(h2p - h1p) <= 180 else h2p - h1p - 360 if h2p > h1p else h2p - h1p + 360)
    dH = 2*math.sqrt(C1p*C2p)*math.sin(math.radians(dh/2))
    Lb = (L1 + L2)/2; Cbp = (C1p + C2p)/2
    hb = (h1p + h2p)/2 if abs(h1p - h2p) <= 180 else ((h1p + h2p + 360)/2 if h1p + h2p < 360 else (h1p + h2p - 360)/2)
    T = 1 - 0.17*math.cos(math.radians(hb-30)) + 0.24*math.cos(math.radians(2*hb)) + 0.32*math.cos(math.radians(3*hb+6)) - 0.2*math.cos(math.radians(4*hb-63))
    SL = 1 + 0.015*(Lb-50)**2/math.sqrt(20+(Lb-50)**2); SC = 1 + 0.045*Cbp; SH = 1 + 0.015*Cbp*T
    RT = -2*math.sqrt(Cbp**7/(Cbp**7+25**7))*math.sin(math.radians(60*math.exp(-((hb-275)/25)**2)))
    return math.sqrt((dL/SL)**2 + (dC/SC)**2 + (dH/SH)**2 + RT*(dC/SC)*(dH/SH))
prims = {n: t['value'] for n, t in colors.items() if isinstance(t['value'], str) and t['value'].startswith('#') and n.split('-')[0] in ('gray', 'teal', 'red', 'amber', 'gold')}
ALLOW = {frozenset(('gray-27', 'gray-34')): 'bg-page and the hover well: approved values, never adjacent (hover wells sit on cards)'}
BASELINE = set(['amber-188', 'amber-268', 'amber-41', 'amber-541', 'amber-830', 'gold-296', 'gray-0', 'gray-1000', 'gray-14', 'gray-160', 'gray-18', 'gray-189', 'gray-27', 'gray-288', 'gray-330', 'gray-34', 'gray-35', 'gray-387', 'gray-408', 'gray-424', 'gray-534', 'gray-548', 'gray-550', 'gray-579', 'gray-62', 'gray-685', 'gray-742', 'gray-744', 'gray-755', 'gray-800', 'gray-801', 'gray-829', 'gray-882', 'gray-892', 'gray-912', 'gray-932', 'gray-948', 'gray-96', 'red-120', 'red-221', 'red-32', 'red-397', 'red-516', 'red-52', 'red-551', 'red-562', 'red-590', 'red-599', 'red-617', 'red-740', 'red-759', 'red-854', 'red-868', 'teal-194', 'teal-281', 'teal-34', 'teal-359', 'teal-385', 'teal-426', 'teal-438', 'teal-454', 'teal-466', 'teal-504', 'teal-505', 'teal-517', 'teal-544', 'teal-554', 'teal-59', 'teal-603', 'teal-66', 'teal-712', 'teal-771', 'teal-810', 'teal-86'])  # the 3.0.0 palette; the 2.0 rule applies to every primitive added after it
# D195: a header style (uppercase eyebrow) on a bare `th` also hits the row headers in tbody.
# Any rule that styles `th` with text-transform:uppercase must scope it to `thead`.
_bundle = open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'components', 'bundle.css')).read()
_th_leaks = [sel.strip() for sel, body in re.findall(r'([^{}]+)\{([^{}]*)\}', _bundle)
             if 'text-transform:uppercase' in body and re.search(r'(^|[\s,(>])th\b', sel) and 'thead' not in sel]
print('row-header leaks (uppercase th outside thead, D195):', _th_leaks or 'none')
if _th_leaks: sys.exit(1)
close = []; warn = []
names_p = sorted(prims)
for i, a in enumerate(names_p):
    for b in names_p[i+1:]:
        if a.split('-')[0] != b.split('-')[0] and not {a.split('-')[0], b.split('-')[0]} <= {'gray'}: continue
        dE = de2000(prims[a], prims[b])
        if frozenset((a, b)) in ALLOW: continue
        if dE < 2.0 and not (a in BASELINE and b in BASELINE): close.append('%s %s %.2f' % (a, b, dE))
        elif dE < 1.0: warn.append('%s %s %.2f' % (a, b, dE))
print('primitives', len(prims), '| new primitives under CIEDE2000 2.0 from a family member:', close or 'none', '| baseline pairs under 1.0:', warn or 'none', '| allowed:', [' '.join(sorted(k)) for k in ALLOW])
if close: sys.exit(1)
