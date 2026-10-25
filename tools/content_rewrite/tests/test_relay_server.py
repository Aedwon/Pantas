"""Tests for the local page: host and origin refusal, the prompt, the copied mark, and the end to end state.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_server.py
"""
import http.client
import json
import sys
import threading
import unittest
from http.server import ThreadingHTTPServer

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import planner  # noqa: E402
import rw_lib  # noqa: E402
import server  # noqa: E402
import status  # noqa: E402

PAGE = Path(rw_lib.RELAY_DIR) / "page.html"


class FakeGh:
    def __init__(self, runs=None, error=None):
        self.runs_value, self.error, self.calls = runs or [], error, 0

    def runs(self):
        self.calls += 1
        if self.error:
            raise status.GhError(self.error)
        return self.runs_value


class Clock:
    def __init__(self):
        self.now = 0.0

    def __call__(self):
        return self.now


class ServerCase(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.gh = FakeGh()
        self.clock = Clock()
        self.app = server.App(self.ctx, self.gh, clock=self.clock)
        self.httpd = ThreadingHTTPServer(("127.0.0.1", 0), server.make_handler(self.app, PAGE))
        self.port = self.httpd.server_address[1]
        thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(self.stop)

    def stop(self):
        self.httpd.shutdown()
        self.httpd.server_close()

    def request(self, method, path, body=None, headers=None, host=None):
        conn = http.client.HTTPConnection("127.0.0.1", self.port, timeout=10)
        merged = {"Host": host or "127.0.0.1:%d" % self.port}
        merged.update(headers or {})
        data = json.dumps(body) if body is not None else None
        if data is not None:
            merged.setdefault("Content-Type", "application/json")
        conn.request(method, path, body=data, headers=merged)
        response = conn.getresponse()
        payload = response.read().decode("utf-8")
        conn.close()
        return response.status, payload, dict(response.getheaders())


class Safety(ServerCase):
    def test_binds_to_this_machine_only(self):
        self.assertEqual(self.httpd.server_address[0], "127.0.0.1")
        self.assertEqual(server.HOST, "127.0.0.1")

    def test_page_and_state_with_the_right_host(self):
        code, body, headers = self.request("GET", "/")
        self.assertEqual(code, 200)
        self.assertIn("Copy prompt", body)
        self.assertIn("default-src 'none'", headers["Content-Security-Policy"])
        code, body, _ = self.request("GET", "/api/state")
        self.assertEqual(code, 200)
        self.assertEqual(json.loads(body)["next"], "RW-001")
        code, _, _ = self.request("GET", "/api/state", host="localhost:%d" % self.port)
        self.assertEqual(code, 200)

    def test_foreign_host_is_refused_everywhere(self):
        for host in ("evil.example.com", "evil.example.com:%d" % self.port, "127.0.0.1:1", "127.0.0.1"):
            self.assertEqual(self.request("GET", "/", host=host)[0], 403, host)
            self.assertEqual(self.request("GET", "/api/state", host=host)[0], 403, host)
            self.assertEqual(self.request("GET", "/api/prompt?id=RW-001", host=host)[0], 403, host)
            self.assertEqual(self.request("POST", "/api/copied", {"id": "RW-001"}, {"X-Rewrite": "1"}, host=host)[0], 403)

    def test_post_needs_the_header_and_our_origin(self):
        body = {"id": "RW-001"}
        self.assertEqual(self.request("POST", "/api/copied", body)[0], 403, "no X-Rewrite header")
        self.assertEqual(self.request("POST", "/api/copied", body, {"X-Rewrite": "0"})[0], 403)
        self.assertEqual(self.request("POST", "/api/copied", body, {"X-Rewrite": "1", "Origin": "https://evil.example.com"})[0], 403)
        self.assertEqual(self.request("POST", "/api/copied", body, {"X-Rewrite": "1", "Origin": "null"})[0], 403)
        self.assertEqual(self.ctx.copied(), {})
        origin = "http://127.0.0.1:%d" % self.port
        self.assertEqual(self.request("POST", "/api/copied", body, {"X-Rewrite": "1", "Origin": origin})[0], 200)
        self.assertIn("RW-001", self.ctx.copied())

    def test_bad_posts_and_unknown_paths(self):
        headers = {"X-Rewrite": "1"}
        self.assertEqual(self.request("POST", "/api/other", {"id": "x"}, headers)[0], 404)
        self.assertEqual(self.request("POST", "/api/copied", {"id": 5}, headers)[0], 400)
        self.assertEqual(self.request("POST", "/api/copied", {"id": "RW-999"}, headers)[0], 400)
        self.assertEqual(self.request("POST", "/api/copied", {}, headers)[0], 400)
        self.assertEqual(self.request("GET", "/nope")[0], 404)
        self.assertEqual(self.request("GET", "/api/prompt?id=RW-999")[0], 400)

    def test_there_is_no_paste_back_endpoint(self):
        self.assertEqual(self.request("POST", "/api/check", {"id": "RW-001", "text": "x"}, {"X-Rewrite": "1"})[0], 404)


class Behavior(ServerCase):
    def test_prompt_endpoint_returns_the_batch_prompt(self):
        code, body, _ = self.request("GET", "/api/prompt?id=RW-001")
        self.assertEqual(code, 200)
        self.assertIn("batch RW-001", body)
        self.assertIn(F.lesson_text("alpha").rstrip("\n"), body)

    def test_copying_moves_the_next_batch(self):
        self.request("POST", "/api/copied", {"id": "RW-001"}, {"X-Rewrite": "1"})
        view = json.loads(self.request("GET", "/api/state")[1])
        self.assertEqual(view["next"], "RW-002")
        states = {b["id"]: b["state"] for b in view["batches"]}
        self.assertEqual(states["RW-001"], "copied")

    def test_remote_checks_are_cached_between_requests(self):
        self.app.view()
        self.app.view()
        self.assertEqual(self.gh.calls, 1)
        self.clock.now += server.REFRESH_SECONDS + 1
        self.app.view()
        self.assertEqual(self.gh.calls, 2)

    def test_a_missing_gh_shows_check_unknown_without_failing(self):
        self.gh.error = "gh is not available (FileNotFoundError)"
        code, body, _ = self.request("GET", "/api/state")
        self.assertEqual(code, 200)
        self.assertTrue(any("Check unknown" in n for n in json.loads(body)["notes"]))

    def test_end_to_end_handed_in_pushed_check_passed(self):
        import handin
        batch = self.ctx.batch("RW-001")
        for lid in batch["lessons"]:
            self.repo.inbox("RW-001", lid + ".md", F.rewritten(lid.replace("lesson-algebra-", "")))
        code, lines = handin.process("RW-001", "1", self.ctx)
        self.assertEqual(code, 0, lines)
        sha = self.repo.head()

        def state_of(batch_id):
            self.clock.now += server.REFRESH_SECONDS + 1  # a new fetch and a new gh call
            view = self.app.view(force=True)
            return next(b for b in view["batches"] if b["id"] == batch_id)

        item = state_of("RW-001")
        self.assertEqual((item["state"], item["commits"]), ("handed_in", [sha[:8]]))
        F.git(self.repo.root, "push", "-q", "origin", rw_lib.BRANCH)  # what git_push_current does
        self.assertEqual(self.repo.remote_head(), sha)
        self.gh.runs_value = []
        self.assertEqual(state_of("RW-001")["state"], "pushed")
        self.gh.runs_value = [{"headSha": sha, "conclusion": "success"}]
        item = state_of("RW-001")
        self.assertEqual((item["state"], item["done"]), ("done", True))
        self.clock.now += server.REFRESH_SECONDS + 1
        view = self.app.view()
        self.assertEqual(view["counts"]["done"], 1)
        self.assertEqual(view["next"], "RD-001", "a read batch for the finished lessons is offered next")
        self.gh.runs_value = [{"headSha": sha, "conclusion": "failure"}]
        self.clock.now += server.REFRESH_SECONDS + 1
        view = self.app.view()
        self.assertIsNone(view["next"])
        self.assertIn("RW-001", view["blocked"])


if __name__ == "__main__":
    unittest.main()
