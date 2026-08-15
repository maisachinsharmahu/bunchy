import AppKit
import SwiftUI
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var shelfPanel: NSPanel?
    private let collector = ClipboardCollector()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        registerForLaunchAtLogin()
    }

    /// Runs in the background from the very first launch, no settings
    /// screen to remember to visit -- matches the "just works" bar this
    /// app is meant to clear. Safe to call every launch: register() is a
    /// no-op if already registered.
    private func registerForLaunchAtLogin() {
        guard SMAppService.mainApp.status != .enabled else { return }
        try? SMAppService.mainApp.register()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "square.stack.3d.up", accessibilityDescription: "Bunchy")
        }
        item.menu = buildMenu()
        statusItem = item
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        if collector.isCollecting {
            menu.addItem(withTitle: "Show Bunch", action: #selector(showShelf), keyEquivalent: "").target = self
            menu.addItem(withTitle: "Finish & Copy All", action: #selector(finishBunch), keyEquivalent: "").target = self
            menu.addItem(withTitle: "Cancel Bunch", action: #selector(cancelBunch), keyEquivalent: "").target = self
        } else {
            menu.addItem(withTitle: "Start New Bunch", action: #selector(startBunch), keyEquivalent: "").target = self
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Bunchy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    private func refreshMenu() {
        statusItem?.menu = buildMenu()
        statusItem?.button?.image = NSImage(
            systemSymbolName: collector.isCollecting ? "square.stack.3d.up.fill" : "square.stack.3d.up",
            accessibilityDescription: "Bunchy"
        )
    }

    @objc private func startBunch() {
        collector.start()
        refreshMenu()
        showShelfPanel()
    }

    @objc private func showShelf() {
        showShelfPanel()
    }

    @objc private func finishBunch() {
        collector.finishAndWriteToPasteboard()
        refreshMenu()
        closeShelfPanel()
    }

    @objc private func cancelBunch() {
        collector.stop()
        collector.clear()
        refreshMenu()
        closeShelfPanel()
    }

    private func showShelfPanel() {
        if shelfPanel == nil {
            let view = ShelfView(
                collector: collector,
                onDone: { [weak self] in self?.finishBunch() },
                onCancel: { [weak self] in self?.cancelBunch() }
            )
            let hosting = NSHostingController(rootView: view)
            let panel = NSPanel(contentViewController: hosting)
            // .nonactivatingPanel is the key piece: the shelf can show and
            // receive clicks on its own buttons without ever stealing
            // frontmost-app status from Finder/Quick Look/whatever you're
            // actively copying from -- the whole point is not interrupting
            // that flow between copies.
            panel.styleMask = [.nonactivatingPanel, .titled, .closable, .fullSizeContentView]
            panel.titlebarAppearsTransparent = true
            panel.titleVisibility = .hidden
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.hidesOnDeactivate = false
            panel.isMovableByWindowBackground = true
            panel.setContentSize(NSSize(width: 340, height: 300))
            positionInCorner(panel)
            panel.isReleasedWhenClosed = false
            shelfPanel = panel
        }
        shelfPanel?.orderFrontRegardless() // shows without activating the app
    }

    private func closeShelfPanel() {
        shelfPanel?.close()
        shelfPanel = nil
    }

    private func positionInCorner(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        let margin: CGFloat = 20
        let frame = panel.frame
        let x = screen.visibleFrame.maxX - frame.width - margin
        let y = screen.visibleFrame.maxY - frame.height - margin
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
