#!/usr/bin/env python3
"""Fail-closed support primitives for the local Pantas Release E2E runner."""

import argparse
import hashlib
import json
import os
import pathlib
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

EXPECTED_FLUTTER_VERSION = "3.41.9"
EXPECTED_FLUTTER_REVISION = "00b0c91f06209d9e4a41f71b7a512d6eb3b9c694"
EXPECTED_DART_VERSION = "3.11.5"
EXPECTED_GRADLE_VERSION = "8.14"
EXPECTED_AGP_VERSION = "8.11.1"
EXPECTED_REMOTE = "Aedwon/Pantas"
PRODUCTION_INDICATORS = (
    "GOOGLE_APPLICATION_CREDENTIALS",
    "FIREBASE_TOKEN",
    "FIREBASE_CONFIG",
    "REVENUECAT_ANDROID_API_KEY",
    "REVENUECAT_API_KEY",
    "PROD_FIREBASE_GOOGLE_SERVICES_JSON",
    "CM_KEYSTORE_PATH",
    "CM_KEYSTORE_PASSWORD",
    "CM_KEY_ALIAS",
    "CM_KEY_PASSWORD",
)
PROJECT_ENV_NAMES = (
    "GCLOUD_PROJECT",
    "GOOGLE_CLOUD_PROJECT",
    "FIREBASE_PROJECT",
    "FIREBASE_PROJECT_ID",
)
SHA40 = re.compile(r"^[0-9a-fA-F]{40}$")
SHA64 = re.compile(r"^[0-9a-fA-F]{64}$")
CONTENT_PREFIX = re.compile(
    r"^const contentSeedVersion = '([0-9a-f]{8,64})';$", re.MULTILINE
)


def fail(message):
    raise RuntimeError(message)


