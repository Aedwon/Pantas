#!/usr/bin/env python3
"""Extract the approved board's sampled tracks, without resampling its motion.

Usage: python3 tool/extract_cse_finale_motion.py MAIN_CHECKOUT/docs/design
"""
import hashlib
import importlib.util
import re
import sys
import subprocess
from pathlib import Path

sys.dont_write_bytecode = True
design = Path(sys.argv[1])
loader = importlib.util.spec_from_file_location('timeline', design / 'tools/timeline.py')
timeline = importlib.util.module_from_spec(loader)
loader.loader.exec_module(timeline)
source = (design / 'boards/MK_Finale.html').read_text()
parser = timeline.P()
parser.feed(source)
keyframes = timeline.parse_keyframes('\n'.join(parser.styles))
flights = []
effects = {}
boxes = {}


def stops(raw):
    result = []
    for percent, props in raw:
        if percent == 100:
            continue  # The demonstration's loop reset is not an app frame.
        position = re.search(r'translate\(([-\d.]+)(?:px)?,\s*([-\d.]+)(?:px)?\)', props)
        vertical = re.search(r'translateY\(([-\d.]+)(?:px)?\)', props)
        scale = re.search(r'scale\(([-\d.]+)(?:,\s*([-\d.]+))?\)', props)
        rotation = re.search(r'rotate\(([-\d.]+)deg\)', props)
        opacity = re.search(r'opacity:([\d.]+)', props)
        curve = re.search(r'cubic-bezier\(([^)]+)\)', props)
        if curve:
            easing = tuple(float(v) for v in curve.group(1).split(','))
        elif 'animation-timing-function:ease-out' in props:
            easing = (0., 0., .58, 1.)
        else:
            easing = (0., 0., 1., 1.)
        result.append(dict(t=percent * 113.5,
                           x=float(position.group(1)) if position else 0.,
                           y=float(position.group(2)) if position else float(vertical.group(1)) if vertical else 0.,
                           sx=float(scale.group(1)) if scale else 1.,
                           sy=float(scale.group(2) or scale.group(1)) if scale else 1.,
                           rotation=float(rotation.group(1)) if rotation else 0.,
                           opacity=float(opacity.group(1)) if opacity else 1.,
                           curve=easing))
    return result


def walk(node):
    if isinstance(node, str):
        return
    style = node.attrs.get('style', '')
    match = re.search(r'animation:\s*MKFinale_n(\d+)', style)
    if match:
        number = int(match.group(1))
        raw = keyframes[f'MKFinale_n{number}']
        if 'width: 9px;' in style and 'scale(0.35)' in raw[-1][1]:
            flights.append(stops(raw))
        if number in range(537, 559) or number in [531, 534, 535, 562, 567, 568, 569, 570, 571, 572, 573, 576]:
            effects[number] = stops(raw)
            parts = {key: re.search(r'(?:^|;)\s*' + key + r':\s*([-\d.]+)px', style) for key in ['left', 'top', 'width', 'height']}
            if all(parts.values()):
                boxes[number] = {key: float(value.group(1)) for key, value in parts.items()}
    for child in node.kids:
        walk(child)


walk(parser.root)
assert len(flights) == 171


def number(value):
    return repr(round(value, 7))


def dart_stop(stop):
    values = ', '.join(f'{key}: {number(stop[key])}' for key in
                       ['t', 'x', 'y', 'sx', 'sy', 'rotation', 'opacity'])
    return '(' + values + ', curve: (' + ', '.join(number(v) for v in stop['curve']) + '),), '


lines = [
    '// Source: MK_Finale, sampled stops retained without curve substitution.',
    '// SHA256: ' + hashlib.sha256(source.encode()).hexdigest(),
    '// Regenerate with tool/extract_cse_finale_motion.py and the main design folder.',
    'typedef CseMotionStop = ({double t, double x, double y, double sx, double sy,',
    '  double rotation, double opacity, (double, double, double, double) curve,});',
    'const cseFlightTracks = <List<CseMotionStop>>[',
]
for track in flights:
    lines.append('[')
    lines.extend(dart_stop(stop) for stop in track)
    lines.append('],')
lines.append('];')
lines.append('const cseEffectTracks = <int, List<CseMotionStop>>{')
for number_, track in sorted(effects.items()):
    lines.append(f'{number_}: [')
    lines.extend(dart_stop(stop) for stop in track)
    lines.append('],')
lines.append('};')
lines.append('const cseEffectBoxes = <int, ({double left, double top, double width, double height})>{')
for key, box in sorted(boxes.items()):
    lines.append(str(key) + ': (' + ', '.join(k + ': ' + number(v) for k,v in box.items()) + ',),')
lines.append('};')
output = Path('lib/features/mock_exam/presentation/widgets/cse_finale_tracks.dart')
output.write_text('\n'.join(lines) + '\n')
subprocess.run(['dart','format',str(output)],check=True,stdout=subprocess.DEVNULL)
print(f'{len(flights)} flight tracks, {len(effects)} effect tracks: {output}')
