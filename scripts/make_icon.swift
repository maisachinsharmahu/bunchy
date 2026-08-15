import AppKit

let iconsetPath = "AppIcon.iconset"

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let corner = size * 0.22
    let bgPath = NSBezierPath(roundedRect: rect, xRadius: corner, yRadius: corner)
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.98, green: 0.62, blue: 0.30, alpha: 1.0),
        NSColor(calibratedRed: 0.92, green: 0.35, blue: 0.38, alpha: 1.0)
    ])
    gradient?.draw(in: bgPath, angle: -60)

    // Three stacked, fanned-out cards -- a "bunch" of copied items.
    let cardW = size * 0.40
    let cardH = size * 0.50
    let cx = size / 2
    let cy = size / 2 - size * 0.02

    func card(offsetX: CGFloat, offsetY: CGFloat, rotation: CGFloat, alpha: CGFloat) {
        NSGraphicsContext.saveGraphicsState()
        let t = NSAffineTransform()
        t.translateX(by: cx + offsetX, yBy: cy + offsetY)
        t.rotate(byDegrees: rotation)
        t.concat()
        let r = NSRect(x: -cardW / 2, y: -cardH / 2, width: cardW, height: cardH)
        let path = NSBezierPath(roundedRect: r, xRadius: size * 0.035, yRadius: size * 0.035)
        NSColor.white.withAlphaComponent(alpha).setFill()
        path.fill()
        NSGraphicsContext.restoreGraphicsState()
    }

    card(offsetX: size * 0.05, offsetY: -size * 0.045, rotation: -12, alpha: 0.55)
    card(offsetX: -size * 0.05, offsetY: -size * 0.02, rotation: 9, alpha: 0.75)
    card(offsetX: 0, offsetY: size * 0.01, rotation: 0, alpha: 0.97)

    image.unlockFocus()
    return image
}

try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

func save(_ image: NSImage, name: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { return }
    let url = URL(fileURLWithPath: "\(iconsetPath)/\(name)")
    try? png.write(to: url)
}

let mapping: [(String, Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
]

for (name, px) in mapping {
    let img = drawIcon(size: CGFloat(px))
    save(img, name: name)
}
print("done")
