import Danger

let danger = Danger()

SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Sources"),
               inline: false,
               configFile: ".swiftlint.yml")

SwiftLint.lint(.modifiedAndCreatedFiles(directory: "Example"),
               inline: false,
               configFile: ".swiftlint.yml")
