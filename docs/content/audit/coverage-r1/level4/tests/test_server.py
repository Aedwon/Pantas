import json
import re
import sys
import threading
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from pathlib import Path

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

    def test_unknown_paths_are_not_found(self):
        self.assertEqual(self.post("/api/delete", {"X-L4": "1"}), 404)
        with self.assertRaises(urllib.error.HTTPError):
            self.get("/secret")


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
