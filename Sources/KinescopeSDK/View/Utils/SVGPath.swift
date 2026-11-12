import CoreGraphics
import Foundation

/// Minimal parser of SVG path data (`M L H V C S Q Z`, absolute and relative).
/// Arcs are not supported.
enum SVGPath {

    static func make(_ data: String, transform: CGAffineTransform = .identity) -> CGPath {
        let path = CGMutablePath()
        var scanner = Tokenizer(data)
        var current = CGPoint.zero
        var start = CGPoint.zero
        var lastControl: CGPoint?
        var command: Character = "M"

        func point(_ x: CGFloat, _ y: CGFloat, relative: Bool) -> CGPoint {
            relative ? CGPoint(x: current.x + x, y: current.y + y) : CGPoint(x: x, y: y)
        }

        while let token = scanner.nextCommand(default: command) {
            command = token
            let relative = command.isLowercase
            switch command.uppercased() {
            case "M":
                guard let x = scanner.number(), let y = scanner.number() else { return path }
                current = point(x, y, relative: relative)
                start = current
                path.move(to: current, transform: transform)
                lastControl = nil
                // Subsequent pairs are implicit line-to.
                command = relative ? "l" : "L"
            case "L":
                guard let x = scanner.number(), let y = scanner.number() else { break }
                current = point(x, y, relative: relative)
                path.addLine(to: current, transform: transform)
                lastControl = nil
            case "H":
                guard let x = scanner.number() else { break }
                current = CGPoint(x: relative ? current.x + x : x, y: current.y)
                path.addLine(to: current, transform: transform)
                lastControl = nil
            case "V":
                guard let y = scanner.number() else { break }
                current = CGPoint(x: current.x, y: relative ? current.y + y : y)
                path.addLine(to: current, transform: transform)
                lastControl = nil
            case "C":
                guard let x1 = scanner.number(), let y1 = scanner.number(),
                      let x2 = scanner.number(), let y2 = scanner.number(),
                      let x = scanner.number(), let y = scanner.number() else { break }
                let control1 = point(x1, y1, relative: relative)
                let control2 = point(x2, y2, relative: relative)
                current = point(x, y, relative: relative)
                path.addCurve(to: current, control1: control1, control2: control2, transform: transform)
                lastControl = control2
            case "S":
                guard let x2 = scanner.number(), let y2 = scanner.number(),
                      let x = scanner.number(), let y = scanner.number() else { break }
                let control1 = lastControl.map { CGPoint(x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                let control2 = point(x2, y2, relative: relative)
                current = point(x, y, relative: relative)
                path.addCurve(to: current, control1: control1, control2: control2, transform: transform)
                lastControl = control2
            case "Q":
                guard let x1 = scanner.number(), let y1 = scanner.number(),
                      let x = scanner.number(), let y = scanner.number() else { break }
                let control = point(x1, y1, relative: relative)
                current = point(x, y, relative: relative)
                path.addQuadCurve(to: current, control: control, transform: transform)
                lastControl = nil
            case "Z":
                path.closeSubpath()
                current = start
                lastControl = nil
            default:
                return path
            }
        }
        return path
    }

}

// MARK: - Tokenizer

private extension SVGPath {

    struct Tokenizer {
        private let chars: [Character]
        private var index = 0

        init(_ string: String) {
            chars = Array(string)
        }

        mutating func nextCommand(default command: Character) -> Character? {
            skipSeparators()
            guard index < chars.count else {
                return nil
            }
            let char = chars[index]
            if char.isLetter {
                index += 1
                return char
            }
            // Numbers without command repeat previous one.
            return command.uppercased() == "Z" ? nil : command
        }

        mutating func number() -> CGFloat? {
            skipSeparators()
            let begin = index
            var hasDot = false
            var hasExponent = false
            if index < chars.count, chars[index] == "-" || chars[index] == "+" {
                index += 1
            }
            while index < chars.count {
                let char = chars[index]
                if char.isNumber {
                    index += 1
                } else if char == ".", !hasDot, !hasExponent {
                    hasDot = true
                    index += 1
                } else if char == "e" || char == "E", !hasExponent {
                    hasExponent = true
                    index += 1
                    if index < chars.count, chars[index] == "-" || chars[index] == "+" {
                        index += 1
                    }
                } else {
                    break
                }
            }
            guard index > begin, let value = Double(String(chars[begin..<index])) else {
                return nil
            }
            return CGFloat(value)
        }

        private mutating func skipSeparators() {
            while index < chars.count, chars[index] == " " || chars[index] == "," || chars[index].isNewline {
                index += 1
            }
        }
    }

}