def run(command, cwd=None, check=True):
    result = subprocess.run(
        command,
        cwd=str(cwd) if cwd is not None else None,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if check and result.returncode != 0:
        fail("command failed: {}".format(command[0]))
    return result


def git(root, *args, check=True):
    return run(["git", "-C", str(root)] + list(args), check=check)


def require_command(name):
    if shutil.which(name) is None:
        fail("required command '{}' is unavailable".format(name))


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def content_prefix(text):
    match = CONTENT_PREFIX.search(text)
    if match is None:
        fail("tracked content seed version is invalid")
    return match.group(1)


def allowed_diff_path(path):
    if path == "tools/release/test_e2e.sh":
        return True
    if path.startswith("tools/release/e2e/"):
        return True
    if path.startswith("integration_test/release/"):
        return True
    if path.startswith("test/tool/release_e2e_") and path.endswith(".dart"):
        return True
    lowered = path.lower()
    if path.startswith("docs/") and ("release-e2e" in lowered or "release_e2e" in lowered):
        return True
    if path == ".github/workflows/main.yml":
        return True
    return False


def remove_yaml_job(text, job_name):
    lines = text.splitlines(True)
    marker = "  {}:".format(job_name)
    start = None
    for index, line in enumerate(lines):
        if line.rstrip("\r\n") == marker:
            start = index
            break
    if start is None:
        fail("candidate workflow does not contain jobs.{}".format(job_name))
    end = len(lines)
    for index in range(start + 1, len(lines)):
        line = lines[index]
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if line.startswith("  ") and not line.startswith("    "):
            end = index
            break
    return "".join(lines[:start] + lines[end:])


def validate_workflow_removal(root, candidate):
    current_path = root / ".github/workflows/main.yml"
    if not current_path.is_file():
        fail("workflow file is missing")
    candidate_result = git(
        root, "show", "{}:.github/workflows/main.yml".format(candidate)
    )
    expected = remove_yaml_job(candidate_result.stdout, "integration")
    current = current_path.read_text(encoding="utf-8")
    if current != expected:
        fail("workflow change must delete only jobs.integration")


def validate_remote(root):
    result = git(root, "remote", "get-url", "origin")
    remote = result.stdout.strip().rstrip("/")
    normalized = remote[:-4] if remote.endswith(".git") else remote
    if not normalized.endswith(EXPECTED_REMOTE):
        fail("repository origin is not Aedwon/Pantas")


def validate_clean(root):
    result = git(root, "status", "--porcelain=v1", "--untracked-files=all")
    if result.stdout.strip():
        fail("worktree is not clean")


def validate_candidate(root, candidate):
    if SHA40.fullmatch(candidate) is None:
        fail("candidate must be a full 40-character Git SHA")
    resolved = git(
        root, "rev-parse", "{}^{{commit}}".format(candidate), check=False
    )
    if resolved.returncode != 0 or resolved.stdout.strip().lower() != candidate.lower():
        fail("candidate is not a full commit object")
    ancestor = git(
        root, "merge-base", "--is-ancestor", candidate, "HEAD", check=False
    )
    if ancestor.returncode != 0:
        fail("candidate is not an ancestor of the checked-out branch")
    changed = git(
        root, "diff", "--name-only", "{}...HEAD".format(candidate)
    ).stdout.splitlines()
    unexpected = [path for path in changed if not allowed_diff_path(path)]
    if unexpected:
        fail("candidate diff contains an unapproved path: {}".format(unexpected[0]))
    if ".github/workflows/main.yml" in changed:
        validate_workflow_removal(root, candidate)


def validate_content(root, candidate, expected_sha):
    if SHA64.fullmatch(expected_sha) is None:
        fail("content SHA must be a full 64-character SHA-256")
    content_path = root / "assets/seed/content.db"
    if not content_path.is_file():
        fail("assets/seed/content.db is missing")
    actual = sha256_file(content_path)
    if actual != expected_sha.lower():
        fail("content SHA-256 mismatch")
    version_path = root / "lib/core/content/content_seed_version.dart"
    if not version_path.is_file():
        fail("tracked content seed version source is missing")
    current_prefix = content_prefix(version_path.read_text(encoding="utf-8"))
    candidate_version = git(
        root,
        "show",
        "{}:lib/core/content/content_seed_version.dart".format(candidate),
    ).stdout
    candidate_prefix = content_prefix(candidate_version)
    if current_prefix != candidate_prefix or not actual.startswith(current_prefix):
        fail("tracked content seed version does not match shipping content")
    return actual, current_prefix


def validate_environment():
    for name in PRODUCTION_INDICATORS:
        if os.environ.get(name, "").strip():
            fail("production credential/service indicator is present: {}".format(name))
    for name in PROJECT_ENV_NAMES:
        value = os.environ.get(name, "").strip()
        if value and not value.startswith("demo-"):
            fail("production credential/service indicator is present: {}".format(name))


def validate_toolchain(root):
    for command in ("flutter", "java", "firebase", "adb"):
        require_command(command)
    flutter_result = run(["flutter", "--version", "--machine"])
    try:
        flutter_data = json.loads(flutter_result.stdout)
    except json.JSONDecodeError:
        fail("Flutter version output is not valid machine JSON")
    if flutter_data.get("frameworkVersion") != EXPECTED_FLUTTER_VERSION:
        fail("Flutter 3.41.9 is required")
    if flutter_data.get("frameworkRevision") != EXPECTED_FLUTTER_REVISION:
        fail("Flutter 3.41.9 pinned framework revision is required")
    if flutter_data.get("dartSdkVersion") != EXPECTED_DART_VERSION:
        fail("Dart 3.11.5 is required")

    java_result = run(["java", "-version"])
    java_text = java_result.stderr + java_result.stdout
    if re.search(r'version "17(?:[._+"]|$)', java_text) is None:
        fail("JDK 17 is required")

    gradlew = root / "android/gradlew"
    wrapper_jar = root / "android/gradle/wrapper/gradle-wrapper.jar"
    if not gradlew.is_file() or not os.access(str(gradlew), os.X_OK):
        fail("Android Gradle wrapper is missing or not executable")
    if not wrapper_jar.is_file():
        fail("Gradle wrapper JAR is missing")
    gradle_result = run([str(gradlew), "--version"], cwd=root / "android")
    if re.search(
        r"(?m)^Gradle {}$".format(re.escape(EXPECTED_GRADLE_VERSION)),
        gradle_result.stdout,
    ) is None:
        fail("Gradle 8.14 is required")

    settings = (root / "android/settings.gradle.kts").read_text(encoding="utf-8")
    agp_pin = 'id("com.android.application") version "{}"'.format(
        EXPECTED_AGP_VERSION
    )
    if agp_pin not in settings:
        fail("AGP 8.11.1 is required")

    firebase_version = run(["firebase", "--version"]).stdout.strip()
    if not firebase_version:
        fail("Firebase CLI version could not be determined")
    adb_version = run(["adb", "version"]).stdout.splitlines()
    if not adb_version:
        fail("ADB version could not be determined")

    return {
        "flutter_version": EXPECTED_FLUTTER_VERSION,
        "flutter_revision": EXPECTED_FLUTTER_REVISION,
        "dart_version": EXPECTED_DART_VERSION,
        "java_version": java_text.splitlines()[0] if java_text.splitlines() else "unknown",
        "gradle_version": EXPECTED_GRADLE_VERSION,
        "agp_version": EXPECTED_AGP_VERSION,
        "firebase_cli_version": firebase_version,
        "adb_version": adb_version[0],
    }


def validate_device(serial):
    if not serial or re.search(r"\s", serial):
        fail("ADB target serial is invalid")
    result = run(["adb", "devices"])
    matches = []
    for line in result.stdout.splitlines()[1:]:
        parts = line.split()
        if parts and parts[0] == serial:
            matches.append(parts[1] if len(parts) > 1 else "unknown")
    if len(matches) != 1 or matches[0] != "device":
        fail("ADB target must appear exactly once and be online")
    state = run(["adb", "-s", serial, "get-state"], check=False)
    if state.returncode != 0 or state.stdout.strip() != "device":
        fail("ADB target is not online")
    api = run(
        ["adb", "-s", serial, "shell", "getprop", "ro.build.version.sdk"]
    ).stdout.strip()
    model = run(
        ["adb", "-s", serial, "shell", "getprop", "ro.product.model"]
    ).stdout.strip()
    if not api.isdigit():
        fail("ADB target Android API level is unavailable")
    return api, model or "unknown"


def command_preflight(args):
    root = pathlib.Path(args.repo_root).resolve()
    if not (root / "pubspec.yaml").is_file():
        fail("current directory is not the Pantas repository")
    validate_remote(root)
    validate_clean(root)
    validate_candidate(root, args.candidate)
    actual_sha, prefix = validate_content(root, args.candidate, args.content_sha)
    validate_environment()
    versions = validate_toolchain(root)
    api, model = validate_device(args.device)
    payload = {
        "candidate": args.candidate.lower(),
        "content_sha": actual_sha,
        "content_seed_prefix": prefix,
        "device": args.device,
        "android_api_level": api,
        "device_model": model,
    }
    payload.update(versions)
    print(json.dumps(payload, sort_keys=True))


def parse_host_port(value):
    if value.startswith("["):
        match = re.fullmatch(r"\[([^]]+)\]:(\d+)", value)
    else:
        match = re.fullmatch(r"([^:]+):(\d+)", value)
    if match is None:
        fail("emulator host must include host:port")
    return match.group(1), int(match.group(2))


def validate_loopback(host):
    if host not in ("127.0.0.1", "localhost", "::1"):
        fail("emulator host must resolve to loopback only")


def command_validate_emulator_isolation(args):
    if not args.project_id.startswith("demo-"):
        fail("Firebase emulator project ID must start with demo-")
    auth_host, auth_port = parse_host_port(args.auth_host)
    firestore_host, firestore_port = parse_host_port(args.firestore_host)
    validate_loopback(auth_host)
    validate_loopback(firestore_host)
    if auth_port == firestore_port:
        fail("Auth and Firestore emulator ports must be distinct")


def port_is_free(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(("127.0.0.1", port))
        return True
    except OSError:
        return False
    finally:
        sock.close()


def command_check_ports(args):
    if args.auth_port == args.firestore_port:
        fail("Auth and Firestore emulator ports must be distinct")
    for port in (args.auth_port, args.firestore_port):
        if not port_is_free(port):
            fail("emulator port collision on {}".format(port))


def allocate_port(exclude=None):
    for _ in range(20):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            sock.bind(("127.0.0.1", 0))
            port = sock.getsockname()[1]
        finally:
            sock.close()
        if port != exclude:
            return port
    fail("could not allocate distinct emulator ports")


def command_allocate_ports(_args):
    auth = allocate_port()
    firestore = allocate_port(exclude=auth)
    print(json.dumps({"auth_port": auth, "firestore_port": firestore}, sort_keys=True))


def command_wait_port_free(args):
    if args.deadline_ms < 0:
        fail("deadline must be non-negative")
    deadline = time.monotonic() + (args.deadline_ms / 1000.0)
    while True:
        if port_is_free(args.port):
            return
        if time.monotonic() >= deadline:
            fail("timed out waiting for port to become free: {}".format(args.port))
        time.sleep(0.05)


def command_verify_pm_clear(args):
    if args.output.strip() != "Success":
        fail("adb pm clear did not report Success")


def command_prepare_diagnostics(args):
    path = pathlib.Path(args.path)
    try:
        path.mkdir(parents=True, exist_ok=False)
    except OSError as exc:
        fail("diagnostics directory creation failed: {}".format(type(exc).__name__))
    print(str(path))


REDACTION_PATTERNS = (
    (
        re.compile(r"(?i)(authorization\s*:\s*bearer\s+)[^\s]+"),
        r"\1[REDACTED]",
    ),
    (
        re.compile(r"(?i)(?:[A-Z0-9._%+-]+)@(?:[A-Z0-9.-]+\.[A-Z]{2,})"),
        "[REDACTED]",
    ),
    (re.compile(r"AIza[0-9A-Za-z_-]+"), "[REDACTED]"),
    (
        re.compile(
            r"(?i)-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----",
            re.DOTALL,
        ),
        "[REDACTED]",
    ),
    (
        re.compile(
            r"(?i)\b(token|cookie|password|secret|api[_-]?key|payload|answer|learner[_-]?data)\s*[=:]\s*[^\s,;]+"
        ),
        r"\1=[REDACTED]",
    ),
    (
        re.compile(r"\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b"),
        "[REDACTED]",
    ),
)


def redact(text):
    output = text
    for pattern, replacement in REDACTION_PATTERNS:
        output = pattern.sub(replacement, output)
    return output


def command_redact(args):
    sys.stdout.write(redact(args.text))
    if not args.text.endswith("\n"):
        sys.stdout.write("\n")


def command_redact_stream(args):
    output_path = pathlib.Path(args.output)
    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        lines = []
        for line in sys.stdin:
            lines.append(redact(line))
            if len(lines) > args.max_lines:
                lines.pop(0)
        with output_path.open("w", encoding="utf-8") as handle:
            handle.writelines(lines)
    except OSError as exc:
        fail("diagnostic redaction/write failed: {}".format(type(exc).__name__))


def command_append_result(args):
    record = {
        "scenario": args.scenario,
        "outcome": args.outcome,
        "runtime_seconds": args.runtime_seconds,
    }
    path = pathlib.Path(args.results)
    try:
        with path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(record, sort_keys=True) + "\n")
    except OSError as exc:
        fail("scenario result write failed: {}".format(type(exc).__name__))


def atomic_write(path, text):
    path = pathlib.Path(path)
    directory = path.parent
    fd = None
    temp_name = None
    try:
        fd, temp_name = tempfile.mkstemp(prefix=path.name + ".", dir=str(directory))
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            fd = None
            handle.write(text)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_name, path)
    except OSError as exc:
        if fd is not None:
            os.close(fd)
        if temp_name and os.path.exists(temp_name):
            os.unlink(temp_name)
        fail("summary write failed: {}".format(type(exc).__name__))


