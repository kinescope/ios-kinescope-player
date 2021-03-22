import Danger

let danger = Danger()

var violations = [SwiftLintViolation]()

violations.append(contentsOf: SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Sources"),
                                             inline: false,
                                             configFile: ".swiftlint.yml"))

violations.append(contentsOf: SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Example"),
                                             inline: false,
                                             configFile: ".swiftlint.yml"))

switch violations.count {
case 0:
    danger.message("Great! We didn't found any violations in your changes. Congratulations  🎉")
case 1..<20:
    danger.warn("Oops! We have found some issues. It's better to fix them to keep code clean ")
default:
    danger.fail("Omg. Your code smells bad. Please fix issues above")
}
