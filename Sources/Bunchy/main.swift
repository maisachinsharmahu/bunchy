import AppKit

// Process launch is single-threaded on the main thread before any run loop
// starts, so this genuinely is the main actor -- assumeIsolated just tells
// the compiler what's already true.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // agent app: no Dock icon, no menu bar theft
    app.run()
}