def command_write_summary(args):
    records = []
    try:
        with open(args.results, "r", encoding="utf-8") as handle:
            for line in handle:
                if line.strip():
                    item = json.loads(line)
                    if not all(
                        key in item
                        for key in ("scenario", "outcome", "runtime_seconds")
                    ):
                        fail("summary input is incomplete")
                    records.append(item)
    except (OSError, json.JSONDecodeError) as exc:
        fail("summary input could not be read: {}".format(type(exc).__name__))
    payload = {
        "candidate": args.candidate,
        "content_sha": args.content_sha,
        "device": args.device,
        "outcome": args.outcome,
        "total_runtime_seconds": args.total_runtime_seconds,
        "scenarios": records,
    }
    text_lines = [
        "Release E2E {}".format(args.outcome.upper()),
        "candidate={}".format(args.candidate),
        "content_sha={}".format(args.content_sha),
        "device={}".format(args.device),
    ]
    for record in records:
        text_lines.append(
            "{}: {} ({}s)".format(
                record["scenario"], record["outcome"], record["runtime_seconds"]
            )
        )
    text_lines.append("total_runtime_seconds={}".format(args.total_runtime_seconds))
    atomic_write(
        args.json_output, json.dumps(payload, indent=2, sort_keys=True) + "\n"
    )
    atomic_write(args.text_output, "\n".join(text_lines) + "\n")


