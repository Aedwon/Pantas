# Builds one SVG contact sheet from lesson SVGs, replacing the reserved color
# tokens with the app's theme colors, for an offscreen look (WORKFLOW, Nov 9).
# Usage: python3 -I figure_sheet.py out.svg [--both] file.svg ...
#   default: light theme, two figures per row; --both: light and dark side by side.
import sys, re, os
L = {'#010101': '#1D1D1F', '#020202': '#6E6E73', '#030303': '#FFFFFF', '#040404': '#E3E3E8',
     '#050505': '#0B7A68', '#060606': '#D70015', 'currentColor': '#1D1D1F'}
D = {'#010101': '#F5F5F7', '#020202': '#98989D', '#030303': '#1C1C1E', '#040404': '#38383A',
     '#050505': '#2FB39C', '#060606': '#D70015', 'currentColor': '#F5F5F7'}
args = sys.argv[1:]
out = args.pop(0)
both = '--both' in args
files = [a for a in args if a != '--both']

def sub(t, m, pfx):
    for k, v in m.items():
        t = re.sub(re.escape(k), v, t, flags=re.I)
    t = re.sub(r'id="([^"]+)"', lambda x: f'id="{pfx}{x.group(1)}"', t)
    t = re.sub(r'url\(#([^)]+)\)', lambda x: f'url(#{pfx}{x.group(1)})', t)
    t = re.sub(r'href="#([^"]+)"', lambda x: f'href="#{pfx}{x.group(1)}"', t)
    return re.sub(r'<\?xml[^>]*\?>', '', t)

cells = []
for i, f in enumerate(files):
    t = open(f).read()
    h = int(float(re.search(r'<svg[^>]*\sheight="([\d.]+)"', t).group(1)))
    themes = [(L, 'l'), (D, 'd')] if both else [(L, 'l')]
    for m, tag in themes:
        cells.append((os.path.basename(f), sub(t, m, f'f{i}{tag}_'), h))
# qlmanage thumbnails are square, so write pages no taller than the sheet width.
pages, y, parts = [], 10, []
for r in range(0, len(cells), 2):
    row = cells[r:r + 2]
    rh = max(c[2] for c in row)
    if parts and y + rh + 36 > 760:
        pages.append((parts, y)); y, parts = 10, []
    for j, (name, s, h) in enumerate(row):
        x = 10 + j * 380
        parts.append(f'<text x="{x}" y="{y + 12}" font-size="12" fill="#222">{name}</text>')
        parts.append(s.replace('<svg ', f'<svg x="{x}" y="{y + 18}" ', 1))
    y += rh + 36
pages.append((parts, y))
base = out[:-4] if out.endswith('.svg') else out
for n, (parts, h) in enumerate(pages, 1):
    h = max(h, 760)
    name = f'{base}-{n}.svg'
    open(name, 'w').write(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
                          f'width="760" height="{h}" viewBox="0 0 760 {h}"><rect width="760" height="{h}" fill="#B0B0B0"/>'
                          + ''.join(parts) + '</svg>')
    print(name)
