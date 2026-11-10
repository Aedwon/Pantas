# Builds one SVG contact sheet (light column, dark column) from lesson SVGs,
# replacing the reserved color tokens with the app's theme colors.
import sys,re,os
L={'#010101':'#1D1D1F','#020202':'#6E6E73','#030303':'#FFFFFF','#040404':'#E3E3E8','#050505':'#0B7A68','#060606':'#D70015','currentColor':'#1D1D1F'}
D={'#010101':'#F5F5F7','#020202':'#98989D','#030303':'#1C1C1E','#040404':'#38383A','#050505':'#2FB39C','#060606':'#D70015','currentColor':'#F5F5F7'}
out=sys.argv[1]; files=sys.argv[2:]
def sub(t,m,pfx):
    for k,v in m.items(): t=re.sub(re.escape(k),v,t,flags=re.I)
    t=re.sub(r'id="([^"]+)"',lambda x:f'id="{pfx}{x.group(1)}"',t)
    t=re.sub(r'url\(#([^)]+)\)',lambda x:f'url(#{pfx}{x.group(1)})',t)
    t=re.sub(r'href="#([^"]+)"',lambda x:f'href="#{pfx}{x.group(1)}"',t)
    return re.sub(r'<\?xml[^>]*\?>','',t)
y=10; parts=[]
for i,f in enumerate(files):
    t=open(f).read(); h=int(re.search(r'height="(\d+)"',t).group(1))
    parts.append(f'<text x="10" y="{y+12}" font-size="12" fill="#888">{os.path.basename(f)}</text>'); y+=18
    for j,(m,x) in enumerate(((L,10),(D,390))):
        s=sub(t,m,f'f{i}{j}_').replace('<svg ',f'<svg x="{x}" y="{y}" ',1)
        parts.append(s)
    y+=h+20
open(out,'w').write(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="760" height="{y}" viewBox="0 0 760 {y}"><rect width="760" height="{y}" fill="#808080"/>'+''.join(parts)+'</svg>')
print(out,y)