def command_write_firebase_config(args):
    config = {
        "firestore": {
            "rules": str(pathlib.Path(args.rules).resolve()),
            "indexes": str(pathlib.Path(args.indexes).resolve()),
        },
        "emulators": {
            "auth": {"host": "127.0.0.1", "port": args.auth_port},
            "firestore": {
                "host": "127.0.0.1",
                "port": args.firestore_port,
            },
            "ui": {"enabled": False},
            "singleProjectMode": True,
        },
    }
    atomic_write(args.output, json.dumps(config, indent=2, sort_keys=True) + "\n")


def request(method, url):
    req = urllib.request.Request(url, method=method)
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            return response.status, response.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode("utf-8", errors="replace")
    except (urllib.error.URLError, TimeoutError, OSError):
        fail("Firebase emulator reset endpoint is unavailable")


def command_reset_emulators(args):
    if not args.project_id.startswith("demo-"):
        fail("Firebase emulator project ID must start with demo-")
    auth_base = "http://127.0.0.1:{}".format(args.auth_port)
    firestore_base = "http://127.0.0.1:{}".format(args.firestore_port)
    auth_path = "/emulator/v1/projects/{}/accounts".format(args.project_id)
    firestore_path = "/emulator/v1/projects/{}/databases/(default)/documents".format(
        args.project_id
    )
    for url in (auth_base + auth_path, firestore_base + firestore_path):
        status, _ = request("DELETE", url)
        if status < 200 or status >= 300:
            fail("Firebase emulator cleanup failed")

    auth_status, auth_body = request("GET", auth_base + auth_path)
    if auth_status >= 300:
        fail("Firebase Auth emulator cleanup verification failed")
    try:
        auth_data = json.loads(auth_body or "{}")
    except json.JSONDecodeError:
        fail("Firebase Auth emulator cleanup verification was not JSON")
    users = auth_data.get("users", auth_data.get("accounts", []))
    if users:
        fail("Firebase Auth emulator cleanup verification found accounts")

    firestore_list = (
        "http://127.0.0.1:{}/v1/projects/{}/databases/(default)/documents?pageSize=1"
    ).format(args.firestore_port, args.project_id)
    fs_status, fs_body = request("GET", firestore_list)
    if fs_status >= 300:
        fail("Firestore emulator cleanup verification failed")
    try:
        fs_data = json.loads(fs_body or "{}")
    except json.JSONDecodeError:
        fail("Firestore emulator cleanup verification was not JSON")
    if fs_data.get("documents"):
        fail("Firestore emulator cleanup verification found documents")


