// Draws Support/AppIcon.icns and Support/dmg-background.tiff.
// Usage: swift scripts/artwork.swift   (run from the repository root)
import AppKit

let amber = NSColor(srgbRed: 0.97, green: 0.70, blue: 0.29, alpha: 1)
let deepAmber = NSColor(srgbRed: 0.88, green: 0.54, blue: 0.12, alpha: 1)
let roast = NSColor(srgbRed: 0.17, green: 0.13, blue: 0.09, alpha: 1)
let night = NSColor(srgbRed: 0.07, green: 0.05, blue: 0.04, alpha: 1)

func png(width: Int, height: Int, draw: (CGContext) -> Void) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw(NSGraphicsContext.current!.cgContext)
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

/// A shield with a coffee bean in it, on a dark roast squircle, on Apple's 1024-point icon grid.
func icon(_ ctx: CGContext, size: CGFloat) {
    ctx.scaleBy(x: size / 1024, y: size / 1024)

    let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
    let squircle = NSBezierPath(roundedRect: tile, xRadius: 185, yRadius: 185)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    roast.setFill()
    squircle.fill()
    ctx.restoreGState()
    NSGradient(starting: roast, ending: night)!.draw(in: squircle, angle: -90)

    let shield = NSBezierPath()
    shield.move(to: NSPoint(x: 512, y: 812))
    shield.curve(to: NSPoint(x: 732, y: 740), controlPoint1: NSPoint(x: 590, y: 770), controlPoint2: NSPoint(x: 660, y: 745))
    shield.line(to: NSPoint(x: 732, y: 560))
    shield.curve(to: NSPoint(x: 512, y: 230), controlPoint1: NSPoint(x: 732, y: 400), controlPoint2: NSPoint(x: 620, y: 290))
    shield.curve(to: NSPoint(x: 292, y: 560), controlPoint1: NSPoint(x: 404, y: 290), controlPoint2: NSPoint(x: 292, y: 400))
    shield.line(to: NSPoint(x: 292, y: 740))
    shield.curve(to: NSPoint(x: 512, y: 812), controlPoint1: NSPoint(x: 364, y: 745), controlPoint2: NSPoint(x: 434, y: 770))
    shield.close()
    NSGradient(starting: amber, ending: deepAmber)!.draw(in: shield, angle: -90)

    ctx.translateBy(x: 512, y: 530)
    ctx.rotate(by: -.pi / 6)
    roast.setFill()
    NSBezierPath(ovalIn: CGRect(x: -80, y: -115, width: 160, height: 230)).fill()
    let crease = NSBezierPath()
    crease.move(to: NSPoint(x: 0, y: -98))
    crease.curve(to: NSPoint(x: 0, y: 98), controlPoint1: NSPoint(x: 38, y: -30), controlPoint2: NSPoint(x: -38, y: 30))
    crease.lineWidth = 16
    crease.lineCapStyle = .round
    amber.setStroke()
    crease.stroke()
}

/// The drag-to-install window: 660 × 400 points, app icon at (180, 190), Applications at (480, 190).
func background(_ ctx: CGContext, scale: CGFloat) {
    ctx.scaleBy(x: scale, y: scale)
    let bounds = CGRect(x: 0, y: 0, width: 660, height: 400)
    NSGradient(
        starting: NSColor(srgbRed: 0.98, green: 0.96, blue: 0.93, alpha: 1),
        ending: NSColor(srgbRed: 0.93, green: 0.89, blue: 0.84, alpha: 1)
    )!.draw(in: bounds, angle: -90)

    // Arrow from the app to Applications; y is flipped relative to Finder's top-left coordinates.
    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: 270, y: 210))
    arrow.line(to: NSPoint(x: 388, y: 210))
    arrow.move(to: NSPoint(x: 370, y: 226))
    arrow.line(to: NSPoint(x: 390, y: 210))
    arrow.line(to: NSPoint(x: 370, y: 194))
    arrow.lineWidth = 5
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    deepAmber.withAlphaComponent(0.85).setStroke()
    arrow.stroke()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    NSAttributedString(string: "Drag Caffeguard into Applications", attributes: [
        .font: NSFont.systemFont(ofSize: 15, weight: .medium),
        .foregroundColor: roast.withAlphaComponent(0.75),
        .paragraphStyle: paragraph,
    ]).draw(in: CGRect(x: 0, y: 60, width: 660, height: 24))
}

let fm = FileManager.default
let iconset = URL(filePath: NSTemporaryDirectory()).appending(path: "AppIcon.iconset")
try? fm.removeItem(at: iconset)
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let name = scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
        try png(width: pixels, height: pixels) { icon($0, size: CGFloat(pixels)) }.write(to: iconset.appending(path: name))
    }
}
try png(width: 1024, height: 1024) { icon($0, size: 1024) }.write(to: URL(filePath: "docs/icon.png"))

let tmp = URL(filePath: NSTemporaryDirectory())
try png(width: 660, height: 400) { background($0, scale: 1) }.write(to: tmp.appending(path: "bg.png"))
try png(width: 1320, height: 800) { background($0, scale: 2) }.write(to: tmp.appending(path: "bg@2x.png"))

func run(_ args: String...) throws {
    let p = Process()
    p.executableURL = URL(filePath: "/usr/bin/env")
    p.arguments = args
    try p.run()
    p.waitUntilExit()
    guard p.terminationStatus == 0 else { fatalError("\(args) failed") }
}
try run("iconutil", "-c", "icns", iconset.path, "-o", "Support/AppIcon.icns")
// One TIFF holding both resolutions, so the window is sharp on Retina displays.
try run("tiffutil", "-cathidpicheck", tmp.appending(path: "bg.png").path, tmp.appending(path: "bg@2x.png").path, "-out", "Support/dmg-background.tiff")
print("Support/AppIcon.icns, Support/dmg-background.tiff, docs/icon.png")
