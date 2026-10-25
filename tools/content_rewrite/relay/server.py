#!/usr/bin/env python3
"""The local page for the CSE rewrite batches.

Usage: python3 -I tools/content_rewrite/relay/server.py      then open http://127.0.0.1:8767

Binds to this Mac only. Every request must name this server as its Host, so a website that points its
own domain at 127.0.0.1 is refused. Every POST also needs the X-Rewrite header and, when the browser
sends one, this page's own Origin, so no other site can post here. These are the rules of the Level 4
paste page. The page shows the next batch with a Copy prompt button and each batch's state. Nothing is
pasted back: a chat hands in through the relay, and a batch is done when its commit is on the remote
branch and the GitHub check passed.
Python 3.9 standard library only.
"""
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import item_types  # noqa: E402
import planner  # noqa: E402
import rw_lib  # noqa: E402
import status  # noqa: E402

HOST = "127.0.0.1"
PORT = int(os.environ.get("PANTAS_REWRITE_PORT", "8767"))
MAX_BODY = 64 * 1024
REFRESH_SECONDS = 30
SECURITY_HEADERS = {
    "Cache-Control": "no-store",
    "Content-Security-Policy": "default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; "
                               "connect-src 'self'; base-uri 'none'; form-action 'none'",
    "X-Content-Type-Options": "nosniff",
}


class App:
    """The page's data. git fetch and gh run at most once every REFRESH_SECONDS; the rest is local and cheap."""

    LOCAL_SECONDS = 5

    def __init__(self, ctx, gh=None, clock=time.monotonic, refresh_seconds=REFRESH_SECONDS):
        self.ctx = ctx
        self.gh = gh or status.Gh(ctx.root)
        self.clock = clock
        self.refresh_seconds = refresh_seconds
        self.lock = threading.Lock()
        self.cache, self.cached_at = None, None
        self.remote_at, self.fetched, self.runs, self.runs_error = None, True, None, None

    def _refresh_remote(self):
        self.fetched = status.fetch(self.ctx.git)
        try:
            planner.plan(self.ctx, kinds=["read"])
        except rw_lib.RewriteError:
            pass  # a read batch that cannot be planned yet is not a page error
        try:
            self.runs, self.runs_error = self.gh.runs(), None
        except status.GhError as exc:
            self.runs, self.runs_error = None, exc
        self.remote_at = self.clock()

    def view(self, force=False):
        with self.lock:
            now = self.clock()
            if self.remote_at is None or now - self.remote_at >= self.refresh_seconds:
                self._refresh_remote()
                force = True
            if force or self.cache is None or now - self.cached_at >= self.LOCAL_SECONDS:
                runs, error = self.runs, self.runs_error
                self.cache = status.overview(self.ctx, _Fixed(runs, error), self.fetched)
                self.cached_at = self.clock()
            return self.cache

    def _batch(self, batch_id):
        batch = self.ctx.batch(batch_id) if isinstance(batch_id, str) else None
        if batch is None:
            raise rw_lib.RewriteError("that batch is not in this run")
        return batch

    def prompt(self, batch_id):
        batch = self._batch(batch_id)
        return item_types.get(batch["type"]).prompt(self.ctx, batch)

    def copied(self, batch_id):
        self._batch(batch_id)
        self.ctx.mark_copied(batch_id)
        return self.view(force=True)


class _Fixed:
    """A gh stand-in that returns the runs the App already fetched."""

    def __init__(self, runs, error):
        self._runs, self._error = runs, error

    def runs(self):
        if self._error is not None:
            raise self._error
        return self._runs


def make_handler(app, page_path):
    class Handler(BaseHTTPRequestHandler):
        def _send(self, code, body, kind="text/plain; charset=utf-8"):
            data = body.encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", kind)
            self.send_header("Content-Length", str(len(data)))
            for name, value in SECURITY_HEADERS.items():
                self.send_header(name, value)
            self.end_headers()
            self.wfile.write(data)

        def _json(self, code, obj):
            self._send(code, json.dumps(obj), "application/json")

        def _local(self):
            """True when the request was addressed to this server by its own name."""
            port = self.server.server_address[1]
            return self.headers.get("Host") in ("127.0.0.1:%d" % port, "localhost:%d" % port)

        def _own_origin(self):
            origin = self.headers.get("Origin")
            port = self.server.server_address[1]
            return origin is None or origin in ("http://127.0.0.1:%d" % port, "http://localhost:%d" % port)

        def do_GET(self):
            if not self._local():
                return self._send(403, "Forbidden")
            url = urlsplit(self.path)
            query = {key: values[0] for key, values in parse_qs(url.query).items()}
            if url.path in ("/", "/index.html"):
                self._send(200, page_path.read_text(encoding="utf-8"), "text/html; charset=utf-8")
            elif url.path == "/api/state":
                self._json(200, app.view())
            elif url.path == "/api/prompt":
                try:
                    self._send(200, app.prompt(query.get("id", "")))
                except rw_lib.RewriteError as exc:
                    self._send(400, str(exc))
            else:
                self._send(404, "Not found")

        def do_POST(self):
            if not self._local():
                return self._send(403, "Forbidden")
            if urlsplit(self.path).path != "/api/copied":
                return self._send(404, "Not found")
            if not self._own_origin() or self.headers.get("X-Rewrite") != "1":
                return self._send(403, "Forbidden")
            try:
                length = int(self.headers.get("Content-Length", ""))
                if not 0 <= length <= MAX_BODY:
                    raise ValueError
                body = json.loads(self.rfile.read(length).decode("utf-8"))
                batch_id = body["id"]
                if not isinstance(batch_id, str):
                    raise ValueError
            except (ValueError, KeyError, TypeError, UnicodeError):
                return self._send(400, "Bad request")
            try:
                self._json(200, app.copied(batch_id))
            except rw_lib.RewriteError as exc:
                self._send(400, str(exc))

        def log_message(self, *args):
            pass

    return Handler


def main():
    ctx = rw_lib.Ctx()
    if not ctx.state_file("batches.json").exists():
        print("No batches are planned yet.\nRun: python3 -I tools/content_rewrite/relay/planner.py plan")
        return 1
    server = ThreadingHTTPServer((HOST, PORT), make_handler(App(ctx), Path(__file__).resolve().parent / "page.html"))
    print("CSE rewrite page: http://%s:%d" % (HOST, PORT))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
