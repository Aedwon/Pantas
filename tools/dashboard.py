#!/usr/bin/env python3
"""
Pantas Demo Control Server
Precision instrument for controlling demo state during presentations.
Ink and Rule design language: tabular data, hairline rules, SVG icons, zero emojis.
"""

import http.server
import json
import os
import re
import socket
import subprocess
import sys
import urllib.request
import urllib.error
from urllib.parse import urlparse, parse_qs

PORT = 4040
PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANUAL_URIS = {}  # device_id -> uri
DEVICE_CACHE = {} # device_id -> {uri, isolate_id, host_port}

def get_local_ip():
    """Get the primary local Wi-Fi / Hotspot IP address on macOS."""
    for cmd in [
        ["ipconfig", "getifaddr", "en0"],
        ["ipconfig", "getifaddr", "en1"],
        ["ipconfig", "getifaddr", "bridge100"],
    ]:
        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=1)
            ip = res.stdout.strip()
            if ip and not ip.startswith("127."):
                return ip
        except Exception:
            pass
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

def run_adb(args, timeout=5):
    """Run an adb command safely."""
    cmd = ["adb"] + args
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return res.returncode == 0, res.stdout.strip(), res.stderr.strip()
    except Exception as e:
        return False, "", str(e)

def http_get_json(url, timeout=3):
    """Perform a fast HTTP GET and parse JSON."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "PantasDemo/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            data = response.read().decode("utf-8")
            return True, json.loads(data)
    except Exception as e:
        return False, str(e)

def get_vm_isolate(base_url):
    """Fetch the main Flutter isolate ID from the Dart VM service."""
    base_clean = base_url.rstrip("/")
    success, data = http_get_json(f"{base_clean}/getVM")
    if not success or not isinstance(data, dict):
        return None
    try:
        isolates = data.get("result", {}).get("isolates", [])
        for iso in isolates:
            if iso.get("name", "").endswith("main"):
                return iso.get("id")
        if isolates:
            return isolates[0].get("id")
    except Exception:
        pass
    return None

def check_pro_status(base_url, isolate_id):
    """Query ext.pantas.pro to get current Pro status."""
    if not base_url or not isolate_id:
        return None
    base_clean = base_url.rstrip("/")
    success, data = http_get_json(f"{base_clean}/ext.pantas.pro?isolateId={isolate_id}&value=report")
    if success and isinstance(data, dict):
        result = data.get("result", {})
        return result.get("pro")
    return None

CACHE_FILE = os.path.join(PROJECT_DIR, ".dart_tool", "pantas_device_cache.json")

def load_device_cache():
    global DEVICE_CACHE
    try:
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, "r") as f:
                DEVICE_CACHE = json.load(f)
    except Exception:
        pass

def save_device_cache():
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump(DEVICE_CACHE, f)
    except Exception:
        pass

load_device_cache()

def discover_device_vm(device_id):
    """Auto-discover or verify Dart VM service URL for a specific device."""
    # 1. Manual user override
    if device_id in MANUAL_URIS and MANUAL_URIS[device_id]:
        uri = MANUAL_URIS[device_id].rstrip("/")
        isolate = get_vm_isolate(uri)
        if isolate:
            return uri, isolate

    # 2. Check cached URI first
    cached = DEVICE_CACHE.get(device_id, {})
    if cached.get("uri"):
        isolate = get_vm_isolate(cached["uri"])
        if isolate:
            return cached["uri"], isolate

    known_token = cached.get("token")

    # 3. Check active forwarded ports from adb forward --list
    ok, stdout, _ = run_adb(["-s", device_id, "forward", "--list"])
    if ok and stdout:
        for line in stdout.splitlines():
            parts = line.split()
            if len(parts) >= 3 and parts[0] == device_id:
                host_p = parts[1].replace("tcp:", "")
                if known_token:
                    test_uri = f"http://127.0.0.1:{host_p}/{known_token}"
                    iso = get_vm_isolate(test_uri)
                    if iso:
                        DEVICE_CACHE[device_id] = {
                            "uri": test_uri,
                            "isolate_id": iso,
                            "host_port": host_p,
                            "token": known_token
                        }
                        save_device_cache()
                        return test_uri, iso

    # 4. Search logcat for VM URL
    ok, logcat, _ = run_adb(["-s", device_id, "logcat", "-d", "-s", "flutter:V", "DartVM:V"])
    if not ok or not logcat:
        ok, logcat, _ = run_adb(["-s", device_id, "logcat", "-d", "-t", "50000"])

    if ok and logcat:
        matches = re.findall(r"Dart VM service is listening on http://127\.0\.0\.1:(\d+)/([^/\s]+)/?", logcat)
        if not matches:
            matches = re.findall(r"is available at: http://127\.0\.0\.1:(\d+)/([^/\s]+)/?", logcat)
        if not matches:
            matches = re.findall(r"http://127\.0\.0\.1:(\d+)/([^/\s]+)/", logcat)

        if matches:
            dev_port, token = matches[-1]
            ok, fwd_out, _ = run_adb(["-s", device_id, "forward", "tcp:0", f"tcp:{dev_port}"])
            if ok:
                host_port = fwd_out.strip()
                uri = f"http://127.0.0.1:{host_port}/{token}"
                iso = get_vm_isolate(uri)
                if iso:
                    DEVICE_CACHE[device_id] = {
                        "uri": uri,
                        "isolate_id": iso,
                        "host_port": host_port,
                        "device_port": dev_port,
                        "token": token
                    }
                    save_device_cache()
                    return uri, iso

    return None, None

def get_all_devices():
    """List all connected ADB devices and their Dart VM status."""
    ok, stdout, _ = run_adb(["devices", "-l"])
    devices = []
    if not ok or not stdout:
        return devices

    lines = stdout.splitlines()
    raw_devices = []
    has_direct_ip = False

    for line in lines[1:]:
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        dev_id = parts[0]
        state = parts[1] if len(parts) > 1 else "unknown"

        if state != "device":
            continue

        if ":" in dev_id and not "._adb" in dev_id:
            has_direct_ip = True

        raw_devices.append((dev_id, parts))

    for dev_id, parts in raw_devices:
        if has_direct_ip and "._adb-tls" in dev_id:
            continue

        is_emulator = dev_id.startswith("emulator-")
        model = "Android Phone"
        for p in parts[2:]:
            if p.startswith("model:"):
                model = p.replace("model:", "").replace("_", " ")

        short_id = dev_id
        if "._adb-tls" in dev_id:
            short_id = "Wireless Phone"

        vm_uri, isolate_id = discover_device_vm(dev_id)
        pro_status = check_pro_status(vm_uri, isolate_id) if vm_uri else None

        display_name = "Emulator (Projector)" if is_emulator else f"Phone ({model})"

        devices.append({
            "id": dev_id,
            "name": display_name,
            "short_id": short_id,
            "model": model,
            "is_emulator": is_emulator,
            "connected": True,
            "app_running": bool(vm_uri and isolate_id),
            "vm_uri": vm_uri or "",
            "isolate_id": isolate_id or "",
            "pro": pro_status,
        })
    return devices

def execute_action(device_id, action):
    """Execute a demo command on a target device or all devices."""
    devices = get_all_devices()
    targets = []
    if device_id == "all":
        targets = [d for d in devices if d["app_running"]]
    else:
        targets = [d for d in devices if d["id"] == device_id]

    if not targets:
        return {
            "success": False,
            "error": "No connected device with an active Flutter app found.",
            "results": []
        }

    results = []
    for d in targets:
        uri = d["vm_uri"]
        iso = d["isolate_id"]
        if not uri or not iso:
            results.append({"device": d["id"], "success": False, "error": "App is not running or VM service unreachable."})
            continue

        base_clean = uri.rstrip("/")
        req_url = None

        if action == "reset":
            req_url = f"{base_clean}/ext.pantas.demo?isolateId={iso}&action=reset"
        elif action == "populate":
            req_url = f"{base_clean}/ext.pantas.demo?isolateId={iso}&action=populate"
        elif action == "pro":
            req_url = f"{base_clean}/ext.pantas.pro?isolateId={iso}&value=true"
        elif action == "free":
            req_url = f"{base_clean}/ext.pantas.pro?isolateId={iso}&value=false"
        elif action == "refresh":
            req_url = f"{base_clean}/ext.pantas.demo?isolateId={iso}&action=refresh"
        elif action == "reload":
            req_url = f"{base_clean}/ext.flutter.reassemble?isolateId={iso}"

        if not req_url:
            results.append({"device": d["id"], "success": False, "error": f"Unknown action '{action}'"})
            continue

        ok, data = http_get_json(req_url, timeout=6)
        
        if ok and action in ("reset", "populate", "pro", "free", "refresh"):
            http_get_json(f"{base_clean}/ext.flutter.reassemble?isolateId={iso}", timeout=2)

        results.append({
            "device": d["id"],
            "name": d["name"],
            "success": ok,
            "response": data if ok else None,
            "error": None if ok else str(data)
        })

    all_success = any(r["success"] for r in results)
    return {
        "success": all_success,
        "action": action,
        "results": results
    }

HTML_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Pantas Demo Control</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0e1116;
      --surface: #15181f;
      --surface-raised: #1c202a;
      --hairline: rgba(255, 255, 255, 0.12);
      --hairline-subtle: rgba(255, 255, 255, 0.06);
      
      --text: #f0f2f5;
      --text-muted: #88909d;
      --text-dim: #505866;
      
      --board-green: #2e7d32;
      --board-green-text: #4ade80;
      --rust: #dc2626;
      --rust-text: #f87171;
      --ink-blue: #3b82f6;
      
      --radius: 3px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-tap-highlight-color: transparent;
    }

    body {
      background-color: var(--bg);
      color: var(--text);
      font-family: 'Source Sans 3', -apple-system, BlinkMacSystemFont, sans-serif;
      min-height: 100vh;
      font-size: 14px;
      line-height: 1.45;
      -webkit-font-smoothing: antialiased;
    }

    /* SVG Icon styles */
    .icon {
      width: 16px;
      height: 16px;
      fill: none;
      stroke: currentColor;
      stroke-width: 1.75;
      stroke-linecap: round;
      stroke-linejoin: round;
      vertical-align: middle;
      flex-shrink: 0;
    }

    .icon-lg {
      width: 18px;
      height: 18px;
    }

    /* Top Bar */
    header {
      background-color: var(--surface);
      border-bottom: 1px solid var(--hairline);
      padding: 12px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .header-brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .header-title {
      font-size: 15px;
      font-weight: 700;
      letter-spacing: 0.5px;
      text-transform: uppercase;
      color: var(--text);
    }

    .header-sep {
      color: var(--hairline);
    }

    .header-subtitle {
      font-size: 12px;
      color: var(--text-muted);
      letter-spacing: 0.3px;
    }

    .remote-tag {
      display: flex;
      align-items: center;
      gap: 8px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-muted);
      border: 1px solid var(--hairline);
      padding: 4px 10px;
      border-radius: var(--radius);
      background: var(--bg);
    }

    .remote-tag span.url {
      color: var(--text);
      font-weight: 500;
    }

    /* Layout */
    main {
      max-width: 880px;
      margin: 0 auto;
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }

    .section-title {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--text-muted);
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    /* Target Selector Strip */
    .target-strip {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 8px;
    }

    .target-box {
      background: var(--surface);
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
      padding: 12px 14px;
      color: var(--text-muted);
      cursor: pointer;
      display: flex;
      flex-direction: column;
      gap: 6px;
      text-align: left;
      font-family: inherit;
      transition: border-color 0.1s ease, background 0.1s ease;
    }

    .target-box:hover {
      background: var(--surface-raised);
      border-color: rgba(255, 255, 255, 0.25);
    }

    .target-box.active {
      background: var(--surface-raised);
      border-color: var(--ink-blue);
      color: var(--text);
    }

    .target-box-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-size: 13px;
      font-weight: 600;
      color: var(--text);
    }

    .target-box-meta {
      display: flex;
      align-items: center;
      gap: 8px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-dim);
    }

    .dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--text-dim);
      display: inline-block;
    }

    .dot.live {
      background: var(--board-green-text);
    }

    .tier-badge {
      font-size: 10px;
      font-weight: 700;
      padding: 1px 4px;
      border-radius: 2px;
      letter-spacing: 0.5px;
    }

    .tier-badge.pro {
      background: rgba(46, 125, 50, 0.3);
      color: var(--board-green-text);
      border: 1px solid var(--board-green);
    }

    .tier-badge.free {
      background: rgba(255, 255, 255, 0.05);
      color: var(--text-muted);
      border: 1px solid var(--hairline);
    }

    /* Ruled Sequence / Presentation Timeline */
    .sequence-block {
      background: var(--surface);
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
    }

    .sequence-row {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      divide-x: 1px solid var(--hairline);
    }

    @media (max-width: 680px) {
      .sequence-row {
        grid-template-columns: 1fr;
      }
    }

    .seq-step {
      background: transparent;
      border: none;
      border-right: 1px solid var(--hairline);
      padding: 16px;
      color: var(--text);
      cursor: pointer;
      text-align: left;
      font-family: inherit;
      display: flex;
      flex-direction: column;
      gap: 8px;
      transition: background 0.1s ease;
    }

    .seq-step:last-child {
      border-right: none;
    }

    @media (max-width: 680px) {
      .seq-step {
        border-right: none;
        border-bottom: 1px solid var(--hairline);
      }
      .seq-step:last-child {
        border-bottom: none;
      }
    }

    .seq-step:hover {
      background: var(--surface-raised);
    }

    .seq-step:active {
      background: var(--bg);
    }

    .seq-num {
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-dim);
      font-weight: 500;
    }

    .seq-label {
      font-size: 14px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .seq-desc {
      font-size: 12px;
      color: var(--text-muted);
      line-height: 1.35;
    }

    /* Direct Action Buttons */
    .actions-bar {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
    }

    @media (max-width: 550px) {
      .actions-bar {
        grid-template-columns: 1fr;
      }
    }

    .cmd-btn {
      appearance: none;
      background: var(--surface);
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
      padding: 14px 16px;
      color: var(--text);
      font-family: inherit;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      transition: background 0.1s ease, border-color 0.1s ease;
      touch-action: manipulation;
    }

    .cmd-btn:hover {
      background: var(--surface-raised);
      border-color: rgba(255, 255, 255, 0.25);
    }

    .cmd-btn:active {
      background: var(--bg);
    }

    .cmd-btn-primary {
      border-color: var(--board-green);
      color: var(--board-green-text);
      background: rgba(46, 125, 50, 0.15);
    }

    .cmd-btn-primary:hover {
      background: rgba(46, 125, 50, 0.25);
      border-color: var(--board-green-text);
    }

    .cmd-btn-danger {
      border-color: rgba(220, 38, 38, 0.4);
      color: var(--rust-text);
    }

    .cmd-btn-danger:hover {
      border-color: var(--rust-text);
      background: rgba(220, 38, 38, 0.1);
    }

    .cmd-btn-full {
      grid-column: 1 / -1;
    }

    /* Terminal Activity Log */
    .terminal-box {
      background: #090b0e;
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
      padding: 12px 14px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      display: flex;
      flex-direction: column;
      gap: 4px;
      max-height: 160px;
      overflow-y: auto;
    }

    .terminal-head {
      font-size: 10px;
      text-transform: uppercase;
      letter-spacing: 0.8px;
      color: var(--text-dim);
      display: flex;
      justify-content: space-between;
      padding-bottom: 6px;
      border-bottom: 1px solid var(--hairline-subtle);
      margin-bottom: 4px;
    }

    .terminal-line {
      color: var(--text-muted);
      word-break: break-all;
    }

    .terminal-line.success { color: var(--board-green-text); }
    .terminal-line.error { color: var(--rust-text); }
    .terminal-line.info { color: var(--text); }

    /* Collapsible Hardware / Manual settings */
    details {
      border: 1px solid var(--hairline-subtle);
      border-radius: var(--radius);
      padding: 10px 14px;
      font-size: 12px;
      color: var(--text-muted);
    }

    summary {
      cursor: pointer;
      font-weight: 600;
      color: var(--text-muted);
      user-select: none;
    }

    .input-row {
      display: flex;
      gap: 8px;
      margin-top: 8px;
    }

    .field-input {
      flex: 1;
      background: var(--bg);
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
      padding: 8px 10px;
      color: var(--text);
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      outline: none;
    }

    .field-input:focus {
      border-color: var(--ink-blue);
    }

    .field-btn {
      background: var(--surface-raised);
      border: 1px solid var(--hairline);
      border-radius: var(--radius);
      padding: 8px 14px;
      font-size: 12px;
      font-weight: 600;
      color: var(--text);
      cursor: pointer;
      font-family: inherit;
    }

    .field-btn:hover {
      border-color: rgba(255, 255, 255, 0.3);
    }

    /* Toast */
    #toast {
      position: fixed;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%) translateY(80px);
      background: var(--surface-raised);
      border: 1px solid var(--hairline);
      color: var(--text);
      padding: 10px 20px;
      border-radius: var(--radius);
      font-size: 13px;
      font-weight: 600;
      transition: transform 0.15s ease;
      pointer-events: none;
      z-index: 1000;
    }

    #toast.show {
      transform: translateX(-50%) translateY(0);
    }
  </style>
</head>
<body>

  <header>
    <div class="header-brand">
      <div class="header-title">Pantas</div>
      <span class="header-sep">/</span>
      <div class="header-subtitle">Instrument Control</div>
    </div>
    <div class="remote-tag">
      <span>Remote:</span>
      <span class="url">http://{{LOCAL_IP}}:4040</span>
    </div>
  </header>

  <main>
    <!-- Target Hardware Strip -->
    <div>
      <div class="section-title">
        <span>Hardware Target</span>
        <span onclick="fetchDevices()" style="cursor:pointer; color:var(--text-muted);">Sync</span>
      </div>
      <div class="target-strip" id="target-strip">
        <button class="target-box active" data-target="all" onclick="selectDevice('all')">
          <div class="target-box-head">
            <span>All Targets</span>
            <span class="dot live"></span>
          </div>
          <div class="target-box-meta">Synchronize All Devices</div>
        </button>
      </div>
    </div>

    <!-- Presentation Timeline -->
    <div>
      <div class="section-title">Slide 06 Presentation Flow</div>
      <div class="sequence-block">
        <div class="sequence-row">
          <button class="seq-step" onclick="triggerAction('reset')">
            <span class="seq-num">STEP 01</span>
            <span class="seq-label">
              <svg class="icon" viewBox="0 0 24 24"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M3 21v-5h5"/></svg>
              Clean Slate
            </span>
            <span class="seq-desc">Purges database. Reset to fresh onboarding before judges inspect.</span>
          </button>

          <button class="seq-step" onclick="triggerAction('pro')">
            <span class="seq-num">STEP 02</span>
            <span class="seq-label">
              <svg class="icon" viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="1"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
              Live Pro Unlock
            </span>
            <span class="seq-desc">Unlocks full catalog and skips paywall immediately without restart.</span>
          </button>

          <button class="seq-step" onclick="triggerAction('populate')">
            <span class="seq-num">STEP 03</span>
            <span class="seq-label">
              <svg class="icon" viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
              60-Day History
            </span>
            <span class="seq-desc">Injects complete daily streaks, quizzes, and archetype analytics.</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Direct Commands -->
    <div>
      <div class="section-title">Direct Controls</div>
      <div class="actions-bar">
        <button class="cmd-btn cmd-btn-primary" onclick="triggerAction('pro')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5"/></svg>
            Unlock Pro Mode
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">STORE: PRO</span>
        </button>

        <button class="cmd-btn" onclick="triggerAction('free')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="1"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            Lock Free Mode
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">STORE: FREE</span>
        </button>

        <button class="cmd-btn" onclick="triggerAction('populate')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
            Populate Faux Data
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">SYNTHETIC</span>
        </button>

        <button class="cmd-btn cmd-btn-danger" onclick="triggerAction('reset')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
            Reset Database
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">PURGE</span>
        </button>

        <button class="cmd-btn" onclick="triggerAction('refresh')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"/></svg>
            Refresh State & Providers
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">HOT REFRESH</span>
        </button>

        <button class="cmd-btn" onclick="triggerAction('reload')">
          <span style="display:flex; align-items:center; gap:8px;">
            <svg class="icon" viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
            Reassemble UI Tree
          </span>
          <span style="font-family:'JetBrains Mono'; font-size:11px;">REBUILD</span>
        </button>
      </div>
    </div>

    <!-- Terminal Console -->
    <div>
      <div class="section-title">Telemetry Log</div>
      <div class="terminal-box">
        <div class="terminal-head">
          <span>EVENT STREAM</span>
          <span onclick="clearLog()" style="cursor:pointer;">CLEAR</span>
        </div>
        <div id="terminal-lines">
          <div class="terminal-line info">Ready. Select hardware target to dispatch commands.</div>
        </div>
      </div>
    </div>

    <!-- Manual Connection Settings -->
    <details>
      <summary>Hardware & Network Configuration</summary>
      <div style="padding-top:12px; display:flex; flex-direction:column; gap:12px;">
        <div>
          <div style="margin-bottom:4px; font-weight:600; color:var(--text);">Connect Wireless ADB (IP:Port)</div>
          <div class="input-row">
            <input type="text" id="adb-ip-input" class="field-input" value="172.20.10.2:38301" placeholder="172.20.10.2:38301">
            <button class="field-btn" onclick="connectAdb()">Connect</button>
          </div>
        </div>
        <div>
          <div style="margin-bottom:4px; font-weight:600; color:var(--text);">Manual VM Service URL Override</div>
          <div class="input-row">
            <input type="text" id="manual-uri-input" class="field-input" placeholder="http://127.0.0.1:45678/token/">
            <button class="field-btn" onclick="saveManualUri()">Set URI</button>
          </div>
        </div>
      </div>
    </details>
  </main>

  <div id="toast">Command Dispatched</div>

  <script>
    let currentTarget = 'all';
    let devices = [];

    function log(msg, type = 'info') {
      const box = document.getElementById('terminal-lines');
      const now = new Date();
      const time = now.toTimeString().split(' ')[0];
      const div = document.createElement('div');
      div.className = `terminal-line ${type}`;
      div.textContent = `${time} ${msg}`;
      box.appendChild(div);
      box.parentElement.scrollTop = box.parentElement.scrollHeight;
    }

    function clearLog() {
      document.getElementById('terminal-lines').innerHTML = '';
    }

    function showToast(msg) {
      const toast = document.getElementById('toast');
      toast.textContent = msg;
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), 2000);
    }

    function selectDevice(id) {
      currentTarget = id;
      document.querySelectorAll('.target-box').forEach(b => {
        b.classList.toggle('active', b.dataset.target === id);
      });
      log(`Target set: ${id}`);
    }

    async function fetchDevices() {
      try {
        const res = await fetch('/api/devices');
        const data = await res.json();
        devices = data.devices || [];
        renderDeviceStrip();
      } catch (e) {
        log(`Discovery poll failed: ${e.message}`, 'error');
      }
    }

    function renderDeviceStrip() {
      const container = document.getElementById('target-strip');
      if (!container) return;

      const runningCount = devices.filter(d => d.app_running).length;
      const isAllActive = currentTarget === 'all';

      let html = `
        <button class="target-box ${isAllActive ? 'active' : ''}" data-target="all" onclick="selectDevice('all')">
          <div class="target-box-head">
            <span style="display:flex; align-items:center; gap:6px;">
              <svg class="icon" viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="1"/><path d="M8 21h8M12 17v4"/></svg>
              All Targets
            </span>
            <span class="dot ${runningCount > 0 ? 'live' : ''}"></span>
          </div>
          <div class="target-box-meta">${runningCount} of ${devices.length} running</div>
        </button>
      `;

      devices.forEach(d => {
        const isActive = currentTarget === d.id;
        const iconSvg = d.is_emulator 
          ? `<svg class="icon" viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="1"/><path d="M8 21h8M12 17v4"/></svg>`
          : `<svg class="icon" viewBox="0 0 24 24"><rect x="5" y="2" width="14" height="20" rx="1"/><line x1="12" y1="18" x2="12" y2="18.01"/></svg>`;
        
        let tierHtml = '';
        if (d.pro === true) {
          tierHtml = '<span class="tier-badge pro">PRO</span>';
        } else if (d.pro === false) {
          tierHtml = '<span class="tier-badge free">FREE</span>';
        }

        html += `
          <button class="target-box ${isActive ? 'active' : ''}" data-target="${d.id}" onclick="selectDevice('${d.id}')">
            <div class="target-box-head">
              <span style="display:flex; align-items:center; gap:6px;">
                ${iconSvg}
                ${d.name}
              </span>
              <span class="dot ${d.app_running ? 'live' : ''}"></span>
            </div>
            <div class="target-box-meta">
              <span>${d.short_id}</span>
              ${tierHtml}
            </div>
          </button>
        `;
      });

      container.innerHTML = html;
    }

    async function triggerAction(action) {
      log(`Dispatching [${action.toUpperCase()}] to [${currentTarget}]...`, 'info');
      try {
        const res = await fetch('/api/action', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            device: currentTarget,
            action: action
          })
        });
        const data = await res.json();
        if (data.success) {
          showToast(`Applied: ${action.toUpperCase()}`);
          data.results.forEach(r => {
            if (r.success) {
              log(`OK ${r.name}: ${action} executed`, 'success');
            } else {
              log(`FAIL ${r.name}: ${r.error}`, 'error');
            }
          });
          fetchDevices();
        } else {
          showToast(`Error: ${data.error || 'Failed'}`);
          log(`Action rejected: ${data.error}`, 'error');
        }
      } catch (e) {
        showToast('Network timeout');
        log(`Connection error: ${e.message}`, 'error');
      }
    }

    async function connectAdb() {
      const address = document.getElementById('adb-ip-input').value.trim();
      if (!address) return;
      log(`Initiating ADB handshake to ${address}...`, 'info');
      try {
        const res = await fetch('/api/connect_adb', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({address: address})
        });
        const data = await res.json();
        if (data.success) {
          showToast('Device Connected');
          log(`ADB Handshake OK: ${data.output}`, 'success');
          fetchDevices();
        } else {
          showToast('Connection Refused');
          log(`ADB Handshake FAIL: ${data.error}`, 'error');
        }
      } catch (e) {
        log(`Network exception: ${e.message}`, 'error');
      }
    }

    async function saveManualUri() {
      const uri = document.getElementById('manual-uri-input').value.trim();
      if (!uri) return;
      try {
        await fetch('/api/manual_uri', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            device: currentTarget === 'all' ? (devices[0]?.id || 'emulator-5554') : currentTarget,
            uri: uri
          })
        });
        showToast('URI Stored');
        log(`Manual VM Service set for ${currentTarget}: ${uri}`, 'info');
        fetchDevices();
      } catch (e) {
        log(`Save URI failed: ${e.message}`, 'error');
      }
    }

    fetchDevices();
    setInterval(fetchDevices, 3000);
  </script>
</body>
</html>
"""

class DemoRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/" or parsed.path == "/index.html":
            local_ip = get_local_ip()
            rendered = HTML_PAGE.replace("{{LOCAL_IP}}", local_ip)
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
            self.send_header("Content-Length", str(len(rendered.encode("utf-8"))))
            self.end_headers()
            self.wfile.write(rendered.encode("utf-8"))
        elif parsed.path == "/api/devices":
            devices = get_all_devices()
            resp = json.dumps({"devices": devices, "local_ip": get_local_ip()})
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(resp.encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
        try:
            payload = json.loads(body)
        except Exception:
            payload = {}

        if parsed.path == "/api/connect_adb":
            address = payload.get("address", "")
            if not address:
                resp = json.dumps({"success": False, "error": "No address provided"})
            else:
                ok, stdout, stderr = run_adb(["connect", address], timeout=6)
                resp = json.dumps({"success": ok, "output": stdout, "error": stderr if not ok else None})
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(resp.encode("utf-8"))
        elif parsed.path == "/api/action":
            device = payload.get("device", "all")
            action = payload.get("action", "")
            result = execute_action(device, action)
            resp = json.dumps(result)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(resp.encode("utf-8"))
        elif parsed.path == "/api/manual_uri":
            dev_id = payload.get("device")
            uri = payload.get("uri")
            if dev_id and uri:
                MANUAL_URIS[dev_id] = uri
            resp = json.dumps({"status": "ok"})
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(resp.encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass

def main():
    local_ip = get_local_ip()
    server = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), DemoRequestHandler)
    print(f"======================================================")
    print(f" Pantas Demo Controller is LIVE")
    print(f"------------------------------------------------------")
    print(f" Local:  http://localhost:{PORT}")
    print(f" Remote: http://{local_ip}:{PORT}")
    print(f"======================================================")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping controller.")
        server.server_close()

if __name__ == "__main__":
    main()
