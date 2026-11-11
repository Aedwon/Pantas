// Local runs only. Copied into build/web by tools/local/run_web_local.py and loaded only when the
// address has ?localFps=1. It is a readout for Aedwon's own testing: frames per second over the last
// second, the 95th percentile frame time over the last 120 frames, and the count of long frames
// (over 50 ms) since the page opened. It never changes what the app draws and is not part of any
// real build.
(function (root) {
  'use strict';
  var WINDOW = 120;
  var LONG_FRAME_MS = 50;

  function percentile95(times) {
    if (!times.length) return 0;
    var sorted = times.slice().sort(function (a, b) { return a - b; });
    return sorted[Math.min(sorted.length - 1, Math.ceil(sorted.length * 0.95) - 1)];
  }

  // Pure bookkeeping, kept apart from the page so it can be checked without a browser.
  function FrameStats() {
    this.stamps = [];
    this.recent = [];
    this.long = 0;
    this.last = null;
  }
  FrameStats.prototype.frame = function (now) {
    if (this.last !== null) {
      var gap = now - this.last;
      this.recent.push(gap);
      if (this.recent.length > WINDOW) this.recent.shift();
      if (gap > LONG_FRAME_MS) this.long += 1;
    }
    this.last = now;
    this.stamps.push(now);
    while (this.stamps.length && now - this.stamps[0] > 1000) this.stamps.shift();
  };
  FrameStats.prototype.snapshot = function () {
    return {
      fps: this.stamps.length > 1 ? this.stamps.length - 1 : 0,
      p95: percentile95(this.recent),
      long: this.long
    };
  };

  function start(doc, raf) {
    var stats = new FrameStats();
    var box = doc.createElement('div');
    box.id = 'local-fps';
    box.setAttribute('aria-hidden', 'true');
    box.style.cssText = 'position:fixed;top:4px;left:4px;z-index:2147483647;padding:4px 6px;' +
      'border-radius:4px;background:rgba(0,0,0,.72);color:#fff;font:11px/1.3 ui-monospace,monospace;' +
      'pointer-events:none;white-space:pre';
    box.textContent = 'fps --\np95 --\nlong 0';
    doc.body.appendChild(box);
    var shown = 0;
    function tick(now) {
      stats.frame(now);
      if (now - shown >= 500) {
        shown = now;
        var s = stats.snapshot();
        box.textContent = 'fps ' + s.fps + '\np95 ' + s.p95.toFixed(1) + ' ms\nlong ' + s.long;
      }
      raf(tick);
    }
    raf(tick);
    return stats;
  }

  root.pantasLocalFps = {FrameStats: FrameStats, start: start};
  if (typeof document !== 'undefined' && typeof requestAnimationFrame === 'function') {
    var go = function () { start(document, function (f) { return requestAnimationFrame(f); }); };
    if (document.body) go(); else document.addEventListener('DOMContentLoaded', go);
  }
})(typeof window !== 'undefined' ? window : globalThis);