def build_parser():
    parser = argparse.ArgumentParser(prog="runner_support.py")
    sub = parser.add_subparsers(dest="command", required=True)

    preflight = sub.add_parser("preflight")
    preflight.add_argument("--repo-root", required=True)
    preflight.add_argument("--candidate", required=True)
    preflight.add_argument("--content-sha", required=True)
    preflight.add_argument("--device", required=True)
    preflight.set_defaults(func=command_preflight)

    isolation = sub.add_parser("validate-emulator-isolation")
    isolation.add_argument("--project-id", required=True)
    isolation.add_argument("--auth-host", required=True)
    isolation.add_argument("--firestore-host", required=True)
    isolation.set_defaults(func=command_validate_emulator_isolation)

    check_ports = sub.add_parser("check-ports")
    check_ports.add_argument("--auth-port", type=int, required=True)
    check_ports.add_argument("--firestore-port", type=int, required=True)
    check_ports.set_defaults(func=command_check_ports)

    allocate = sub.add_parser("allocate-ports")
    allocate.set_defaults(func=command_allocate_ports)

    wait_free = sub.add_parser("wait-port-free")
    wait_free.add_argument("--port", type=int, required=True)
    wait_free.add_argument("--deadline-ms", type=int, required=True)
    wait_free.set_defaults(func=command_wait_port_free)

    pm_clear = sub.add_parser("verify-pm-clear")
    pm_clear.add_argument("--output", required=True)
    pm_clear.set_defaults(func=command_verify_pm_clear)

    diagnostics = sub.add_parser("prepare-diagnostics")
    diagnostics.add_argument("--path", required=True)
    diagnostics.set_defaults(func=command_prepare_diagnostics)

    redact_parser = sub.add_parser("redact")
    redact_parser.add_argument("--text", required=True)
    redact_parser.set_defaults(func=command_redact)

    redact_stream = sub.add_parser("redact-stream")
    redact_stream.add_argument("--output", required=True)
    redact_stream.add_argument("--max-lines", type=int, default=400)
    redact_stream.set_defaults(func=command_redact_stream)

    append = sub.add_parser("append-result")
    append.add_argument("--results", required=True)
    append.add_argument("--scenario", required=True)
    append.add_argument("--outcome", choices=("pass", "fail"), required=True)
    append.add_argument("--runtime-seconds", type=int, required=True)
    append.set_defaults(func=command_append_result)

    summary = sub.add_parser("write-summary")
    summary.add_argument("--results", required=True)
    summary.add_argument("--json-output", required=True)
    summary.add_argument("--text-output", required=True)
    summary.add_argument("--candidate", required=True)
    summary.add_argument("--content-sha", required=True)
    summary.add_argument("--device", required=True)
    summary.add_argument("--total-runtime-seconds", type=int, required=True)
    summary.add_argument("--outcome", choices=("pass", "fail"), default="pass")
    summary.set_defaults(func=command_write_summary)

    firebase_config = sub.add_parser("write-firebase-config")
    firebase_config.add_argument("--output", required=True)
    firebase_config.add_argument("--rules", required=True)
    firebase_config.add_argument("--indexes", required=True)
    firebase_config.add_argument("--auth-port", type=int, required=True)
    firebase_config.add_argument("--firestore-port", type=int, required=True)
    firebase_config.set_defaults(func=command_write_firebase_config)

    reset = sub.add_parser("reset-emulators")
    reset.add_argument("--project-id", required=True)
    reset.add_argument("--auth-port", type=int, required=True)
    reset.add_argument("--firestore-port", type=int, required=True)
    reset.set_defaults(func=command_reset_emulators)

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except RuntimeError as exc:
        print("release e2e support failed: {}".format(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
