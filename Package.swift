// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EFDBUI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "EFDBUI",
            targets: ["EFDBUI"]
        )
    ],
    targets: [
        .executableTarget(
            name: "EFDBUI",
            path: ".",
            exclude: [
                "README.md",
                "QUICKSTART.md",
                "INTEGRATION_EXAMPLES.md",
                "BUILD_AND_DISTRIBUTION.md",
                "UI_LAYOUT.md",
                "USAGE.md",
                "AUTHENTICATION.md",
                "PROJECT_STATUS.md",
                "Info.plist",
                "Makefile",
                "build.sh",
                "create-release.sh",
                "efdbui.rb",
                ".gitignore"
            ],
            sources: [
                "EFDBUIApp.swift",
                "ContentView.swift",
                "ObjectViewModel.swift",
                "LargeTextView.swift",
                "CommandAction.swift",
                "CommandDialogs.swift",
                "CustomConfirmationWindow.swift"
            ]
        )
    ]
)

