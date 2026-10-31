"""POST /local-seed for the local web runner: checks a request, then seeds one sample student."""
import ipaddress
import json
import re
import subprocess
import threading

PROFILES = ('new', 'steady', 'behind', 'examWeek')
UID = re.compile(r'^[A-Za-z0-9_-]{1,128}$')
_one_at_a_time = threading.Lock()


class Refused(Exception):
    def __init__(self, status, message):
        super().__init__(message)
        self.status = status


def check(body, content_type, client_ip, host, port, origin, lan):
    """Returns (uid, profile). Raises Refused. Only this machine's own page may ask."""
    if lan:
        raise Refused(403, 'Sample students are not available with --lan.')
    try:
        if not ipaddress.ip_address(client_ip.split('%')[0]).is_loopback:
            raise ValueError
    except ValueError:
        raise Refused(403, 'Local requests only.') from None
    # A JSON content type forces a cross-site page to ask first; the origin must be this server.
    if (content_type or '').split(';')[0].strip() != 'application/json':
        raise Refused(415, 'Send JSON.')
    if origin is not None and origin not in {f'http://{name}:{port}' for name in (host, 'localhost', '127.0.0.1')}:
        raise Refused(403, 'Not from this page.')
    try:
        data = json.loads(body)
        uid, profile = data['uid'], data['profile']
    except (ValueError, KeyError, TypeError):
        raise Refused(400, 'Send uid and profile.') from None
    if not isinstance(uid, str) or not UID.match(uid) or profile not in PROFILES:
        raise Refused(400, 'Unknown account or student.')
    return uid, profile


def seed(uid, profile, env, script='tools/local/seed_student.mjs', timeout=240):
    """Runs the seed script against the emulators. Returns its JSON result."""
    with _one_at_a_time:
        done = subprocess.run(['node', script, uid, profile], env=env, capture_output=True, text=True,
                              timeout=timeout)
    if done.returncode != 0:
        raise Refused(500, (done.stderr or done.stdout).strip().splitlines()[-1][:300] if (done.stderr or done.stdout).strip() else 'Seed failed.')
    return json.loads(done.stdout.strip().splitlines()[-1])
