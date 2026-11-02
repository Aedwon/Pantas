#!/usr/bin/env python3
"""Draw the Content Pass icon (dark green rounded square, white check) and
write AppIcon.icns with iconutil. Usage: make_icon.py <out.icns>. Stdlib only."""
import os, struct, subprocess, sys, tempfile, zlib

def render(size):
    ss = 3  # supersampling
    n = size * ss
    r = n * 0.225
    inset = n * 0.04
    lo, hi = inset, n - inset
    green = (0x0B, 0x7A, 0x67)
    # check mark as two thick segments
    p1, p2, p3 = (n * .27, n * .52), (n * .43, n * .68), (n * .74, n * .33)
    w = n * 0.075
    def seg_d(px, py, a, b):
        ax, ay = a; bx, by = b
        dx, dy = bx - ax, by - ay
        t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
        return ((px - ax - t * dx) ** 2 + (py - ay - t * dy) ** 2) ** .5
    def inside(x, y):
        if x < lo or x > hi or y < lo or y > hi: return False
        cx = min(max(x, lo + r), hi - r); cy = min(max(y, lo + r), hi - r)
        return (x - cx) ** 2 + (y - cy) ** 2 <= r * r
    rows = []
    for Y in range(size):
        row = bytearray([0])
        for X in range(size):
            a = g = chk = 0
            for sy in range(ss):
                for sx in range(ss):
                    x, y = X * ss + sx + .5, Y * ss + sy + .5
                    if inside(x, y):
                        a += 1
                        if min(seg_d(x, y, p1, p2), seg_d(x, y, p2, p3)) <= w: chk += 1
            c = ss * ss
            if a == 0: row += bytes(4); continue
            f = chk / a
            col = [round(green[i] * (1 - f) + 255 * f) for i in range(3)]
            row += bytes(col + [round(255 * a / c)])
        rows.append(bytes(row))
    return rows

def png(size):
    raw = b"".join(render(size))
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))

out = sys.argv[1]
with tempfile.TemporaryDirectory() as t:
    iset = os.path.join(t, "AppIcon.iconset"); os.mkdir(iset)
    cache = {}
    for base in (16, 32, 128, 256, 512):
        for scale in (1, 2):
            px = base * scale
            cache.setdefault(px, png(px))
            name = f"icon_{base}x{base}{'@2x' if scale == 2 else ''}.png"
            open(os.path.join(iset, name), "wb").write(cache[px])
    subprocess.check_call(["iconutil", "-c", "icns", iset, "-o", out])
