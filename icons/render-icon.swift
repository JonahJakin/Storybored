import AppKit
import Foundation

let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("icons")

let background = NSColor.clear
let badgeFill = NSColor(calibratedRed: 0xEF / 255.0, green: 0xE4 / 255.0, blue: 0xD4 / 255.0, alpha: 1)
let badgeStroke = NSColor(calibratedRed: 0xFC / 255.0, green: 0xFA / 255.0, blue: 0xF5 / 255.0, alpha: 1)
let gold = NSColor(calibratedRed: 0xEF / 255.0, green: 0xC7 / 255.0, blue: 0x5C / 255.0, alpha: 1)

struct RoundedRect {
  let rect: CGRect
  let radius: CGFloat
}

let badge = RoundedRect(rect: CGRect(x: 44, y: 44, width: 424, height: 424), radius: 92)
let marks = [
  RoundedRect(rect: CGRect(x: 116, y: 271, width: 280, height: 76), radius: 16),
  RoundedRect(rect: CGRect(x: 124, y: 168, width: 102, height: 72), radius: 13),
  RoundedRect(rect: CGRect(x: 286, y: 168, width: 102, height: 72), radius: 13)
]
let cutouts = [
  RoundedRect(rect: CGRect(x: 132, y: 289, width: 248, height: 40), radius: 10),
  RoundedRect(rect: CGRect(x: 138, y: 189, width: 74, height: 30), radius: 8),
  RoundedRect(rect: CGRect(x: 300, y: 189, width: 74, height: 30), radius: 8)
]

func drawIcon(size: CGFloat) -> NSImage {
  guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size),
    pixelsHigh: Int(size),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  ) else {
    fatalError("Unable to create bitmap rep")
  }
  rep.size = NSSize(width: size, height: size)
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  NSGraphicsContext.current?.imageInterpolation = .high

  let scale = size / 512.0
  let isTiny = size <= 32

  let badgeRect = CGRect(
    x: badge.rect.origin.x * scale,
    y: badge.rect.origin.y * scale,
    width: badge.rect.width * scale,
    height: badge.rect.height * scale
  )
  let badgePath = NSBezierPath(
    roundedRect: badgeRect,
    xRadius: badge.radius * scale,
    yRadius: badge.radius * scale
  )
  badgeFill.setFill()
  badgePath.fill()
  badgeStroke.setStroke()
  badgePath.lineWidth = isTiny ? 1 : max(1.5, 3 * scale)
  badgePath.stroke()

  if !isTiny {
    let glow = NSShadow()
    glow.shadowColor = NSColor(calibratedRed: 0xEF / 255.0, green: 0xC7 / 255.0, blue: 0x5C / 255.0, alpha: 0.62)
    glow.shadowBlurRadius = 18 * scale
    glow.shadowOffset = .zero
    NSGraphicsContext.saveGraphicsState()
    glow.set()
  }

  gold.setFill()
  marks.forEach { mark in
    let rect = CGRect(
      x: mark.rect.origin.x * scale,
      y: mark.rect.origin.y * scale,
      width: mark.rect.width * scale,
      height: mark.rect.height * scale
    )
    let path = NSBezierPath(roundedRect: rect, xRadius: mark.radius * scale, yRadius: mark.radius * scale)
    path.fill()
  }
  badgeFill.setFill()
  cutouts.forEach { cutout in
    let rect = CGRect(
      x: cutout.rect.origin.x * scale,
      y: cutout.rect.origin.y * scale,
      width: cutout.rect.width * scale,
      height: cutout.rect.height * scale
    )
    let path = NSBezierPath(roundedRect: rect, xRadius: cutout.radius * scale, yRadius: cutout.radius * scale)
    path.fill()
  }
  if !isTiny {
    NSGraphicsContext.restoreGraphicsState()
  }

  NSGraphicsContext.restoreGraphicsState()
  let image = NSImage(size: NSSize(width: size, height: size))
  image.addRepresentation(rep)
  return image
}

func writePNG(_ image: NSImage, to name: String) throws {
  guard
    let tiff = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiff),
    let data = rep.representation(using: .png, properties: [:])
  else {
    throw NSError(domain: "icon.render", code: 1)
  }
  try data.write(to: outputDir.appendingPathComponent(name))
}

try writePNG(drawIcon(size: 512), to: "icon-512.png")
try writePNG(drawIcon(size: 512), to: "icon-maskable-512.png")
try writePNG(drawIcon(size: 192), to: "icon-192.png")
try writePNG(drawIcon(size: 180), to: "apple-touch-icon-180.png")
try writePNG(drawIcon(size: 32), to: "icon-32.png")
