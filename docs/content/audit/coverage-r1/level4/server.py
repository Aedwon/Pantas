"""The local page and the loop that drives the run.

Usage: python3 server.py            then open http://127.0.0.1:8765

Binds to this Mac only. Every request must name this server as its Host, so
a website that points its own domain at 127.0.0.1 is refused. Controls also
need the X-L4 header and, when the browser sends one, this page's own Origin,
so no other site can press Start or Hold here.
"""
import json
import sys
import threading
import time
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import build_packets
import dispatch
import eraser
import l4lib
import report
import runqueue

HOST, PORT = "127.0.0.1", 8765
TICK_SECONDS = 15
ACTIONS = ("start", "pause", "resume", "restart", "hold")
REPORTS = {"/report/pilot": report.pilot_report, "/report/hold-list": report.hold_list}


def make_handler(run, lock, page_path, reports=None):
    reports = REPORTS if reports is None else reports

    class Handler(BaseHTTPRequestHandler):
        def _send(self, code, body, kind="text/plain; charset=utf-8"):
            data = body.encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", kind)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(data)

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
            if self.path in ("/", "/index.html"):
                self._send(200, page_path.read_text(encoding="utf-8"), "text/html; charset=utf-8")
            elif self.path == "/api/state":
                with lock:
                    view = run.view()
                self._send(200, json.dumps(view), "application/json")
            elif self.path in reports:
                try:
                    self._send(200, reports[self.path]())
                except Exception as exc:  # a report must never take the page down
                    self._send(500, "The report could not be built: %s" % exc)
            elif self.path == "/report/summary":
                path = l4lib.LEVEL4_DIR / "results" / "summary.md"
                self._send(200, path.read_text(encoding="utf-8") if path.exists()
                           else "The summary is written when the lead publishes the final results.")
            else:
                self._send(404, "Not found")

        def do_POST(self):
            action = self.path[len("/api/"):] if self.path.startswith("/api/") else ""
            if not self._local():
                return self._send(403, "Forbidden")
            if action not in ACTIONS:
                return self._send(404, "Not found")
            if not self._local() or not self._own_origin() or self.headers.get("X-L4") != "1":
                return self._send(403, "Forbidden")
            with lock:
                if action == "restart":
                    run.restart_current()
                elif action == "hold":
                    run.hold_current("")
                else:
                    getattr(run, action)()
            self._send(200, "ok")

        def log_message(self, *args):
            pass

    return Handler


def tick_forever(run, lock, seconds=TICK_SECONDS, stop=None):
    while not (stop and stop.is_set()):
        try:
            with lock:
                run.tick()
        except Exception:
            # A failed GitHub call or dispatcher command must not end the loop;
            # the next tick tries again from the saved state.
            traceback.print_exc()
        time.sleep(seconds)


def main():
    config = build_packets.load_config()
    run = runqueue.Run(dispatch, config=config,
                       erase=lambda packet_id, role, attempt, since: eraser.erase_handin(
                           packet_id, role, attempt, config, since))
    if run.q is None:
        print("No run is set up yet. Create the queue first.")
        return 1
    lock = threading.Lock()
    threading.Thread(target=tick_forever, args=(run, lock), daemon=True).start()
    server = ThreadingHTTPServer((HOST, PORT), make_handler(run, lock, l4lib.LEVEL4_DIR / "page" / "index.html"))
    print("Level 4 audit page: http://%s:%d" % (HOST, PORT))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
