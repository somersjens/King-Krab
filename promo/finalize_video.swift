import AVFoundation
import CoreImage
import Foundation

struct CLI {
    let input: URL
    let cues: URL
    let audioDir: URL
    let width: Int
    let height: Int
    let trimSeconds: Double
    let maxSeconds: Double
    let cropTop: Double
    let cropBottom: Double
    let output: URL

    init() throws {
        let args = Array(CommandLine.arguments.dropFirst())
        func value(_ flag: String) -> String? {
            guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
            return args[index + 1]
        }
        guard
            let input = value("--input"),
            let cues = value("--cues"),
            let audioDir = value("--audio-dir"),
            let width = value("--width").flatMap(Int.init),
            let height = value("--height").flatMap(Int.init),
            let output = value("--output")
        else {
            throw NSError(domain: "FinalizeVideo", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "usage: finalize_video.swift --input raw.mov --cues cues.json --audio-dir dir --width 886 --height 1920 --output final.mp4 [--trim-seconds 0] [--max-seconds 40] [--crop-top 0] [--crop-bottom 0]"
            ])
        }
        self.input = URL(fileURLWithPath: input)
        self.cues = URL(fileURLWithPath: cues)
        self.audioDir = URL(fileURLWithPath: audioDir)
        self.width = width
        self.height = height
        self.trimSeconds = value("--trim-seconds").flatMap(Double.init) ?? 0
        self.maxSeconds = value("--max-seconds").flatMap(Double.init) ?? 40
        self.cropTop = value("--crop-top").flatMap(Double.init) ?? 0
        self.cropBottom = value("--crop-bottom").flatMap(Double.init) ?? 0
        self.output = URL(fileURLWithPath: output)
    }
}

struct Cue: Decodable {
    let t: Double
    let key: String
}

let effectMap: [String: (String, Float)] = [
    "correct": ("sfx_correct.caf", 0.14),
    "wrong": ("sfx_wrong.caf", 0.11),
    "cardFlip": ("sfx_card_flip.caf", 0.10),
    "cardReveal": ("sfx_card_reveal.caf", 0.19),
    "doubleCard": ("sfx_double_card.caf", 0.18),
    "doubleScore": ("sfx_double_score.caf", 0.15),
    "flamethrower": ("sfx_flamethrower.caf", 0.31),
    "sessionComplete": ("sfx_level_complete.caf", 0.10),
    "cardTotal": ("score_increase.caf", 1.0),
    "sessionStart": ("sfx_session_start.caf", 0.16),
]

func loadCues(from url: URL) -> [Cue] {
    guard let data = try? Data(contentsOf: url) else { return [] }
    return (try? JSONDecoder().decode([Cue].self, from: data)) ?? []
}

func orientedSize(for track: AVAssetTrack) -> CGSize {
    let transformed = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: abs(transformed.width), height: abs(transformed.height))
}

func makeVideoComposition(
    asset: AVAsset,
    track: AVAssetTrack,
    width: Int,
    height: Int,
    cropTop: Double,
    cropBottom: Double
) -> AVMutableVideoComposition {
    let sourceSize = orientedSize(for: track)
    let top = min(max(cropTop, 0), 0.4)
    let bottom = min(max(cropBottom, 0), 0.4)
    let cropped = CGRect(
        x: 0,
        y: sourceSize.height * top,
        width: sourceSize.width,
        height: max(1, sourceSize.height * (1 - top - bottom))
    )
    let renderSize = CGSize(width: width, height: height)
    let scale = max(renderSize.width / cropped.width, renderSize.height / cropped.height)
    let extraX = (renderSize.width - cropped.width * scale) / 2
    // Keep the HUD. Center-cropping the fill would shave the top of the
    // playfield after the island/status-bar strip is already gone.
    let extraY: CGFloat = 0

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    var transform = track.preferredTransform
    transform = transform.concatenating(CGAffineTransform(translationX: -cropped.minX, y: -cropped.minY))
    transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
    transform = transform.concatenating(CGAffineTransform(translationX: extraX, y: extraY))
    layer.setTransform(transform, at: .zero)
    instruction.layerInstructions = [layer]

    let composition = AVMutableVideoComposition()
    composition.instructions = [instruction]
    composition.renderSize = renderSize
    composition.frameDuration = CMTime(value: 1, timescale: 30)
    return composition
}

