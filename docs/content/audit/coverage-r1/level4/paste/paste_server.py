"""The local paste page for the Level 4 lesson audit.

Usage: python3 -I level4/paste/paste_server.py      then open http://127.0.0.1:8766

Binds to this Mac only. Every request must name this server as its Host, so a
website that points its own domain at 127.0.0.1 is refused. Every POST also
needs the X-L4 header and, when the browser sends one, this page's own Origin,
so no other site can submit a reply here. These are the rules in level4/server.py.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

PASTE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(PASTE_DIR))  # python3 -I does not add the script's folder

import paste_lib  # noqa: E402

HOST, PORT = "127.0.0.1", 8766
ACTIONS = ("check", "start-over")
MAX_BODY = 5 * 1024 * 1024
SECURITY_HEADERS = {
    "Cache-Control": "no-store",
    "Content-Security-Policy": "default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; "
                               "connect-src 'self'; base-uri 'none'; form-action 'none'",
    "X-Content-Type-Options": "nosniff",
}


def make_handler(lists, page_path):
    """lists: {key: list object with view(), prompt(id), check(id, reply), start_over(id)}."""

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
                self._json(200, {"lists": [item.view() for item in lists.values()]})
            elif url.path == "/api/prompt":
                target = lists.get(query.get("list", ""))
                if target is None:
                    return self._send(404, "Not found")
                try:
                    self._send(200, target.prompt(query.get("id", "")))
                except paste_lib.PasteError as exc:
                    self._send(400, str(exc))
            else:
                self._send(404, "Not found")

        def do_POST(self):
            action = urlsplit(self.path).path[len("/api/"):] if self.path.startswith("/api/") else ""
            if not self._local():
                return self._send(403, "Forbidden")
            if action not in ACTIONS:
                return self._send(404, "Not found")
            if not self._own_origin() or self.headers.get("X-L4") != "1":
                return self._send(403, "Forbidden")
            try:
                length = int(self.headers.get("Content-Length", ""))
                if not 0 <= length <= MAX_BODY:
                    raise ValueError
                body = json.loads(self.rfile.read(length).decode("utf-8"))
                target = lists[body["list"]]
                packet_id = body["id"]
                if not isinstance(packet_id, str):
                    raise ValueError
            except (ValueError, KeyError, TypeError, UnicodeError):
                return self._send(400, "Bad request")
            try:
                if action == "check":
                    reply = body.get("text")
                    if not isinstance(reply, str):
                        return self._send(400, "Bad request")
                    self._json(200, target.check(packet_id, reply))
                else:
                    target.start_over(packet_id)
                    self._json(200, target.view())
            except paste_lib.PasteError as exc:
                self._send(400, str(exc))

        def log_message(self, *args):
            pass

    return Handler


def main():
    try:
        ids = paste_lib.read_scope()
        lessons = paste_lib.LessonList()
        if lessons.ids() != ids:
            raise paste_lib.PasteError("scope.txt no longer matches the prepared run")
    except (paste_lib.PasteError, OSError, ValueError, KeyError) as exc:
        print("The paste run is not ready (%s).\nRun: python3 -I level4/paste/setup_paste.py" % exc)
        return 1
    lists = {lessons.key: lessons}
    server = ThreadingHTTPServer((HOST, PORT), make_handler(lists, PASTE_DIR / "page.html"))
    print("Level 4 paste page: http://%s:%d" % (HOST, PORT))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
