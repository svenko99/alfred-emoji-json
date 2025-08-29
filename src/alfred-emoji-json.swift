#!/usr/bin/env swift

import Foundation
import AppKit

// Emoji to Image conversion
extension String {
    // Converts an emoji string into an NSImage of given size (default: 256px).
    func emojiToImage(size: CGFloat = 256) -> NSImage? {
        let nsString = self as NSString
        let font = NSFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let imageSize = nsString.size(withAttributes: attributes)

        let image = NSImage(size: imageSize)
        image.lockFocus()

        // Draw transparent background
        NSColor.clear.set()
        NSBezierPath(rect: CGRect(origin: .zero, size: imageSize)).fill()
        // Draw the emoji
        nsString.draw(at: .zero, withAttributes: attributes)

        image.unlockFocus()
        return image
    }
}

// Save NSImage as PNG to specified path
// Returns true on success, false on failure
func saveImageAsPNG(image: NSImage, to path: String) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return false
    }

    do {
        // Ensure directory exists
        try FileManager.default.createDirectory(
            atPath: (path as NSString).deletingLastPathComponent,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try pngData.write(to: URL(fileURLWithPath: path))
        return true
    } catch {
        fputs("Error saving image: \(error)\n", stderr)
        return false
    }
}

// Recursively process JSON
// Walks the JSON structure and replaces
//
// {"type": "emoji", "path": "🙂"}
// with {"path": "./emojis/...png"}
//
// Generates PNG files if they do not already exist.
func processJSON(_ obj: Any) -> Any {
    if var dict = obj as? [String: Any] {
        // If this is an icon object, process it
        if let type = dict["type"] as? String,
           type == "emoji",
           let emoji = dict["path"] as? String {

            // Build a unique filename based on Unicode scalars
            let fileName = emoji.unicodeScalars
                .map { String(format: "%04X", $0.value) }
                .joined(separator: "_") + ".png"
            let filePath = "./emojis/\(fileName)"

            // Generate PNG only if it doesn’t already exist
            if !FileManager.default.fileExists(atPath: filePath) {
                if let img = emoji.emojiToImage() {
                    _ = saveImageAsPNG(image: img, to: filePath)
                }
            }

            // Return just the path to the saved image
            return ["path": filePath]
        }

        // Recursively process nested objects
        for (k, v) in dict {
            dict[k] = processJSON(v)
        }
        return dict
    } else if var arr = obj as? [Any] {
        // Recursively process arrays
        arr = arr.map { processJSON($0) }
        return arr
    } else {
        return obj
    }
}

// Main
let inputData = FileHandle.standardInput.readDataToEndOfFile()
guard let json = try? JSONSerialization.jsonObject(with: inputData, options: []) else {
    fputs("Invalid JSON input\n", stderr)
    exit(1)
}

let processed = processJSON(json)

// Encode back to JSON and print to stdout
if let outData = try? JSONSerialization.data(withJSONObject: processed, options: []),
   let outStr = String(data: outData, encoding: .utf8) {
    print(outStr)
} else {
    fputs("Failed to encode output JSON\n", stderr)
    exit(1)
}
