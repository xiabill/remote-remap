import Cocoa

/// 在 ctx 上画一个 av.remote SF Symbol（白色），居中、占画布约 56%。
func drawRemoteSymbol(size: CGFloat) {
    let config = NSImage.SymbolConfiguration(pointSize: size * 0.56, weight: .regular)
    guard let img = NSImage(systemSymbolName: "av.remote", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) else { return }

    // 把 symbol 染成白色
    let tinted = NSImage(size: img.size, flipped: false) { rect in
        img.draw(in: rect)
        NSColor.white.set()
        rect.fill(using: .sourceIn)
        return true
    }

    let drawSize = tinted.size
    let drawRect = NSRect(
        x: (size - drawSize.width) / 2,
        y: (size - drawSize.height) / 2,
        width: drawSize.width, height: drawSize.height)
    tinted.draw(in: drawRect)
}

func renderIconPNG(pxSize: Int) -> Data? {
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: pxSize, height: pxSize,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ns
    defer { NSGraphicsContext.restoreGraphicsState() }

    let size = CGFloat(pxSize)

    // 1. 圆角背景：macOS app icon 标准比例（22.37% 圆角，4% padding）
    let radius = size * 0.2237
    let inset  = size * 0.04
    let bgRect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: radius, yRadius: radius)

    // 紫红渐变 —— 跟 AirPodsRemap（蓝）做区分
    let gradient = NSGradient(colors: [
        NSColor(red: 1.00, green: 0.42, blue: 0.55, alpha: 1.0),  // 顶部桃红
        NSColor(red: 0.55, green: 0.10, blue: 0.42, alpha: 1.0),  // 底部紫红
    ])!
    gradient.draw(in: bgPath, angle: -90)

    // 2. 顶部高光弧
    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()
    let hlRect = NSRect(x: inset, y: size * 0.58, width: size - inset * 2, height: size * 0.42)
    let hl = NSGradient(colors: [
        NSColor(white: 1.0, alpha: 0.20),
        NSColor(white: 1.0, alpha: 0.0)
    ])!
    hl.draw(in: hlRect, angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // 3. 居中遥控器 symbol
    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()
    drawRemoteSymbol(size: size)
    NSGraphicsContext.restoreGraphicsState()

    // 4. 内描边，提升对比
    let borderPath = NSBezierPath(
        roundedRect: bgRect.insetBy(dx: 0.5, dy: 0.5),
        xRadius: radius, yRadius: radius)
    NSColor(white: 0, alpha: 0.10).setStroke()
    borderPath.lineWidth = max(1, size / 1024)
    borderPath.stroke()

    guard let cgImage = ctx.makeImage() else { return nil }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    return rep.representation(using: .png, properties: [:])
}

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

let sizes: [(String, Int)] = [
    ("icon_16x16",       16),
    ("icon_16x16@2x",    32),
    ("icon_32x32",       32),
    ("icon_32x32@2x",    64),
    ("icon_128x128",    128),
    ("icon_128x128@2x", 256),
    ("icon_256x256",    256),
    ("icon_256x256@2x", 512),
    ("icon_512x512",    512),
    ("icon_512x512@2x",1024),
]

for (name, px) in sizes {
    if let data = renderIconPNG(pxSize: px) {
        let url = URL(fileURLWithPath: outDir).appendingPathComponent("\(name).png")
        try? data.write(to: url)
        print("✓ \(name).png  \(px)×\(px)")
    } else {
        print("✗ failed \(name) \(px)")
    }
}
