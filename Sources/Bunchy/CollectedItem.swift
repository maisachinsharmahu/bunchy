import AppKit

/// A faithful snapshot of one pasteboard item captured during a collecting
/// session -- every representation (type + raw data) that was present at
/// copy time, not just a guessed-at image. That's what lets the final
/// combined paste hand a receiving app exactly what a normal single paste
/// of that item would have, whether it's a file reference, raw image
/// bytes, or something else entirely.
struct CollectedItem: Identifiable {
    let id = UUID()
    let capturedAt = Date()
    var representations: [(type: NSPasteboard.PasteboardType, data: Data)]
    var thumbnail: NSImage?
    var displayName: String

    /// Rebuilds a pasteboard item carrying the same representations that
    /// were captured, for the final multi-item write.
    func makePasteboardItem() -> NSPasteboardItem {
        let item = NSPasteboardItem()
        for rep in representations {
            item.setData(rep.data, forType: rep.type)
        }
        return item
    }
}
