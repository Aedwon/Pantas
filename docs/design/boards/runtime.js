/* Pantas design boards: a tiny stand-in for the canvas runtime, so each board opens
   on its own in any browser. CSS animations need nothing from here; this only runs the
   small scripted flows (frames that switch with {{f0}}, {{f1}}, ... and replay buttons). */
(function () {
  function start() {
    var root = document.querySelector('x-dc');
    if (!root) return;
    var helmet = root.querySelector('helmet');
    if (helmet) { Array.prototype.slice.call(helmet.children).forEach(function (c) { document.head.appendChild(c); }); helmet.remove(); }
    var st = document.createElement('style');
    st.textContent = 'sc-if[value="false"]{display:none!important}';
    document.head.appendChild(st);
    var scriptEl = document.querySelector('script[data-dc-script]');
    root.querySelectorAll('script').forEach(function (s) { s.remove(); });
    if (!scriptEl) return;
    var tpl = root.innerHTML;
    var fns = {};
    window.__dcfn = function (k, ev) { if (fns[k]) fns[k](ev); };
    function DCLogic(p) { this.props = p || {}; this.state = {}; this.tos = []; }
    DCLogic.prototype.setState = function (o) {
      if (typeof o === 'function') o = o(this.state);
      Object.assign(this.state, o); schedule();
    };
    var Comp;
    try { Comp = new Function('DCLogic', scriptEl.textContent + '\n;return Component;')(DCLogic); }
    catch (e) { console.warn('board script', e); return; }
    var c = new Comp({}); if (!c.state) c.state = {}; if (!c.tos) c.tos = [];
    function html() {
      var vals = c.renderVals ? c.renderVals() : {};
      return tpl.replace(/\{\{\s*(\w+)\s*\}\}/g, function (m, k) {
        var v = vals[k];
        if (typeof v === 'function') { fns[k] = v; return "__dcfn('" + k + "',event)"; }
        if (k === 'true' || k === 'false') return k;
        return v === undefined || v === null ? '' : String(v);
      });
    }
    function patch(a, b) {
      if (a.nodeType === 3 || b.nodeType === 3) { if (a.textContent !== b.textContent) a.textContent = b.textContent; return; }
      if (b.attributes) for (var i = 0; i < b.attributes.length; i++) { var at = b.attributes[i]; if (a.getAttribute(at.name) !== at.value) a.setAttribute(at.name, at.value); }
      var n = Math.min(a.childNodes.length, b.childNodes.length);
      for (var j = 0; j < n; j++) patch(a.childNodes[j], b.childNodes[j]);
    }
    var first = true, queued = false;
    function render() {
      queued = false;
      var t = document.createElement('x-dc'); t.innerHTML = html();
      if (first) { root.innerHTML = t.innerHTML; first = false; } else patch(root, t);
    }
    function schedule() { if (first || queued) return; queued = true; requestAnimationFrame(render); }
    render();
    if (c.componentDidMount) c.componentDidMount();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
