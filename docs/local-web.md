# Local web visual check

From the repository root on your Mac:

```bash
tools/local/run_web_local.sh
```

Requires Flutter/Dart, Python 3, Node 22, and Java 21. The runner uses Homebrew's
Node 22 and Java 21 when installed. The first run downloads dependencies and
emulator binaries. No Firebase login or real credentials are needed.

Open the printed `/local-login.html` URL. Choose Free or Pro. The local links
sign in before the normal app starts, so you do not need Google sign-in.
Test logins are also printed and saved in `build/local-web/logins.txt` (gitignored).
Use separate browser profiles for both accounts at once.

The command starts Auth (9099), Firestore (8080), Functions (5001), Storage (9199),
and a web server (7357) using only `demo-pantas-local`. It checks ports before
starting. `--port 7358` changes the web port. Ctrl-C stops everything. Each run
creates fresh emulator data. Logs are in `build/local-web/`.

Content uses the normal uploader and `build/export.json`. The default is `--corpus cse`.
If CSE export fails, a one-line notice reports the fallback to this code branch's
corpus for layout checks. Use `--corpus code` to select it directly.
If this checkout lacks
the rewritten CSE corpus, the runner extracts the locally available
`origin/content/cse-rewrite-r1` into `build/local-web/corpus`. It does not fetch or
change branches. Pro uses the existing server trial grant, including its normal
seven-day expiry and server claims. The local App Check debug exchange never
contacts the real App Check service. Remote Config and telemetry are disabled.
The Functions emulator uses an isolated folder with fake local configuration.
Its HTTP clients reject external services.

The Pro page is available. Checkout cannot complete locally. No payment API is
called. Install and offline need HTTPS and are tested after deploy.

For your iPhone on the same trusted Wi-Fi:

```bash
tools/local/run_web_local.sh --lan
```

The runner detects the Mac's active LAN address, binds all services to it, and
prints the URL plus an ASCII QR code if the installed dependencies include a QR
package. Otherwise it prints the URL as plain text. Allow local network access
if macOS asks. You can set an address explicitly with `--lan --host 192.168.1.10`.
LAN mode exposes disposable emulator data to that network. Do not use public Wi-Fi.

Check the planned commands without starting services or changing files:

```bash
tools/local/run_web_local.sh --dry-run
tools/local/run_web_local.sh --lan --dry-run
```

## Verification

Run the service-free script checks with:

```bash
bash -n tools/local/run_web_local.sh
python3 -m unittest tools/local/test_run_web_local.py
```

The CSE rewrite currently has a missing figure credit. Its export fails validation,
so the default command uses the code corpus. The rewritten CSE export keeps full validation. For the code corpus only, the
uploader uses its existing `--skip-invalid` option and lists each omission.
Currently it omits two oversized lessons and one malformed question file.
This corpus has the older CSE scaffold. Use it to check layouts while the content
owner fixes the rewrite.

Policy read from `origin/main` at `6fe0445090c0a43786cb1f1d4c059ed5e74d4aef`.

Verified locally: default CSE export failure and code fallback, emulator seeding,
Free and Pro account creation with server grant claims, profile web build, HTTP 200
for the served page, and authenticated `getContent` returning the CSE catalog.
Ctrl-C stopped the runner and services. LAN dry-run passes; iPhone access and
visual appearance still need Aedwon's check. Checkout cannot complete locally.

Checks: five Python tests passed; shell syntax passed; Flutter analysis found no
issues; format checked 1695 files with no changes; attribution and layering passed;
24 focused Firebase bootstrap, App Check, and remote flag tests passed.
