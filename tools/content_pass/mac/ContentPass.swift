// Content Pass: a window around the bundled local server. AppKit + WebKit only.
import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var server: Process?
    var serverGeneration = 0
    var pageURL: URL?
    var ready = false
    var quitting = false
    var retries = 0
    var logFD: Int32 = -1
    var driveStarted = false
    let ownPID = ProcessInfo.processInfo.processIdentifier

    let support = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Content Pass")
    var logURL: URL { support.appendingPathComponent("server.log") }

    // MARK: launch

    func applicationDidFinishLaunching(_ note: Notification) {
        if let id = Bundle.main.bundleIdentifier,
           let other = NSRunningApplication.runningApplications(withBundleIdentifier: id)
               .first(where: { $0.processIdentifier != ownPID }) {
            other.activate(options: [.activateAllWindows])
            exit(0)
        }
        buildMenus()
        buildWindow()
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        logFD = open(logURL.path, O_WRONLY | O_CREAT | O_TRUNC | O_APPEND, 0o644)
        NSApp.activate(ignoringOtherApps: true)
        startServer()
    }

    func buildMenus() {
        let main = NSMenu()
        func add(_ title: String, _ items: [(String, Selector, String)]) {
            let top = NSMenuItem(); main.addItem(top)
            let m = NSMenu(title: title); top.submenu = m
            for (t, s, k) in items { m.addItem(withTitle: t, action: s, keyEquivalent: k) }
        }
        add("Content Pass", [("Quit Content Pass", #selector(NSApplication.terminate(_:)), "q")])
        add("Edit", [
            ("Undo", Selector(("undo:")), "z"), ("Redo", Selector(("redo:")), "Z"),
            ("Cut", #selector(NSText.cut(_:)), "x"), ("Copy", #selector(NSText.copy(_:)), "c"),
            ("Paste", #selector(NSText.paste(_:)), "v"), ("Select All", #selector(NSText.selectAll(_:)), "a")])
        add("Window", [("Minimize", #selector(NSWindow.performMiniaturize(_:)), "m"),
                       ("Close", #selector(NSWindow.performClose(_:)), "w")])
        NSApp.mainMenu = main
    }

    func buildWindow() {
        let f = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1600, height: 1000)
        let size = NSSize(width: min(1500, f.width * 0.9), height: min(950, f.height * 0.9))
        window = NSWindow(contentRect: NSRect(origin: .zero, size: size),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Content Pass"
        window.isReleasedWhenClosed = false
        window.center()
        let cfg = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: cfg)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsMagnification = false
        if #available(macOS 13.3, *) { webView.isInspectable = true }
        window.contentView = webView
        window.makeKeyAndOrderFront(nil)
        showStarting()
    }

    func showStarting() {
        webView.loadHTMLString("""
            <body style="margin:0;height:100vh;display:flex;align-items:center;justify-content:center;\
            background:#101010;color:#ddd;font:15px -apple-system,sans-serif">Starting Content Pass</body>
            """, baseURL: nil)
    }

    // MARK: server

    func logLine(_ s: String) {
        if logFD >= 0, let d = ("[app] " + s + "\n").data(using: .utf8) { d.withUnsafeBytes { _ = write(logFD, $0.baseAddress, d.count) } }
    }

    func logTail() -> String {
        guard let t = try? String(contentsOf: logURL, encoding: .utf8) else { return "" }
        return t.split(separator: "\n", omittingEmptySubsequences: true).suffix(6).joined(separator: "\n")
    }

    func startServer() {
        let res = Bundle.main.resourceURL!.appendingPathComponent("runtime")
        let exe = res.appendingPathComponent("bin/content_pass_server")
        if !FileManager.default.isExecutableFile(atPath: exe.path)
            || !FileManager.default.fileExists(atPath: res.appendingPathComponent("web/index.html").path) {
            fail("Content Pass needs rebuilding. Run tools/content_pass/make_app.sh.", restart: false); return
        }
        ready = false; retries = 0; pageURL = nil
        serverGeneration += 1
        let gen = serverGeneration
        let p = Process()
        p.executableURL = exe
        p.arguments = ["--port", "0", "--web", res.appendingPathComponent("web").path,
                       "--bin", res.appendingPathComponent("bin").path, "--parent-pid", String(ownPID)]
        let out = Pipe()
        p.standardOutput = out
        p.standardInput = FileHandle.nullDevice
        p.standardError = logFD >= 0 ? FileHandle(fileDescriptor: logFD, closeOnDealloc: false) : FileHandle.nullDevice
        var buffer = Data()
        out.fileHandleForReading.readabilityHandler = { [weak self] h in
            let d = h.availableData
            if d.isEmpty { h.readabilityHandler = nil; return }
            buffer.append(d)
            while let nl = buffer.firstIndex(of: 10) {
                let line = String(decoding: buffer[buffer.startIndex..<nl], as: UTF8.self)
                buffer.removeSubrange(buffer.startIndex...nl)
                DispatchQueue.main.async { self?.serverLine(line, gen) }
            }
        }
        p.terminationHandler = { [weak self] proc in
            DispatchQueue.main.async { self?.serverExited(proc.terminationStatus, gen) }
        }
        do { try p.run() } catch {
            fail("Content Pass could not start its server: \(error.localizedDescription)", restart: false); return
        }
        server = p
        logLine("server started, pid \(p.processIdentifier)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self, gen == self.serverGeneration, !self.ready, !self.quitting else { return }
            self.stopServer()
            self.fail("Content Pass did not start within 30 seconds.", restart: false)
        }
    }

    func serverLine(_ line: String, _ gen: Int) {
        guard gen == serverGeneration else { return }
        if line.hasPrefix("LISTENING "), !ready, let port = Int(line.dropFirst(10).trimmingCharacters(in: .whitespaces)) {
            ready = true
            pageURL = URL(string: "http://127.0.0.1:\(port)/")
            logLine("listening on \(port)")
            webView.load(URLRequest(url: pageURL!))
        } else {
            logLine("server stdout: \(line)")
        }
    }

    func serverExited(_ status: Int32, _ gen: Int) {
        guard gen == serverGeneration, !quitting else { return }
        logLine("server exited with status \(status)")
        if !ready {
            if status == 3 { fail("Another copy of Content Pass is already running.", restart: false) }
            else { fail("The Content Pass server stopped before it was ready.", restart: false) }
        } else {
            fail("The Content Pass server stopped.", restart: true)
        }
    }

    func stopServer() {
        serverGeneration += 1  // ignore this process's exit
        guard let p = server, p.isRunning else { return }
        p.terminate()
        let end = Date().addingTimeInterval(2)
        while p.isRunning && Date() < end { usleep(20_000) }
        if p.isRunning { kill(p.processIdentifier, SIGKILL) }
    }

    func fail(_ message: String, restart: Bool) {
        guard !quitting else { return }
        let a = NSAlert()
        a.alertStyle = .warning
        a.messageText = message
        let tail = logTail()
        a.informativeText = tail.isEmpty ? "" : tail
        a.addButton(withTitle: "Quit")
        if restart { a.addButton(withTitle: "Restart") }
        let r = a.runModal()
        if restart && r == .alertSecondButtonReturn {
            showStarting(); startServer()
        } else {
            NSApp.terminate(nil)
        }
    }

    // MARK: web view

    func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) { navFailed(e) }
    func webView(_ w: WKWebView, didFail n: WKNavigation!, withError e: Error) { navFailed(e) }

    func navFailed(_ e: Error) {
        guard let url = pageURL, webView.url == nil || webView.url == url || webView.url?.scheme == "about" else { return }
        if (e as NSError).code == NSURLErrorCancelled { return }
        logLine("navigation failed: \(e.localizedDescription)")
        retries += 1
        if retries <= 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                if let s = self, !s.quitting { s.webView.load(URLRequest(url: url)) }
            }
        } else {
            fail("Content Pass could not load its page.", restart: false)
        }
    }

    func webView(_ w: WKWebView, decidePolicyFor a: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let u = a.request.url
        let ok = u == nil || u!.scheme == "about" || u!.scheme == "blob" || u!.scheme == "data" || u!.host == "127.0.0.1"
        decisionHandler(ok ? .allow : .cancel)  // external links open nowhere
    }

    func webView(_ w: WKWebView, createWebViewWith c: WKWebViewConfiguration,
                 for a: WKNavigationAction, windowFeatures f: WKWindowFeatures) -> WKWebView? { nil }

    func webView(_ w: WKWebView, didFinish n: WKNavigation!) {
        if webView.url?.host == "127.0.0.1" { retries = 0; runDriveOnce() }
    }

    // MARK: lifecycle

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool {
        window.makeKeyAndOrderFront(nil); return true
    }

    func applicationWillTerminate(_ n: Notification) { quitting = true; stopServer() }

    // MARK: verification hook
    // Only for verifying the real window without UI automation. Active only when
    // CONTENT_PASS_DRIVE names a JSON file of steps: {"js"}, {"wait"}, {"snap"}, {"quit"}.
    // Results and errors are appended to <file>.log. Does nothing when the variable is absent.
    func runDriveOnce() {
        guard !driveStarted, let path = ProcessInfo.processInfo.environment["CONTENT_PASS_DRIVE"] else { return }
        driveStarted = true
        let log = path + ".log"
        func note(_ s: String) {
            if let h = FileHandle(forWritingAtPath: log) ?? { FileManager.default.createFile(atPath: log, contents: nil); return FileHandle(forWritingAtPath: log) }() {
                h.seekToEndOfFile(); h.write((s + "\n").data(using: .utf8)!); h.closeFile() }
        }
        guard let data = FileManager.default.contents(atPath: path),
              let steps = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { note("bad steps file"); return }
        func run(_ i: Int) {
            guard i < steps.count else { return }
            let s = steps[i]; let next = { run(i + 1) }
            if let js = s["js"] as? String {
                webView.callAsyncJavaScript("return await eval(js)", arguments: ["js": js], in: nil, in: .page) { r in
                    switch r { case .success(let v): note("js \(i): \(String(describing: v))")
                               case .failure(let e): note("js \(i) error: \(e)") }
                    next() }
            } else if let sec = s["wait"] as? Double {
                DispatchQueue.main.asyncAfter(deadline: .now() + sec, execute: next)
            } else if let out = s["snap"] as? String {
                webView.takeSnapshot(with: nil) { img, e in
                    if let t = img?.tiffRepresentation, let png = NSBitmapImageRep(data: t)?.representation(using: .png, properties: [:]) {
                        do { try png.write(to: URL(fileURLWithPath: out)); note("snap \(i): \(out)") } catch { note("snap \(i) error: \(error)") }
                    } else { note("snap \(i) error: \(String(describing: e))") }
                    next() }
            } else if s["quit"] as? Bool == true { NSApp.terminate(nil) }
            else { note("step \(i) unknown"); next() }
        }
        run(0)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
