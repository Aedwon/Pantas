import json
import sys
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from pathlib import Path

PASTE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PASTE / "tests"))
sys.path.insert(0, str(PASTE))
import fixtures  # noqa: E402,F401  (put by test_paste's path setup)
import paste_server  # noqa: E402
from test_paste import make_list  # noqa: E402


class Endpoints(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.lessons = make_list(self.tmp.name)
        # A real packet stands in for the fixture lesson's packet file.
        real = (PASTE.parent / "packets" / "L4-1055.md").read_text(encoding="utf-8")
        (self.lessons.packets_dir / "L4-0417.md").write_text(real, encoding="utf-8")
        handler = paste_server.make_handler({"lessons": self.lessons}, PASTE / "page.html")
        self.httpd = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        threading.Thread(target=self.httpd.serve_forever, daemon=True).start()
        self.addCleanup(self.httpd.server_close)
        self.addCleanup(self.httpd.shutdown)
        self.port = self.httpd.server_address[1]
        self.base = "http://127.0.0.1:%d" % self.port

    def call(self, path, body=None, headers=None, host=None):
        request = urllib.request.Request(self.base + path, data=None if body is None else json.dumps(body).encode(),
                                         method="GET" if body is None else "POST")
        request.add_header("Host", host or "127.0.0.1:%d" % self.port)
        for name, value in (headers or {}).items():
            request.add_header(name, value)
        try:
            with urllib.request.urlopen(request) as response:
                return response.status, response.read().decode("utf-8")
        except urllib.error.HTTPError as error:
            return error.code, error.read().decode("utf-8")

    CHECK = {"list": "lessons", "id": "L4-0417", "text": "{}"}

    def test_page_state_and_prompt_are_served(self):
        status, page = self.call("/")
        self.assertEqual(status, 200)
        self.assertIn("Copy prompt", page)
        self.assertNotIn("http://", page.replace("http://127.0.0.1", ""))  # no outside address in the page
        status, state = self.call("/api/state")
        self.assertEqual(json.loads(state)["lists"][0]["total"], 1)
        status, prompt = self.call("/api/prompt?list=lessons&id=L4-0417")
        self.assertEqual(status, 200)
        self.assertIn("reply with only the completed form as one JSON code block", prompt)
        self.assertNotIn("relay", prompt)
        self.assertEqual(self.call("/api/prompt?list=lessons&id=L4-9999")[0], 400)
        self.assertEqual(self.call("/api/prompt?list=nope&id=L4-0417")[0], 404)

    def test_wrong_host_is_refused_for_every_request(self):
        for path in ("/", "/api/state", "/api/prompt?list=lessons&id=L4-0417"):
            self.assertEqual(self.call(path, host="evil.example")[0], 403)
        self.assertEqual(self.call("/api/check", self.CHECK, {"X-L4": "1"}, host="evil.example")[0], 403)

    def test_post_without_the_header_or_from_another_origin_is_refused(self):
        self.assertEqual(self.call("/api/check", self.CHECK)[0], 403)
        self.assertEqual(self.call("/api/check", self.CHECK, {"X-L4": "0"})[0], 403)
        self.assertEqual(self.call("/api/check", self.CHECK, {"X-L4": "1", "Origin": "https://evil.example"})[0], 403)
        self.assertEqual(self.call("/api/start-over", self.CHECK)[0], 403)
        self.assertEqual(self.lessons.view()["counts"]["todo"], 1)

    def test_a_good_post_runs_the_check(self):
        form = json.dumps(fixtures.valid_form("A"))
        status, body = self.call("/api/check", dict(self.CHECK, text=form),
                                 {"X-L4": "1", "Origin": self.base})
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body)["word"], "ACCEPTED")

    def test_bad_posts(self):
        headers = {"X-L4": "1"}
        self.assertEqual(self.call("/api/check", {"list": "nope", "id": "x", "text": "{}"}, headers)[0], 400)
        self.assertEqual(self.call("/api/check", {"list": "lessons", "id": "L4-0417"}, headers)[0], 400)
        self.assertEqual(self.call("/api/check", {"list": "lessons", "id": "L4-9999", "text": "{}"}, headers)[0], 400)
        self.assertEqual(self.call("/api/other", self.CHECK, headers)[0], 404)


if __name__ == "__main__":
    unittest.main()
