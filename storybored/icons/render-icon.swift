import AppKit
import Foundation

let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("icons")

let background = NSColor(calibratedRed: 0xEB / 255.0, green: 0xE9 / 255.0, blue: 0xE2 / 255.0, alpha: 1)
let gold = NSColor(calibratedRed: 0xCF / 255.0, green: 0x9B / 255.0, blue: 0x38 / 255.0, alpha: 1)

struct RoundedRect {
  let rect: CGRect
  let radius: CGFloat
}

let outerShapes = [
  RoundedRect(rect: CGRect(x: 94, y: 254, width: 324, height: 102), radius: 30),
  RoundedRect(rect: CGRect(x: 94, y: 143, width: 136, height: 88), radius: 30),
  RoundedRect(rect: CGRect(x: 282, y: 143, width: 136, height: 88), radius: 30)
]

let innerShapes = [
  RoundedRect(rect: CGRect(x: 119, y: 282, width: 274, height: 46), radius: 5),
  RoundedRect(rect: CGRect(x: 120, y: 171, width: 84, height: 32), radius: 5),
  RoundedRect(rect: CGRect(x: 308, y: 171, width: 84, height: 32), radius: 5)
]

func drawIcon(size: CGFloat, maskable: Bool) -> NSImage {
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

  background.setFill()
  NSBezierPath(rect: CGRect(x: 0, y: 0, width: size, height: size)).fill()

  let scale = size / 512.0
  let inset = maskable ? size * 0.07 : 0

  NSGraphicsContext.current?.imageInterpolation = .high

  func scaled(_ roundedRect: RoundedRect) -> NSBezierPath {
    let rect = CGRect(
      x: roundedRect.rect.origin.x * scale,
      y: roundedRect.rect.origin.y * scale,
      width: roundedRect.rect.width * scale,
      height: roundedRect.rect.height * scale
    ).insetBy(dx: inset, dy: inset)
    let radius = max(1, roundedRect.radius * scale - inset * 0.2)
    return NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
  }

  gold.setFill()
  outerShapes.forEach { scaled($0).fill() }

  background.setFill()
  innerShapes.forEach { scaled($0).fill() }

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

try writePNG(drawIcon(size: 512, maskable: false), to: "icon-512.png")
try writePNG(drawIcon(size: 512, maskable: true), to: "icon-maskable-512.png")
try writePNG(drawIcon(size: 192, maskable: false), to: "icon-192.png")
try writePNG(drawIcon(size: 180, maskable: false), to: "apple-touch-icon-180.png")
try writePNG(drawIcon(size: 32, maskable: false), to: "icon-32.png")
