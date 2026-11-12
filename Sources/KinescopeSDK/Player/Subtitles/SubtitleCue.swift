import Foundation

struct SubtitleCue {
    let start: TimeInterval
    let end: TimeInterval
    let lines: [String]
}

enum SubtitleCueParser {

    /// WebVTT and SubRip. Tags are stripped.
    static func parse(_ source: String) -> [SubtitleCue] {
        let text = source.replacingOccurrences(of: "\u{FEFF}", with: "")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let blocks = text.components(separatedBy: "\n\n")
        return blocks.compactMap(parseBlock).sorted { $0.start < $1.start }
    }

    /// Lines revealed as playback moves through the cue, same as Android progressive captions.
    static func text(at time: TimeInterval, in cues: [SubtitleCue]) -> String? {
        guard let cue = cue(at: time, in: cues), !cue.lines.isEmpty else {
            return nil
        }
        let duration = max(cue.end - cue.start, 0.01)
        let progress = min(1, max(0, (time - cue.start) / duration))
        let visible = max(1, min(cue.lines.count, Int((progress * Double(cue.lines.count)).rounded(.up))))
        let text = cue.lines.prefix(visible).joined(separator: "\n")
        return text.isEmpty ? nil : text
    }

    private static func cue(at time: TimeInterval, in cues: [SubtitleCue]) -> SubtitleCue? {
        var low = 0
        var high = cues.count - 1
        var match: SubtitleCue?
        while low <= high {
            let mid = (low + high) / 2
            if cues[mid].start <= time {
                match = cues[mid]
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        guard let match, time < match.end else {
            return nil
        }
        return match
    }

    private static func parseBlock(_ block: String) -> SubtitleCue? {
        let rows = block.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let timingIndex = rows.firstIndex(where: { $0.contains("-->") }) else {
            return nil
        }
        let parts = rows[timingIndex].components(separatedBy: "-->")
        guard parts.count >= 2,
              let start = timestamp(parts[0]),
              let end = timestamp(parts[1]) else {
            return nil
        }
        let lines = rows.dropFirst(timingIndex + 1)
            .map { stripTags($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !lines.isEmpty, end > start else {
            return nil
        }
        return SubtitleCue(start: start, end: end, lines: lines)
    }

    private static func timestamp(_ raw: String) -> TimeInterval? {
        let token = raw.split(whereSeparator: { $0 == " " || $0 == "\t" }).first.map(String.init) ?? ""
        let pieces = token.replacingOccurrences(of: ",", with: ".").split(separator: ":").map(String.init)
        guard pieces.count == 2 || pieces.count == 3,
              let secondsPart = pieces.last,
              let seconds = Double(secondsPart) else {
            return nil
        }
        let minutes = Double(pieces[pieces.count - 2]) ?? 0
        let hours = pieces.count == 3 ? (Double(pieces[0]) ?? 0) : 0
        return hours * 3600 + minutes * 60 + seconds
    }

    private static func stripTags(_ line: String) -> String {
        line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }

}
