import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count == 3 else {
    fputs("usage: extract_frames.swift <video.mp4> <output_dir>\n", stderr)
    exit(1)
}

let videoURL = URL(fileURLWithPath: args[1])
let outputDir = URL(fileURLWithPath: args[2], isDirectory: true)
try? FileManager.default.removeItem(at: outputDir)
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let asset = AVURLAsset(url: videoURL)
let duration = CMTimeGetSeconds(asset.duration)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.maximumSize = CGSize(width: 1200, height: 2000)

let sampleCount = 10
let step = max(0.5, duration / Double(sampleCount + 1))
let times: [NSValue] = (0..<sampleCount).map { index in
    NSValue(time: CMTime(seconds: step * Double(index + 1), preferredTimescale: 600))
}

var failures = 0
for (index, value) in times.enumerated() {
    do {
        let cgImage = try generator.copyCGImage(at: value.timeValue, actualTime: nil)
        let fileURL = outputDir.appendingPathComponent(String(format: "frame-%02d.jpg", index + 1))
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            failures += 1
            continue
        }
        let options: CFDictionary = [kCGImageDestinationLossyCompressionQuality: 0.88] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        CGImageDestinationFinalize(destination)
    } catch {
        failures += 1
    }
}

print("extracted \(sampleCount - failures) frames to \(outputDir.path)")