func finalize() async throws {
    let cli = try CLI()
    try? FileManager.default.removeItem(at: cli.output)

    let sourceAsset = AVURLAsset(url: cli.input)
    let sourceDuration = sourceAsset.duration
    let trimStart = CMTime(seconds: cli.trimSeconds, preferredTimescale: 600)
    let unclampedDuration = CMTimeSubtract(sourceDuration, trimStart)
    let maxDuration = CMTime(seconds: cli.maxSeconds, preferredTimescale: 600)
    let trimmedDuration = CMTimeMinimum(unclampedDuration, maxDuration)
    guard trimmedDuration > .zero else {
        throw NSError(domain: "FinalizeVideo", code: 6, userInfo: [
            NSLocalizedDescriptionKey: "Raw recording was too short after trimming lead-in"
        ])
    }
    guard let videoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "FinalizeVideo", code: 2, userInfo: [NSLocalizedDescriptionKey: "No video track in raw recording"])
    }

    let mixComposition = AVMutableComposition()
    guard let compositionVideo = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw NSError(domain: "FinalizeVideo", code: 3)
    }
    try compositionVideo.insertTimeRange(CMTimeRange(start: trimStart, duration: trimmedDuration), of: videoTrack, at: .zero)

    var audioParams: [AVMutableAudioMixInputParameters] = []

    let musicURL = cli.audioDir.appendingPathComponent("music_background.m4a")
    if FileManager.default.fileExists(atPath: musicURL.path),
       let musicTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
        let musicAsset = AVURLAsset(url: musicURL)
        if let source = try await musicAsset.loadTracks(withMediaType: .audio).first {
            var cursor = CMTime.zero
            let musicDuration = musicAsset.duration
            while cursor < trimmedDuration {
                let remaining = CMTimeSubtract(trimmedDuration, cursor)
                let slice = CMTimeMinimum(musicDuration, remaining)
                try musicTrack.insertTimeRange(CMTimeRange(start: .zero, duration: slice), of: source, at: cursor)
                cursor = CMTimeAdd(cursor, slice)
            }
            let params = AVMutableAudioMixInputParameters(track: musicTrack)
            params.setVolume(0.22, at: .zero)
            audioParams.append(params)
        }
    }

    for cue in loadCues(from: cli.cues) {
        guard let effect = effectMap[cue.key] else { continue }
        let effectURL = cli.audioDir.appendingPathComponent(effect.0)
        guard FileManager.default.fileExists(atPath: effectURL.path),
              let effectTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        else { continue }

        let effectAsset = AVURLAsset(url: effectURL)
        guard let source = try await effectAsset.loadTracks(withMediaType: .audio).first else { continue }
        let adjustedSeconds = max(0, cue.t - CMTimeGetSeconds(trimStart))
        let start = CMTime(seconds: adjustedSeconds, preferredTimescale: 600)
        guard start < trimmedDuration else { continue }
        let remaining = CMTimeSubtract(trimmedDuration, start)
        let slice = CMTimeMinimum(effectAsset.duration, remaining)
        try effectTrack.insertTimeRange(CMTimeRange(start: .zero, duration: slice), of: source, at: start)
        let params = AVMutableAudioMixInputParameters(track: effectTrack)
        params.setVolume(effect.1, at: .zero)
        audioParams.append(params)
    }

    let videoComposition = makeVideoComposition(
        asset: mixComposition,
        track: compositionVideo,
        width: cli.width,
        height: cli.height,
        cropTop: cli.cropTop,
        cropBottom: cli.cropBottom
    )

    let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
    guard let exporter else {
        throw NSError(domain: "FinalizeVideo", code: 4)
    }
    exporter.outputURL = cli.output
    exporter.outputFileType = .mp4
    exporter.shouldOptimizeForNetworkUse = true
    exporter.videoComposition = videoComposition

    let audioMix = AVMutableAudioMix()
    audioMix.inputParameters = audioParams
    exporter.audioMix = audioMix

    await withCheckedContinuation { continuation in
        exporter.exportAsynchronously {
            continuation.resume()
        }
    }

    guard exporter.status == .completed else {
        throw exporter.error ?? NSError(domain: "FinalizeVideo", code: 5, userInfo: [
            NSLocalizedDescriptionKey: "Export failed with status \(exporter.status.rawValue)"
        ])
    }

    print("wrote \(cli.output.path)")
}

Task {
    do {
        try await finalize()
        exit(0)
    } catch {
        fputs("finalize_video.swift error: \(error)\n", stderr)
        exit(1)
    }
}

dispatchMain()
