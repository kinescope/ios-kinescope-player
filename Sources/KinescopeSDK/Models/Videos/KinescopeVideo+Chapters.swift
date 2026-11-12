import Foundation

/// Chapter with start time normalized to seconds.
struct KinescopeChapterMark: Equatable {
    let start: TimeInterval
    let title: String
}

extension KinescopeVideo {

    /// Chapters with non-empty titles sorted by start.
    var availableChapters: [KinescopeChapterMark] {
        let items = (chapters.items ?? []).filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard !items.isEmpty else {
            return []
        }
        // API may return either seconds or milliseconds; start can't be beyond duration.
        let maxTime = items.map(\.time).max() ?? 0
        let divider: TimeInterval = duration > 0 && TimeInterval(maxTime) > duration + 1 ? 1000 : 1
        return items
            .map { KinescopeChapterMark(start: TimeInterval($0.time) / divider, title: $0.title) }
            .sorted { $0.start < $1.start }
    }

}

func formatPlayerTime(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds.rounded(.down)))
    if total <= 0 {
        return "0:00"
    }
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let secs = total % 60
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    }
    return String(format: "%d:%02d", minutes, secs)
}

extension Array where Element == KinescopeChapterMark {

    func chapter(at time: TimeInterval) -> (index: Int, chapter: KinescopeChapterMark)? {
        enumerated()
            .last { $0.element.start <= time }
            .map { ($0.offset, $0.element) }
    }

}
