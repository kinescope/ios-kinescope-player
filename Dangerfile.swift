import Danger

let danger = Danger()

var violations = [SwiftLintViolation]()

violations.append(contentsOf: SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Sources"),
                                             inline: false,
                                             configFile: ".swiftlint.yml"))

violations.append(contentsOf: SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Example"),
                                             inline: false,
                                             configFile: ".swiftlint.yml"))

if violations.isEmpty {
    danger.message("✅ Great! We didn't found any violations in your changes. Congratulations 🎉")
}
