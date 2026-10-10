import json
import re
import shutil
import subprocess
import sys
import threading
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest import mock

LEVEL4 = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(LEVEL4))
import server  # noqa: E402

PAGE = LEVEL4 / "page" / "index.html"
MOCKUP = LEVEL4 / "mockups" / "level4-page-v3.html"
# Wording the approved mockup does not show. Each needs Aedwon's approval
# before the run starts; adding to this list is a design change, not a fix.
NEW_TEXT = {
    "The next lesson is starting.",
    "This lesson needs you.",
    "Check lesson {n} of {total}, {subject}",
    # Approved by Aedwon (relayed by the coordinator, October 11, 2026): the run_trouble state,
    # this sentence with the reason beneath it and a Resume button.
    "The run needs you.",
}


class FakeRun:
    def __init__(self):
        self.calls = []

    def view(self):
        return {"state": "ready"}

    def tick(self):
        self.calls.append("tick")

    def __getattr__(self, name):
        if name in ("start", "pause", "resume", "restart_current"):
            return lambda: self.calls.append(name)
        if name == "hold_current":
            return lambda reason: self.calls.append("hold_current")
        raise AttributeError(name)


class Endpoints(unittest.TestCase):
    def setUp(self):
        self.run = FakeRun()
        handler = server.make_handler(self.run, threading.Lock(), PAGE, reports={"/report/pilot": lambda: "PILOT TEXT"})
        self.httpd = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        threading.Thread(target=self.httpd.serve_forever, daemon=True).start()
        self.base = "http://127.0.0.1:%d" % self.httpd.server_address[1]

    def tearDown(self):
        self.httpd.shutdown()
        self.httpd.server_close()

    def get(self, path):
        with urllib.request.urlopen(self.base + path) as response:
            return response.read().decode("utf-8")

    def post(self, path, headers=None):
        request = urllib.request.Request(self.base + path, data=b"", headers=headers or {}, method="POST")
        try:
            with urllib.request.urlopen(request) as response:
                return response.status
        except urllib.error.HTTPError as error:
            return error.code

    def test_page_state_and_report_are_served(self):
        self.assertIn("Level 4 audit", self.get("/"))
        self.assertEqual(json.loads(self.get("/api/state")), {"state": "ready"})
        self.assertEqual(self.get("/report/pilot"), "PILOT TEXT")

    def test_each_control_reaches_the_run(self):
        for action in ("start", "pause", "resume", "restart", "hold"):
            self.assertEqual(self.post("/api/" + action, {"X-L4": "1"}), 200)
        self.assertEqual(self.run.calls, ["start", "pause", "resume", "restart_current", "hold_current"])

    def test_a_control_without_the_header_is_refused(self):
        self.assertEqual(self.post("/api/start"), 403)
        self.assertEqual(self.run.calls, [])

    def test_a_request_addressed_to_another_host_name_is_refused(self):
        # A site can point its own domain at 127.0.0.1; the Host header then names that domain.
        request = urllib.request.Request(self.base + "/api/state", headers={"Host": "evil.example:8765"})
        with self.assertRaises(urllib.error.HTTPError) as caught:
            urllib.request.urlopen(request)
        self.assertEqual(caught.exception.code, 403)
        self.assertEqual(self.post("/api/start", {"X-L4": "1", "Host": "evil.example:8765"}), 403)
        self.assertEqual(self.run.calls, [])

    def test_a_control_from_another_origin_is_refused(self):
        self.assertEqual(self.post("/api/start", {"X-L4": "1", "Origin": "http://evil.example"}), 403)
        self.assertEqual(self.post("/api/start", {"X-L4": "1", "Origin": self.base}), 200)
        self.assertEqual(self.run.calls, ["start"])

    def test_unknown_paths_are_not_found(self):
        self.assertEqual(self.post("/api/delete", {"X-L4": "1"}), 404)
        with self.assertRaises(urllib.error.HTTPError):
            self.get("/secret")


class TickLoop(unittest.TestCase):
    def setUp(self):
        patcher = mock.patch.object(server.traceback, "print_exc")  # the failures here are deliberate
        patcher.start()
        self.addCleanup(patcher.stop)

    class Run:
        def __init__(self, fail):
            self.fail, self.troubles, self.ticks = fail, [], 0

        def tick(self):
            self.ticks += 1
            if self.fail:
                raise RuntimeError("HTTP 502 from gh")

        def trouble(self, reason):
            self.troubles.append(reason)

    def test_three_failing_ticks_in_a_row_put_the_run_in_trouble(self):
        run, failing = self.Run(fail=True), 0
        for expected in (1, 2):
            failing = server.tick_once(run, threading.Lock(), failing)
            self.assertEqual((failing, run.troubles), (expected, []))
        failing = server.tick_once(run, threading.Lock(), failing)
        self.assertEqual(failing, 3)
        self.assertEqual(len(run.troubles), 1)
        self.assertIn("HTTP 502 from gh", run.troubles[0])

    def test_one_good_tick_resets_the_count(self):
        run = self.Run(fail=True)
        failing = server.tick_once(run, threading.Lock(), 2 - 1)
        run.fail = False
        self.assertEqual(server.tick_once(run, threading.Lock(), failing), 0)
        run.fail = True
        self.assertEqual(server.tick_once(run, threading.Lock(), 0), 1)
        self.assertEqual(run.troubles, [])

    def test_the_loop_keeps_going_after_a_failure(self):
        run, stop = self.Run(fail=True), threading.Event()
        original = server.time.sleep
        server.time.sleep = lambda seconds: stop.set() if run.ticks >= 4 else None
        try:
            server.tick_forever(run, threading.Lock(), seconds=0, stop=stop)
        finally:
            server.time.sleep = original
        self.assertEqual(run.ticks, 4)
        self.assertEqual(len(run.troubles), 2)


