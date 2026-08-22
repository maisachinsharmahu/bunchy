import AppKit
import QuickLookThumbnailing

/// Watches the system pasteboard while a collecting session is active and
/// appends a snapshot of every new copy made anywhere else on the Mac --
/// Finder, Quick Look, Preview, Photos, whatever -- into the running
/// "bunch", without disturbing what's currently on the pasteboard (a copy
/// still works normally as a single paste too; this is purely additive).
///
/// There's no public API to hook into Cmd+C system-wide, so this uses the
/// same technique every clipboard-history app on macOS relies on: poll
/// NSPasteboard.general.changeCount and react when it increases. No special
/// permission is required for this -- it's plain NSPasteboard access.
///
/// @MainActor-isolated so every public method -- and the poll timer's own
/// callback -- is guaranteed to run on the same thread as the menu/button
/// actions that drive it. Mixing threads here is exactly the kind of bug
/// that reads fine in a quick manual test and only shows up intermittently
/// in real use, so it's worth ruling out at compile time rather than by
/// convention.
@MainActor
final class ClipboardCollector: ObservableObject {
    @Published private(set) var items: [CollectedItem] = []
    @Published private(set) var isCollecting = false

    private var pollTimer: Timer?
    private var lastSeenChangeCount = NSPasteboard.general.changeCount

    /// Where web-sourced images (raw pixel data with no file reference) get
    /// written so the final combined paste can offer a real file, not just
    /// bytes -- see `materializeFileIfNeeded`.
    private lazy var scratchDirectory: URL = {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("Bunchy", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    func start() {
        items = []
        lastSeenChangeCount = NSPasteboard.general.changeCount
        isCollecting = true
        try? FileManager.default.removeItem(at: scratchDirectory)
        try? FileManager.default.createDirectory(at: scratchDirectory, withIntermediateDirectories: true)
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkForNewCopy() }
        }
    }

    func stop() {
        isCollecting = false
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func clear() {
        items = []
    }

    func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }

    private func checkForNewCopy() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastSeenChangeCount else { return }
        lastSeenChangeCount = pb.changeCount

        guard let pasteboardItems = pb.pasteboardItems, !pasteboardItems.isEmpty else { return }

        for pbItem in pasteboardItems {
            if capture(pbItem) { continue }

            // Some sources -- browsers especially -- announce the
            // pasteboard's types a moment before the backing data is
            // actually readable. Rather than silently dropping the item,
            // give it one short retry against the same live pasteboard
            // item before giving up.
            guard !pbItem.types.isEmpty else { continue }
            let expectedChangeCount = pb.changeCount
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self, NSPasteboard.general.changeCount == expectedChangeCount else { return }
                _ = self.capture(pbItem)
            }
        }
    }

    /// Attempts to snapshot one pasteboard item. Returns false (without
    /// adding anything) if none of its declared types yielded readable data
    /// yet.
    @discardableResult
    private func capture(_ pbItem: NSPasteboardItem) -> Bool {
        var representations: [(NSPasteboard.PasteboardType, Data)] = []
        for type in pbItem.types {
            if let data = pbItem.data(forType: type) {
                representations.append((type, data))
            }
        }
        guard !representations.isEmpty else { return false }

        var fileURL = pbItem.string(forType: .fileURL).flatMap { URL(string: $0) }
        materializeFileIfNeeded(representations: &representations, fileURL: &fileURL)

        let name = fileURL?.lastPathComponent ?? "Item \(items.count + 1)"
        let captured = CollectedItem(representations: representations, thumbnail: nil, displayName: name)

        items.append(captured)
        loadThumbnail(for: captured.id, fileURL: fileURL, representations: representations)
        return true
    }

    /// Web-sourced image copies (e.g. right-click "Copy Image" in Safari or
    /// Chrome) typically land on the pasteboard as raw TIFF/PNG bytes with
    /// no `public.file-url` at all -- unlike a Finder copy, which is always
    /// backed by a real file. Apps that expect a file reference to paste an
    /// image (Finder itself, Mail, most chat apps) silently fail to paste
    /// those items even though the raw bytes were captured correctly. Write
    /// the bytes to a scratch file and add a file-url representation so
    /// those items paste exactly like a Finder-sourced one.
    private func materializeFileIfNeeded(representations: inout [(NSPasteboard.PasteboardType, Data)], fileURL: inout URL?) {
        guard fileURL == nil else { return }
        guard let (type, data) = representations.first(where: { [.tiff, .png].contains($0.0) }) else { return }

        let ext = type == .png ? "png" : "tiff"
        let url = scratchDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
        do {
            try data.write(to: url)
        } catch {
            return
        }

        // Route through a real NSPasteboardItem so the file-url data is
        // encoded exactly the way `string(forType:)` expects to decode it
        // when this representation gets replayed later.
        let encoder = NSPasteboardItem()
        encoder.setString(url.absoluteString, forType: .fileURL)
        guard let urlData = encoder.data(forType: .fileURL) else { return }

        representations.append((.fileURL, urlData))
        fileURL = url
    }

    private func loadThumbnail(for id: UUID, fileURL: URL?, representations: [(NSPasteboard.PasteboardType, Data)]) {
        if let fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: CGSize(width: 160, height: 160), scale: 2, representationTypes: .thumbnail)
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { [weak self] rep, _ in
                guard let image = rep?.nsImage else { return }
                Task { @MainActor in self?.setThumbnail(image, for: id) }
            }
            return
        }

        // No file reference -- fall back to decoding raw image bytes directly
        // (e.g. a copy made from inside an app rather than of a file).
        for (type, data) in representations where [.tiff, .png].contains(type) {
            if let image = NSImage(data: data) {
                setThumbnail(image, for: id)
                return
            }
        }
    }

    private func setThumbnail(_ image: NSImage, for id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].thumbnail = image
    }

    /// Combines every collected item into one multi-item pasteboard write,
    /// so a single Cmd+V in an app/context that supports multi-item paste
    /// (Finder, Mail, most chat apps) pastes all of them together.
    func finishAndWriteToPasteboard() {
        let pasteboardItems = items.map { $0.makePasteboardItem() }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects(pasteboardItems)
        lastSeenChangeCount = pb.changeCount
        stop()
    }
}

private extension NSPasteboard.PasteboardType {
    static let fileURL = NSPasteboard.PasteboardType("public.file-url")
}