NODE = shutil.which("node")


@unittest.skipUnless(NODE, "node is needed to run the page's own script")
class PageRenders(unittest.TestCase):
    """Runs the page's script against a stub document and reads back what it would show."""
    HARNESS = r"""
const fs = require('fs'), vm = require('vm');
const html = fs.readFileSync(process.argv[2], 'utf8');
const text = html.match(/<script type="application\/json" id="text">([\s\S]*?)<\/script>/)[1];
const code = html.slice(html.lastIndexOf('<script>') + 8, html.lastIndexOf('</script>'));
const nodes = {};
const node = id => nodes[id] = nodes[id] || { id, textContent: id === 'text' ? text : '', innerHTML: '', className: '', hidden: false };
const ctx = vm.createContext({ document: { getElementById: node, addEventListener() {} },
  fetch: () => Promise.reject(new Error('no server')), setInterval() {}, console });
vm.runInContext(code, ctx);
vm.runInContext('render(' + process.argv[3] + ')', ctx);
const out = {};
for (const id of ['where', 'lesson', 'say', 'more', 'acts', 'tally']) out[id] = node(id).textContent || node(id).innerHTML;
out.sayClass = node('say').className; out.hidden = node('trouble').hidden;
console.log(JSON.stringify(out));
"""

    def show(self, **view):
        base = {"state": "running", "reason": "", "lesson": None, "chats": [], "strip": [], "finished": 0, "total": 0,
                "held": 0, "hours_left": None, "in_pilot": False, "pilot_total": 10, "disputed_items": 0}
        base.update(view)
        script = self.HARNESS.replace("process.argv[2]", json.dumps(str(PAGE))).replace(
            "process.argv[3]", json.dumps(json.dumps(base)))
        out = subprocess.check_output([NODE, "-e", script], universal_newlines=True)
        return json.loads(out)

    def test_run_trouble_shows_its_sentence_the_reason_and_one_resume_button(self):
        shown = self.show(state="run_trouble", reason="HTTPError: gh failed <b>x</b>")
        self.assertEqual(shown["say"], "The run needs you.")
        self.assertIn("HTTPError: gh failed &lt;b&gt;x&lt;/b&gt;", shown["more"])
        self.assertEqual(shown["acts"].count("<button"), 1)
        self.assertIn('data-post="resume"', shown["acts"])
        self.assertIn(">Resume<", shown["acts"])

    def test_the_finished_sentence_counts_finished_lessons_not_all(self):
        shown = self.show(state="done", total=158, finished=151, held=7)
        self.assertEqual(shown["more"], "151 lessons read. 7 are on hold and need a decision.")

    def test_needs_you_and_stopped_still_render(self):
        self.assertEqual(self.show(state="needs_you", reason="Chat 1 had its form rejected twice.")["say"],
                         "This lesson needs you.")
        self.assertEqual(self.show(state="stopped", reason="unexpected change: a.md")["say"],
                         "Stopped. A file changed that no chat handed in.")


class MatchesMockup(unittest.TestCase):
    SAMPLE = {"n": "12", "total": "158", "subject": "Mathematics", "held": "3", "path": "packets/L4-0388.md",
              "m": "2", "minutes": "minutes", "finished": "9", "h": "15", "hours": "hours", "rules": "rules"}
    # The mockup shows these with other sample numbers.
    VARIANTS = ({"n": "2"}, {"held": "1"})

    def strings(self, value):
        if isinstance(value, str):
            yield value
        elif isinstance(value, dict):
            for item in value.values():
                yield from self.strings(item)
        elif isinstance(value, list):
            for item in value:
                yield from self.strings(item)

    def test_every_sentence_on_the_page_is_in_the_approved_mockup(self):
        page = PAGE.read_text(encoding="utf-8")
        mockup = MOCKUP.read_text(encoding="utf-8")
        block = re.search(r'<script type="application/json" id="text">(.*?)</script>', page, re.S).group(1)
        body = page[page.index("<body>"):page.index("<script")]
        sentences = {text for text in self.strings(json.loads(block)) if " " in text}
        sentences |= {text.strip() for text in re.findall(r">([^<>]+)<", body) if " " in text.strip()}
        missing = []
        for text in sorted(sentences - NEW_TEXT):
            fills = [dict(self.SAMPLE, **variant) for variant in ({},) + self.VARIANTS]
            shown = [re.sub(r"\{(\w+)\}", lambda match: sample[match.group(1)], text) for sample in fills]
            if not any(candidate in mockup for candidate in shown):
                missing.append(text)
        self.assertEqual(missing, [])

    def test_the_script_holds_no_wording_of_its_own(self):
        page = PAGE.read_text(encoding="utf-8")
        script = page[page.rindex("<script>"):]
        script = re.sub(r"//[^\n]*|/\*.*?\*/", "", script, flags=re.S)
        prose = [text for text in re.findall(r"'([^'\n]*)'", script) if re.search(r"[A-Za-z]{3,} [A-Za-z]{3,}", text)]
        self.assertEqual(prose, [])

    def test_styles_are_the_mockups(self):
        page, mockup = PAGE.read_text(encoding="utf-8"), MOCKUP.read_text(encoding="utf-8")
        for rule in (".say { font-size: 38px;", ".go { display: block;", ".tick.now { background: var(--blue);",
                     "--paper: #eef1f4;", ".go.quiet {"):
            self.assertIn(rule, mockup)
            self.assertIn(rule, page)


if __name__ == "__main__":
    unittest.main()
